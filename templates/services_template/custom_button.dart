// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'responsive_size.dart';
import 'colors.dart';
import 'text_style_util.dart';

/// Button style variants
enum ButtonStyle {
  filled,
  outline,
  text,
  icon,
}

/// Advanced customizable button component with multiple styles and features
class CustomButton extends StatelessWidget {
  /// Button title/text
  final String? title;
  
  /// Button icon (for icon button)
  final IconData? icon;
  
  /// Whether button is disabled
  final bool disabled;
  
  /// Whether button is in loading state
  final bool isLoading;
  
  /// Tap callback
  final VoidCallback? onTap;
  
  /// Button style variant
  final ButtonStyle style;
  
  /// Leading widget (icon or widget before text)
  final Widget? leading;
  
  /// Trailing widget (icon or widget after text)
  final Widget? trailing;
  
  /// Linear gradient for filled button
  final LinearGradient? linearGradient;
  
  /// Button background color
  final Color? color;
  
  /// Text color
  final Color? textColor;
  
  /// Border radius
  final double? borderRadius;
  
  /// Custom border radius
  final BorderRadius? radius;
  
  /// Button height
  final double? height;
  
  /// Button width (null = full width)
  final double? width;
  
  /// Border width (for outline button)
  final double borderWidth;
  
  /// Padding around content
  final EdgeInsetsGeometry? padding;
  
  /// Margin around button
  final EdgeInsetsGeometry? margin;
  
  /// Loading indicator color
  final Color? loadingColor;
  
  /// Loading indicator size
  final double? loadingSize;
  
  /// Box shadow
  final List<BoxShadow>? boxShadow;
  
  /// Button elevation
  final double? elevation;

  /// Standard filled button
  const CustomButton({
    Key? key,
    this.title,
    this.icon,
    this.disabled = false,
    this.isLoading = false,
    this.onTap,
    this.leading,
    this.trailing,
    this.linearGradient,
    this.color,
    this.textColor,
    this.borderRadius,
    this.radius,
    this.height,
    this.width,
    this.borderWidth = 1.0,
    this.padding,
    this.margin,
    this.loadingColor,
    this.loadingSize,
    this.boxShadow,
    this.elevation,
  })  : style = ButtonStyle.filled,
        super(key: key);

  /// Outline button constructor
  const CustomButton.outline({
    Key? key,
    this.title,
    this.icon,
    this.disabled = false,
    this.isLoading = false,
    this.onTap,
    this.leading,
    this.trailing,
    this.color,
    this.textColor,
    this.borderRadius,
    this.radius,
    this.height,
    this.width,
    this.borderWidth = 1.0,
    this.padding,
    this.margin,
    this.loadingColor,
    this.loadingSize,
    this.boxShadow,
    this.elevation,
  })  : style = ButtonStyle.outline,
        linearGradient = null,
        super(key: key);

  /// Text button constructor
  const CustomButton.text({
    Key? key,
    this.title,
    this.icon,
    this.disabled = false,
    this.isLoading = false,
    this.onTap,
    this.leading,
    this.trailing,
    this.color,
    this.textColor,
    this.borderRadius,
    this.radius,
    this.height,
    this.width,
    this.padding,
    this.margin,
    this.loadingColor,
    this.loadingSize,
  })  : style = ButtonStyle.text,
        linearGradient = null,
        borderWidth = 0,
        boxShadow = null,
        elevation = null,
        super(key: key);

  /// Icon button constructor
  const CustomButton.icon({
    Key? key,
    required this.icon,
    this.disabled = false,
    this.isLoading = false,
    this.onTap,
    this.color,
    this.textColor,
    this.borderRadius,
    this.radius,
    this.height,
    this.width,
    this.padding,
    this.margin,
    this.loadingColor,
    this.loadingSize,
    this.boxShadow,
    this.elevation,
  })  : style = ButtonStyle.icon,
        title = null,
        leading = null,
        trailing = null,
        linearGradient = null,
        borderWidth = 0,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = height ?? 48.kh;
    final effectiveRadius = radius ?? 
        (borderRadius != null ? BorderRadius.circular(borderRadius!) : BorderRadius.circular(12.kh));
    final effectiveColor = color ?? Get.context?.brandColor1 ?? Colors.blue;
    final effectiveTextColor = textColor ?? 
        (style == ButtonStyle.filled ? Colors.white : effectiveColor);

    Widget buttonWidget;

    switch (style) {
      case ButtonStyle.filled:
        buttonWidget = _buildFilledButton(
          context,
          effectiveHeight,
          effectiveRadius,
          effectiveColor,
          effectiveTextColor,
        );
        break;
      case ButtonStyle.outline:
        buttonWidget = _buildOutlineButton(
          context,
          effectiveHeight,
          effectiveRadius,
          effectiveColor,
          effectiveTextColor,
        );
        break;
      case ButtonStyle.text:
        buttonWidget = _buildTextButton(
          context,
          effectiveHeight,
          effectiveRadius,
          effectiveColor,
          effectiveTextColor,
        );
        break;
      case ButtonStyle.icon:
        buttonWidget = _buildIconButton(
          context,
          effectiveHeight,
          effectiveRadius,
          effectiveColor,
        );
        break;
    }

    if (margin != null) {
      buttonWidget = Padding(
        padding: margin!,
        child: buttonWidget,
      );
    }

    if (width != null) {
      buttonWidget = SizedBox(
        width: width,
        child: buttonWidget,
      );
    }

    return buttonWidget;
  }

  Widget _buildFilledButton(
    BuildContext context,
    double height,
    BorderRadius radius,
    Color bgColor,
    Color textColor,
  ) {
    return Material(
      color: Colors.transparent,
      elevation: elevation ?? (disabled ? 0 : 2),
      borderRadius: radius,
      child: InkWell(
        onTap: disabled || isLoading ? null : onTap,
        borderRadius: radius,
        child: Container(
          width: width ?? double.infinity,
          height: height,
          padding: padding,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: linearGradient ??
                (disabled
                    ? null
                    : LinearGradient(
                        colors: [bgColor, bgColor],
                      )),
            color: disabled ? bgColor.withOpacity(0.5) : (linearGradient == null ? bgColor : null),
            boxShadow: boxShadow ??
                (disabled || elevation == 0
                    ? null
                    : [
                        BoxShadow(
                          color: bgColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]),
          ),
          child: _buildContent(textColor),
        ),
      ),
    );
  }

  Widget _buildOutlineButton(
    BuildContext context,
    double height,
    BorderRadius radius,
    Color borderColor,
    Color textColor,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: disabled || isLoading ? null : onTap,
        borderRadius: radius,
        child: Container(
          width: width ?? double.infinity,
          height: height,
          padding: padding,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: radius,
            border: Border.all(
              color: disabled ? borderColor.withOpacity(0.5) : borderColor,
              width: borderWidth,
            ),
          ),
          child: _buildContent(textColor),
        ),
      ),
    );
  }

  Widget _buildTextButton(
    BuildContext context,
    double height,
    BorderRadius radius,
    Color textColor,
    Color effectiveTextColor,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: disabled || isLoading ? null : onTap,
        borderRadius: radius,
        child: Container(
          width: width ?? double.infinity,
          height: height,
          padding: padding,
          alignment: Alignment.center,
          child: _buildContent(effectiveTextColor),
        ),
      ),
    );
  }

  Widget _buildIconButton(
    BuildContext context,
    double height,
    BorderRadius radius,
    Color bgColor,
  ) {
    return Material(
      color: Colors.transparent,
      elevation: elevation ?? (disabled ? 0 : 2),
      borderRadius: radius,
      child: InkWell(
        onTap: disabled || isLoading ? null : onTap,
        borderRadius: radius,
        child: Container(
          width: width ?? height,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: disabled ? bgColor.withOpacity(0.5) : bgColor,
            borderRadius: radius,
            boxShadow: boxShadow,
          ),
          alignment: Alignment.center,
          child: isLoading
              ? _buildLoadingIndicator()
              : Icon(
                  icon,
                  color: textColor ?? Colors.white,
                  size: loadingSize ?? 24,
                ),
        ),
      ),
    );
  }

  Widget _buildContent(Color textColor) {
    if (isLoading) {
      return _buildLoadingIndicator();
    }

    if (style == ButtonStyle.icon && icon != null) {
      return Icon(
        icon,
        color: textColor,
        size: loadingSize ?? 24,
      );
    }

    final children = <Widget>[];

    if (leading != null) {
      children.add(leading!);
      children.add(SizedBox(width: 8.kw));
    }

    if (icon != null && style != ButtonStyle.icon) {
      children.add(Icon(icon, color: textColor, size: 20));
      if (title != null) {
        children.add(SizedBox(width: 8.kw));
      }
    }

    if (title != null) {
      children.add(
        Flexible(
          child: Text(
            title!,
            style: TextStyleUtil.genSans600(
              color: textColor,
              fontSize: 16.kh,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }

    if (trailing != null) {
      children.add(SizedBox(width: 8.kw));
      children.add(trailing!);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      height: loadingSize ?? 20,
      width: loadingSize ?? 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          loadingColor ?? Colors.white,
        ),
      ),
    );
  }
}
