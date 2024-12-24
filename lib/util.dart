import 'dart:io';

import 'package:io/io.dart';
import 'package:metadata_god/metadata_god.dart';
import 'progress_dispatcher.dart';

Future<Metadata> getMetadata(String path) => MetadataGod.readMetadata(file: path);

Future<void> runCataloger(
  String pathFrom,
  String pathTo,
  String toCueSplit,
  ProgressDispatcher progress,
  bool deleteAfterCopy,
) async {
  final rootDirectory = Directory(pathFrom);
  final directories = await rootDirectory.getAllPotentialDirectories;
  int counter = 1;
  for (final currentDirectory in directories) {
    if (!currentDirectory.existsSync()) {
      continue;
    }
    final files = await currentDirectory.files;

    final p = counter++ / directories.length;
    progress.put(p > 1 ? 1 : p);

    if (files.isEmpty) {
      if (await currentDirectory.list().isEmpty) {
        if (deleteAfterCopy && rootDirectory.path != currentDirectory.path) {
          await currentDirectory.deleteRecursive();
        }
      }
      continue;
    }
    final filesWithAudio = files.where((e) => e.isAudio);
    final notAudioFiles = files.where((e) => !e.isAudio).toList();
    final cueFiles = files.where((e) => e.extension == 'cue').toList();

    if (cueFiles.isNotEmpty && cueFiles.length >= filesWithAudio.length || files.any((e) => e.extension == 'ape')) {
      final toDir = '$toCueSplit\\${currentDirectory.uri.pathSegments.where((e) => e.isNotEmpty).last}';
      if (Directory(toDir).existsSync()) {
        if (deleteAfterCopy && rootDirectory.path != currentDirectory.path) {
          await currentDirectory.deleteRecursive();
        }
        continue;
      }
      await copyPath(currentDirectory.path, toDir);
      if (deleteAfterCopy && rootDirectory.path != currentDirectory.path) {
        await currentDirectory.deleteRecursive();
      }
      continue;
    }

    if (filesWithAudio.isEmpty) {
      continue;
    }

    final audioFiles = await Future.wait(filesWithAudio.map((file) async {
      Metadata metadata;
      try {
        metadata = await file.metadata;
      } catch (e) {
        metadata = Metadata(album: file.name, artist: 'Unknown');
      }
      return AudioFile(file: file, metadata: metadata);
    }).toList());

    final albums = <List<AudioFile>>[];

    for (final file in audioFiles) {
      if (albums.isEmpty) {
        albums.add([file]);
        continue;
      }
      if (albums.last.first.isEqualAlbum(file)) {
        albums.last.add(file);
      } else {
        albums.add([file]);
      }
    }

    for (final album in albums) {
      await copyTracksInAlbum(cueFiles, notAudioFiles, album, pathTo);
    }

    if (deleteAfterCopy && rootDirectory.path != currentDirectory.path) {
      await currentDirectory.deleteRecursive();
    }
  }

  if (deleteAfterCopy) {
    for (final entity in await rootDirectory.list().toList()) {
      await entity.delete(recursive: true);
    }
  }
}

Future<void> copyTracksInAlbum(
  List<File> cueFiles,
  List<File> notAudioFiles,
  List<AudioFile> album,
  String pathTo,
) async {
  String? performer;
  if (cueFiles.isNotEmpty) {
    performer = await cueFiles.first.getCueValue('PERFORMER');
  }

  final author = (performer?.emptyToNull ??
          album.first.metadata.albumArtist?.emptyToNull ??
          album.first.metadata.artist?.emptyToNull ??
          'Unknown')
      .trim();
  final albumName = (album.first.metadata.album?.emptyToNull ?? 'Unknown').trim();
  final year = album.first.metadata.year;
  final artistAlbumPathSegment = '${author.clearDirPath}\\${year == null ? '' : '$year - '}${albumName.clearDirPath}';
  final destinationAlbumPath = await createAlbumDir('$pathTo\\$artistAlbumPathSegment');

  for (final notAudioFile in notAudioFiles) {
    final anyFilesPath = '$destinationAlbumPath\\${notAudioFile.uri.pathSegments.last}';
    await notAudioFile.copy(anyFilesPath);
  }

  for (final track in album) {
    final trackPath = '$destinationAlbumPath\\${track.file.uri.pathSegments.last.replaceAll(':', '')}';
    await track.file.copy(trackPath);
  }
}

Future<String> createAlbumDir(String path, {bool firstRun = true}) async {
  final newDir = Directory(path);
  String clearPath = path;
  if (!newDir.existsSync()) {
    return (await newDir.create(recursive: true)).path;
  } else {
    int number = 1;
    if (!firstRun) {
      final suffix = RegExp(r' \d+$').allMatches(path).map((m) => m.group(0)).where((text) => text != null).first ?? '';
      clearPath = path.replaceAll(RegExp(r' \d+$'), '');
      number = (int.tryParse(suffix.trim()) ?? 100) + 1;
    }
    return createAlbumDir('$clearPath $number', firstRun: false);
  }
}

extension on String {
  String? get emptyToNull => isEmpty ? null : this;

  String get clearDirPath => replaceAll(RegExp(r'[/\\*."\[\]:;|,?><]'), '').trim();
}

extension on Directory {
  Future<List<File>> get files => list().where((e) => e is File).map((e) => e as File).toList();

  Future<void> deleteRecursive() async {
    try {
      await delete(recursive: true);
    } catch (e) {
      print(e);
    }
  }

  Future<List<Directory>> get getAllPotentialDirectories async {
    final dirs = await list(recursive: true)
        .where((e) => e is Directory)
        .map((e) => e as Directory)
        .where((e) => e.listSync().any((e) => e is Directory || (e is File && e.isAudio)))
        .toList();
    return dirs..add(this);
  }
}

extension on File {
  String get extension => path.split('.').last;

  String get name => uri.pathSegments.last.replaceFirst(r'\.[^\.]+$', '');

  bool get isAudio => ['m4a', 'mp3', 'flac'].contains(extension);

  Future<Metadata> get metadata => MetadataGod.readMetadata(file: path);

  Future<String?> getCueValue(String key) async {
    try {
      final performerLines = (await readAsLines()).where((l) => l.contains(key)).toList();
      if (performerLines.isNotEmpty) {
        final line = performerLines.first;
        if (line.allMatches(r'\"').length == 2) {
          return RegExp(r'"(.+)"').allMatches(line).map((m) => m.group(1)).where((text) => text != null).first;
        }
        if (line.allMatches(r'\"').length < 2) {
          return line.replaceFirst(key, '').trim();
        }
        return null;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

class AudioFile {
  final File file;
  final Metadata metadata;

  const AudioFile({
    required this.file,
    required this.metadata,
  });

  bool isEqualAlbum(AudioFile other) {
    return metadata.year == other.metadata.year && metadata.album == other.metadata.album;
  }
}
