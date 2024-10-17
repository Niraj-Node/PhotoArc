import 'package:flutter/material.dart';

class SplashButton extends StatelessWidget {
  final String title;
  final String subText;
  final Function() onPressed;

  final double width;
  final double height;
  final double borderRadius;
  final List<Color> gradientColors;
  final FontWeight fontWeight;
  final double fontSize;
  final Color fontColor;
  final double subTextFontSize;
  final Color subTextFontColor;

  const SplashButton({
    required this.title,
    required this.onPressed,
    this.subText = "",
    this.width = 150,
    this.height = 50.0,
    this.borderRadius = 20.0,
    this.gradientColors = const [Colors.blueAccent, Colors.deepPurpleAccent],
    this.fontWeight = FontWeight.w600,
    this.fontSize = 16.0,
    this.fontColor = Colors.white,
    this.subTextFontSize = 12.0,
    this.subTextFontColor = Colors.white70,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: onPressed,
        splashColor: gradientColors[1].withOpacity(0.3),
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          width: width,
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: fontWeight,
                  color: fontColor,
                  fontFamily: 'RobotoMono',
                ),
              ),
              if (subText.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 5.0),
                  child: Text(
                    subText,
                    style: TextStyle(
                      fontSize: subTextFontSize,
                      color: subTextFontColor,
                      fontFamily: 'RobotoMono',
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
