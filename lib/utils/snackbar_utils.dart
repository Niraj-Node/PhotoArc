import 'package:flutter/material.dart';
import 'package:photoarc/widgets/snackbar/primary_snackbar.dart';
import 'package:photoarc/widgets/snackbar/error_snackbar.dart';

// Show success snackbar
void showPrimarySnackbar(BuildContext context, String message) {
  primarySnackbar(context, message);
}

// Show error snackbar
void showErrorSnackbar(BuildContext context, String message) {
  ErrorSnackbar(context, message);
}
