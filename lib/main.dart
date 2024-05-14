import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
//Mapas
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
//Permisos
import 'package:permission_handler/permission_handler.dart';
//Firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetFinder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'PetFinder'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class PetsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Página Mascotas'),
      ),
      body: Center(
        child: Text('Esta es la página de mascotas'),
      ),
    );
  }
}

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Página busqueda'),
      ),
      body: Center(
        child: Text('Esta es la página de busqueda'),
      ),
    );
  }
}

class UserPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Página de usuario'),
      ),
      body: Center(
        child: Text('Esta es la página de usuario'),
      ),
    );
  }
}

class ConfigPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Página config'),
      ),
      body: Center(
        child: Text('Esta es la página de config'),
      ),
    );
  }
}


class _MyHomePageState extends State<MyHomePage> {
  GoogleMapController? _mapController;

  @override
  void dispose() {
  _mapController?.dispose();
  super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _requestLocationPermission(); // Solicita permisos cuando se inicia la página
  }

  Future<void> _requestLocationPermission() async {
    final PermissionStatus status = await Permission.location.request(); // Solicita permisos de ubicación
    if (status.isGranted) {
      // Permiso otorgado, puedes acceder a la ubicación
    } else {
      // Permiso denegado, maneja este caso según tus necesidades
    }
  }

  void _onMapCreated(GoogleMapController controller) {
  setState(() {
  _mapController = controller;
  });
  }

  Widget _bottomAction(IconData icon, VoidCallback onPressed) {
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(icon),
      ),
      onTap: onPressed,
    );
  }

  Future<void> _goToCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    _mapController?.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 15.0,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        notchMargin: 8.0,
        shape: CircularNotchedRectangle(),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget> [
            _bottomAction(FontAwesomeIcons.search, () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => SearchPage()));
              },
            ),
            _bottomAction(FontAwesomeIcons.dog, () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => PetsPage()));
              },
            ),
            const SizedBox(width: 48.0),
            _bottomAction(FontAwesomeIcons.user, () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => UserPage()));
              },
            ),
            _bottomAction(Icons.settings, () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => ConfigPage()));
              },
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.map_sharp),
        onPressed: _goToCurrentLocation,
      ),
      body: _body(),
    );
  }

  Widget _body() {
    return SafeArea(
        child: Column(
          children: <Widget>[
            _title(),
            Expanded(child: _maps()),
         ],
        ),
    );
  }

  Widget _title() {
    return Column(
      children: <Widget>[
        Text("Pet"),
        Text("Finder"),
      ],
    );
  }

  Widget _maps() {
    return Container(
      height: 300, // Altura deseada del mapa
      child: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: LatLng(0, 0), // Establece la posición inicial del mapa
          zoom: 12, // Establece el nivel de zoom inicial
        ),
      ),
    );
  }

}

