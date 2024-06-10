import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

//pages
import 'package:petfinder/pages/home_page.dart';
import 'package:petfinder/pages/edit_pet_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetFinder',
      initialRoute: '/',
      routes: {
        '/': (context) => MyHomePage(title: 'PetFinder'),
        '/add': (context) => AddPetPage(),
        '/edit': (context) => EditPetPage(),
      },
    );
  }
}
