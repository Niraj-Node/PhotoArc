import 'package:flutter/material.dart';

void primarySnackbar(BuildContext context, String text) {
  // This should be called by an onPressed function
  // Example:
  // ElevatedButton(
  //   onPressed: () {
  //     primarySnackbar(context, "Your Text");
  //   },
  //   child: Text("Show Snackbar"),
  // );

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Color(0xff4338CA),
      content: Text(text),
      duration: Duration(milliseconds: 2500),
    ),
  );
}
