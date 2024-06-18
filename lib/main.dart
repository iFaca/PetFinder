import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

//pages
import 'package:petfinder/pages/home_page.dart';
import 'package:petfinder/pages/edit_pet_page.dart';
import 'package:petfinder/pages/add_pet_page.dart';
import 'package:petfinder/pages/search_page.dart';
import 'package:petfinder/pages/login_page.dart';
import 'package:petfinder/pages/signup_page.dart';

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
        '/': (context) => AuthWrapper(),
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignupPage(),
        '/home': (context) => MyHomePage(title: 'PetFinder'),
        '/add': (context) => AddPetPage(),
        '/edit': (context) => EditPetPage(),
        '/search': (context) => SearchPage(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          return MyHomePage(title: 'PetFinder');
        }
        return LoginPage();
      },
    );
  }
}