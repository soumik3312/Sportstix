import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';

/// A text widget that adapts its font size based on the screen size
class AdaptiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;
  final double scaleFactor;

  const AdaptiveText(
    this.text, {
    Key? key,
    this.style,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.scaleFactor = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final defaultStyle = DefaultTextStyle.of(context).style;
    final baseStyle = style ?? defaultStyle;
    
    // Calculate the responsive font size
    final fontSize = baseStyle.fontSize ?? 14.0;
    final responsiveFontSize = ResponsiveHelper.getResponsiveFontSize(
      context, 
      fontSize * scaleFactor
    );
    
    return Text(
      text,
      style: baseStyle.copyWith(fontSize: responsiveFontSize),
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
    );
  }
}

/// A headline text widget that adapts its font size based on the screen size
class AdaptiveHeadline extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;
  final Color? color;
  final FontWeight? fontWeight;
  final double level;

  const AdaptiveHeadline(
    this.text, {
    Key? key,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.color,
    this.fontWeight,
    this.level = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Base font size based on headline level (1-6)
    double baseFontSize;
    FontWeight baseWeight;
    
    switch (level.round()) {
      case 1:
        baseFontSize = 32.0;
        baseWeight = FontWeight.bold;
        break;
      case 2:
        baseFontSize = 28.0;
        baseWeight = FontWeight.bold;
        break;
      case 3:
        baseFontSize = 24.0;
        baseWeight = FontWeight.bold;
        break;
      case 4:
        baseFontSize = 20.0;
        baseWeight = FontWeight.w600;
        break;
      case 5:
        baseFontSize = 18.0;
        baseWeight = FontWeight.w600;
        break;
      case 6:
        baseFontSize = 16.0;
        baseWeight = FontWeight.w600;
        break;
      default:
        baseFontSize = 24.0;
        baseWeight = FontWeight.bold;
    }
    
    return AdaptiveText(
      text,
      style: TextStyle(
        fontSize: baseFontSize,
        fontWeight: fontWeight ?? baseWeight,
        color: color,
      ),
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
    );
  }
}

/// A body text widget that adapts its font size based on the screen size
class AdaptiveBodyText extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;
  final Color? color;
  final FontWeight? fontWeight;
  final double size;

  const AdaptiveBodyText(
    this.text, {
    Key? key,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.color,
    this.fontWeight,
    this.size = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Base font size based on body text size (1-3)
    double baseFontSize;
    
    switch (size.toInt()) {
      case 1:
        baseFontSize = 16.0;
        break;
      case 2:
        baseFontSize = 14.0;
        break;
      case 3:
        baseFontSize = 12.0;
        break;
      default:
        baseFontSize = 14.0;
    }
    
    return AdaptiveText(
      text,
      style: TextStyle(
        fontSize: baseFontSize,
        fontWeight: fontWeight ?? FontWeight.normal,
        color: color,
      ),
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
    );
  }
}
