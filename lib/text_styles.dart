import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'palette.dart';

class TextStyles {
  static final mainText = GoogleFonts.nunito(
    fontSize: 18,
    letterSpacing: 2,
    color: Palette.mainText,
    fontWeight: FontWeight.w600,
  ).copyWith(overflow: TextOverflow.ellipsis);
  static final accentText = mainText.copyWith(color: Palette.enabledButtons);
  static final darkText = mainText.copyWith(color: Palette.header);
  static final errorText = mainText.copyWith(color: Palette.errorText);
}
