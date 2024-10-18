import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:photoarc/utils/routes.dart';
import 'package:photoarc/widgets/snackbar/error_snackbar.dart';
import 'package:photoarc/widgets/snackbar/primary_snackbar.dart';

class NavBar extends StatefulWidget {
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final int? selectedTab;

  NavBar({
    this.primaryColor = Colors.green,
    this.secondaryColor = Colors.white,
    this.selectedTab, // No default value, optional
    Key? key,
  })  : backgroundColor = Colors.black.withOpacity(.5),
        super(key: key);

  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {

  Future<void> _handleCameraAction(BuildContext context) async {
    final cameraStatus = await Permission.camera.status;

    if (!cameraStatus.isGranted) {
      final result = await Permission.camera.request();
      if (!result.isGranted) {
        ErrorSnackbar(context, "Camera permission denied.");
        return;
      }
    }

    // If the camera permission is granted, navigate to the CameraScreen
    Navigator.of(context).pushReplacementNamed(Routes.camera);
  }

  Future<void> _handleCloudImagesAction(BuildContext context) async {
    Navigator.of(context).pushReplacementNamed(Routes.cloudImages);
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushReplacementNamed(Routes.signin);
    } catch (e) {
      print('Error signing out: $e');
      ErrorSnackbar(context, 'Error signing out. Please try again.');
    }
  }

  void _showSnackBar(String message) {
    primarySnackbar(context, message);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double height = 56;

    final primaryColor = widget.primaryColor;
    final secondaryColor = widget.secondaryColor;
    final backgroundColor = widget.backgroundColor;

    return BottomAppBar(
      color: Colors.transparent,
      elevation: 0,
      child: Stack(
        children: [
          CustomPaint(
            size: Size(size.width, height + 6),
            painter: BottomNavCurvePainter(backgroundColor: backgroundColor),
          ),
          Center(
            heightFactor: 0.6,
            child: FloatingActionButton(
              backgroundColor: primaryColor,
              elevation: 0.1,
              onPressed: () {},
              child: const Icon(Icons.landscape),
            ),
          ),
          SizedBox(
            height: height,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                NavBarIcon(
                  text: "Home",
                  icon: Icons.home_outlined,
                  selected: widget.selectedTab == 0,
                  onPressed: () { Navigator.of(context).pushReplacementNamed(Routes.home); },
                  defaultColor: secondaryColor,
                  selectedColor: primaryColor,
                ),
                NavBarIcon(
                  text: "Camera",
                  icon: Icons.camera_alt,
                  selected: widget.selectedTab == 1,
                  onPressed: () => _handleCameraAction(context),
                  defaultColor: secondaryColor,
                  selectedColor: primaryColor,
                ),
                const SizedBox(width: 56),
                NavBarIcon(
                  text: "Cloud",
                  icon: Icons.cloud,
                  selected: widget.selectedTab == 2,
                  onPressed: () => _handleCloudImagesAction(context),
                  defaultColor: secondaryColor,
                  selectedColor: primaryColor,
                ),
                NavBarIcon(
                  text: "Log Out",
                  icon: Icons.logout,
                  selected: widget.selectedTab == 3,
                  onPressed: () => _signOut(),
                  selectedColor: primaryColor,
                  defaultColor: secondaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BottomNavCurvePainter extends CustomPainter {
  final Color backgroundColor;
  final double insetRadius;

  BottomNavCurvePainter({
    this.backgroundColor = Colors.white,
    this.insetRadius = 35,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    Path path = Path()..moveTo(-size.width * 0.2, 12);

    double insetCurveBeginnningX = size.width / 2 - insetRadius;
    double insetCurveEndX = size.width / 2 + insetRadius;
    double transitionToInsetCurveWidth = size.width * .05;

    path.quadraticBezierTo(size.width * 0.20, 0,
        insetCurveBeginnningX - transitionToInsetCurveWidth, 0);
    path.quadraticBezierTo(
        insetCurveBeginnningX, 0, insetCurveBeginnningX, insetRadius / 2);

    path.arcToPoint(
      Offset(insetCurveEndX, insetRadius / 2),
      radius: Radius.circular(10.0),
      clockwise: false,
    );

    path.quadraticBezierTo(
        insetCurveEndX, 0, insetCurveEndX + transitionToInsetCurveWidth, 0);
    path.quadraticBezierTo(size.width * 0.80, 0, size.width * 1.1, 12);
    path.lineTo(size.width, size.height + 56);
    path.lineTo(0, size.height + 56);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class NavBarIcon extends StatelessWidget {
  const NavBarIcon({
    Key? key,
    required this.text,
    required this.icon,
    required this.selected,
    required this.onPressed,
    this.selectedColor = const Color(0xffFF8527),
    this.defaultColor = Colors.black54,
  }) : super(key: key);

  final String text;
  final IconData icon;
  final bool selected;
  final Function() onPressed;
  final Color defaultColor;
  final Color selectedColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: onPressed,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          icon: Icon(
            icon,
            size: 25,
            color: selected ? selectedColor : defaultColor,
          ),
        ),
      ],
    );
  }
}
