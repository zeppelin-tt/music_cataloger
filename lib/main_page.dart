import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import 'check_box.dart';
import 'palette.dart';
import 'progress_dispatcher.dart';
import 'text_styles.dart';
import 'util.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final progressDispatcher = ProgressDispatcher(initialValue: 0);
  String buttonFromText = 'Введите';
  String buttonToText = 'Введите';
  String buttonToCueSplit = 'Введите';
  bool isLaunched = false;
  bool deleteAfterCopy = false;

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
          Row(
            children: [
              AppCheckbox(onChanged: (bool value) => deleteAfterCopy = value),
              const SizedBox(width: 10),
              Text('Delete after copy', style: TextStyles.accentText),
            ],
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 98,
            width: double.infinity,
            child: StreamBuilder<double>(
              stream: progressDispatcher.stream,
              initialData: progressDispatcher.value,
              builder: (context, progress) {
                return TextButton(
                  onPressed: () async {
                    setState(() => isLaunched = true);
                    await runCataloger(
                      buttonFromText,
                      buttonToText,
                      buttonToCueSplit,
                      progressDispatcher,
                      deleteAfterCopy,
                    );
                    progressDispatcher.put(0);
                    setState(() => isLaunched = false);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  ),
                  child: isLaunched
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: LinearProgressIndicator(
                            minHeight: 40,
                            value: progress.requireData,
                            backgroundColor: Palette.disabledButtons,
                            color: Palette.enabledButtons,
                            semanticsLabel: 'Linear progress indicator',
                          ),
                        )
                      : Text('Поехали!', style: TextStyles.mainText.copyWith(fontSize: 38)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    progressDispatcher.dispose();
    super.dispose();
  }

  Future<String?> getDirPath() => getDirectoryPath(confirmButtonText: 'Choose directory');
}

class _Button extends StatefulWidget {
  final VoidCallback onPressed;
  final String textPrefix;
  final String? textValue;
  final String textError;

  const _Button({
    required this.onPressed,
    required this.textPrefix,
    required this.textError,
    required this.textValue,
  });

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
