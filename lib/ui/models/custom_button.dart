import 'package:flutter/material.dart';
import 'package:ashal/ui/theme.dart' as Theme;

class CustomButton extends RaisedButton {
  CustomButton({
    Key key,
    @required VoidCallback onPressed,
    ValueChanged<bool> onHighlightChanged,
    ButtonTextTheme textTheme,
    Color textColor,
    Color disabledTextColor,
    Color color,
    Color disabledColor,
    Color highlightColor,
    Color splashColor,
    Brightness colorBrightness,
    double elevation,
    EdgeInsets padding,
    double highlightElevation,
    double disabledElevation,
    ShapeBorder shape,
    Clip clipBehavior = Clip.none,
    MaterialTapTargetSize materialTapTargetSize,
    Duration animationDuration,
    Widget prefix,
    @required Widget label,
    bool loading = false,
    bool disabled = false,
  }) : super(
    key: key,
    onPressed: disabled ? null : loading ? () {} : onPressed,
    onHighlightChanged: onHighlightChanged,
    textTheme: textTheme,
    textColor: textColor ?? Theme.Colors.primary,
    disabledTextColor: disabledTextColor ??
        Theme.Colors.primary.withAlpha(50),
    color: color,
    disabledColor:
    disabledColor ?? Theme.Colors.primary.withAlpha(50),
    highlightColor: loading ? Colors.transparent : highlightColor,
    splashColor: loading ? Colors.transparent : splashColor,
    colorBrightness: colorBrightness,
    elevation: elevation,
    padding: padding,
    highlightElevation: highlightElevation,
    disabledElevation: disabledElevation,
    shape: shape,
    clipBehavior: clipBehavior,
    materialTapTargetSize: materialTapTargetSize,
    animationDuration: animationDuration,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: loading
          ? [
        SizedBox(
          height: 15,
          width: 15,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
                Theme.Colors.primary),
          ),
        )
      ]
          : [
        prefix ?? SizedBox.shrink(),
        const SizedBox(width: 8.0),
        label,
      ],
    ),
  );
}
