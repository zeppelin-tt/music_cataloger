import 'dart:io';

import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:io/io.dart';

Future<Metadata> getMetadata(String path) => MetadataRetriever.fromFile(File(path));

Future<void> foo(String pathFrom, String pathTo, String toCueSplit) async {
  final directories = await getAllDirectories(pathFrom);
  for (final currentDirectory in directories) {
    final files = await currentDirectory.files;
    if (files.isEmpty) {
      continue;
    }
    final audioFiles = await Future.wait(files.where((e) => e.isAudio).map((e) async {
      return AudioFile(file: e, metadata: await e.metadata);
    }).toList());
    final notAudioFiles = files.where((e) => !e.isAudio).toList();
    final cueFiles = files.where((e) => e.extension == 'cue').toList();

    if (cueFiles.isNotEmpty && cueFiles.length == audioFiles.length) {
      await copyPath(
        currentDirectory.path,
        '$toCueSplit\\${currentDirectory.uri.pathSegments.where((e) => e.isNotEmpty).last}',
      );
      continue;
    }

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

    for (final album in albums) {}
  }
}

Future<List<Directory>> getAllDirectories(String rootPath) async {
  return Directory(rootPath).list(recursive: true).where((e) => e is Directory).map((e) => e as Directory).toList();
}

extension on Directory {
  Future<List<File>> get files => list().where((e) => e is File).map((e) => e as File).toList();
}

extension on File {
  String get extension => path.split('.').last;

  String get name => uri.pathSegments.last.replaceFirst(r'\.[^\.]+$', '');

  bool get isAudio => ['m4a', 'mp3', 'flac'].contains(extension);

  Future<Metadata> get metadata => MetadataRetriever.fromFile(this);
}

class AudioFile {
  final File file;
  final Metadata metadata;

  const AudioFile({
    required this.file,
    required this.metadata,
  });

  bool isEqualAlbum(AudioFile other) {
    return metadata.year == other.metadata.year &&
        metadata.albumName == other.metadata.albumName &&
        metadata.authorName == other.metadata.authorName;
  }
}
