import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:photoarc/config/firebase_options.dart'; // Import the generated Firebase options file
import 'package:photoarc/utils/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const PhotoArc());
}

class PhotoArc extends StatelessWidget {
  const PhotoArc({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PhotoArc',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      initialRoute: Routes.home,
      routes: Routes.getRoutes(),
    );
  }
}