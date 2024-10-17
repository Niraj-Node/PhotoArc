import 'dart:io';
import 'package:intl/intl.dart';

// Helper function to get the file size in a readable format
String getFileSize(File file) {
  final bytes = file.lengthSync();
  if (bytes <= 0) return "0 B";
  const suffixes = ["B", "KB", "MB", "GB"];
  final i = (bytes.toString().length - 1) ~/ 3;
  final size = (bytes / (1 << (10 * i))).toStringAsFixed(2);
  return '$size ${suffixes[i]}';
}

// Helper function to get the date the file was last modified in AM/PM format
String getFormattedDate(File file) {
  final lastModified = file.lastModifiedSync();
  return DateFormat('yyyy-MM-dd ~ hh:mm a').format(lastModified);
}
