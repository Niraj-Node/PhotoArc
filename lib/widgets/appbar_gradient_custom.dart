import 'package:flutter/material.dart';

class AppBarCustom extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color primaryColor;
  final Color secondaryColor;
  final List<Widget> actions;
  final Color titleColor;
  final double elevation;
  final bool centerTitle;

  @override
  final Size preferredSize;

  const AppBarCustom({
    Key? key,
    this.title = "PhotoArc",
    this.primaryColor = const Color(0xff4338CA),
    this.secondaryColor = const Color(0xff6D28D9),
    required this.actions,
    this.titleColor = Colors.white,
    this.elevation = 4.0,
    this.centerTitle = false, // Set to false to align title to the left
  })  : preferredSize = const Size.fromHeight(56.0),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Align(
        alignment: Alignment.centerLeft, // Align the title to the left
        child: Text(
          title,
          style: TextStyle(color: titleColor),
        ),
      ),
      actions: actions,
      elevation: elevation,
      centerTitle: false, // Ensure this is false to keep title left-aligned
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
