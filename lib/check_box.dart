import 'package:flutter/material.dart';
import 'palette.dart';

class AppCheckbox extends StatefulWidget {
  final ValueChanged<bool> onChanged;

  const AppCheckbox({
    super.key,
    required this.onChanged,
  });

  @override
  State<AppCheckbox> createState() => _AppCheckboxState();
}

class _AppCheckboxState extends State<AppCheckbox> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Palette.enabledButtons;
      }
      return Palette.disabledButtons;
    }

    return Checkbox(
      checkColor: Colors.white,
      fillColor: MaterialStateProperty.resolveWith(getColor),
      value: isChecked,
      onChanged: (bool? value) {
        if(value != null) {
          widget.onChanged(value);
          setState(() => isChecked = value);
        }
      },
    );
  }
}
