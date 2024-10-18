import 'package:flutter/material.dart';

class DialogBox extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? avatarImageUrl;
  final String primaryButtonText;
  final String secondaryButtonText;
  final Function() primaryButtonAction;
  final Function() secondaryButtonAction;
  final bool invertSecondaryButton;
  final Color primaryColor;
  final Color accentColor;
  final double borderRadius;
  final double avatarRadius;
  final TextStyle? titleTextStyle;
  final TextStyle? subtitleTextStyle;
  final EdgeInsetsGeometry? contentPadding;

  const DialogBox({
    super.key,
    required this.title,
    required this.subtitle,
    this.avatarImageUrl,
    required this.primaryButtonText,
    required this.secondaryButtonText,
    required this.primaryButtonAction,
    required this.secondaryButtonAction,
    this.invertSecondaryButton = false,
    this.primaryColor = const Color(0xff4338CA),
    this.accentColor = Colors.white,
    this.borderRadius = 15.0,
    this.avatarRadius = 25.0,
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {

    return Dialog(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Padding(
        padding: contentPadding ?? const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (avatarImageUrl != null)
              CircleAvatar(
                backgroundColor: primaryColor,
                radius: avatarRadius,
                backgroundImage: NetworkImage(avatarImageUrl!),
              ),
            const SizedBox(height: 20),
            Text(
              title,
              style: titleTextStyle ??
                  const TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              style: subtitleTextStyle ??
                  const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildButton(
                  text: primaryButtonText,
                  onPressed: primaryButtonAction,
                  color: primaryColor,
                  textColor: Colors.white,
                  borderColor: primaryColor,
                ),
                _buildButton(
                  text: secondaryButtonText,
                  onPressed: secondaryButtonAction,
                  color: invertSecondaryButton ? accentColor : Colors.white,
                  textColor: invertSecondaryButton ? Colors.white : Colors.black,
                  borderColor: primaryColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required Function() onPressed,
    required Color color,
    required Color textColor,
    required Color borderColor,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 100),
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(color),
          foregroundColor: WidgetStateProperty.all(textColor),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: borderColor),
            ),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
