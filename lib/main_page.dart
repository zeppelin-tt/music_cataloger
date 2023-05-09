import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:music_cataloger/palette.dart';
import 'package:music_cataloger/text_styles.dart';
import 'package:music_cataloger/utill.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String buttonFromText = 'Введите';
  String buttonToText = 'Введите';
  String buttonToCueSplit = 'Введите';
  String metadata = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 30),
      child: Column(
        children: [
          _Button(
            textValue: buttonFromText,
            textPrefix: 'Где',
            onPressed: () async {
              final dirPath = await getDirPath();
              if (dirPath != null) {
                setState(() => buttonFromText = dirPath);
              }
            },
            textError: '',
          ),
          const SizedBox(height: 30),
          _Button(
            textValue: buttonToText,
            textPrefix: 'Куда',
            onPressed: () async {
              final dirPath = await getDirPath();
              if (dirPath != null) {
                setState(() => buttonToText = dirPath);
              }
            },
            textError: '',
          ),
          const SizedBox(height: 30),
          _Button(
            textValue: buttonToCueSplit,
            textPrefix: 'cue',
            onPressed: () async {
              final dirPath = await getDirPath();
              if (dirPath != null) {
                setState(() => buttonToCueSplit = dirPath);
              }
            },
            textError: '',
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 98,
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                foo(buttonFromText, buttonToText, buttonToCueSplit);
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              ),
              child:  Text('Поехали!', style: TextStyles.mainText.copyWith(fontSize: 38)),
            ),
          ),
          const SizedBox(height: 30),
          Text(metadata, style: TextStyles.mainText, textAlign: TextAlign.center)
        ],
      ),
    );
  }

  Future<String?> getDirPath() => getDirectoryPath(confirmButtonText: 'Choose directory');
}

class _Button extends StatefulWidget {
  final VoidCallback onPressed;
  final String textPrefix;
  final String? textValue;
  final String textError;

  const _Button({
    Key? key,
    required this.onPressed,
    required this.textPrefix,
    required this.textError,
    required this.textValue,
  }) : super(key: key);

  @override
  State<_Button> createState() => _ButtonState();
}

class _ButtonState extends State<_Button> {
  bool isOnHover = false;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: SizedBox(
        height: 34,
        child: InkWell(
          onHover: (isOnHover) => setState(() => this.isOnHover = isOnHover),
          radius: 5,
          borderRadius: BorderRadius.circular(5),
          onTap: widget.onPressed,
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 34,
                  child: ColoredBox(
                    color: Colors.green,
                    child: Center(
                      child: Text(widget.textPrefix, style: TextStyles.mainText),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 8,
                child: SizedBox(
                  height: 34,
                  child: ColoredBox(
                    color: isOnHover ? Palette.enabledButtons.withOpacity(0.5) : Palette.disabledButtons,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: Text(
                          widget.textValue != null ? widget.textValue! : widget.textError,
                          style: widget.textValue != null ? TextStyles.accentText : TextStyles.errorText,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
