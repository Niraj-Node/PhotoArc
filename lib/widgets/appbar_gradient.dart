import 'package:flutter/material.dart';

class AppBarGradient extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color primaryColor;
  final Color secondaryColor;

  @override
  final Size preferredSize;

  const AppBarGradient({
    super.key,
    this.title = "PhotoArc",
    this.primaryColor = const Color(0xff4338CA),
    this.secondaryColor = const Color(0xff6D28D9),
  }) : preferredSize = const Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      backgroundColor: primaryColor,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, secondaryColor],
            stops: const [0.5, 1.0],
          ),
        ),
      ),
    );
  }
}
