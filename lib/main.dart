import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
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

  Widget _bottomAction(IconData icon) {
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(icon),
      ),
      onTap: () {},
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
            _bottomAction(FontAwesomeIcons.search),
            _bottomAction(FontAwesomeIcons.dog),
            const SizedBox(width: 48.0),
            _bottomAction(FontAwesomeIcons.user),
            _bottomAction(Icons.settings),
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
        markers: _createMarkers(), // Agrega marcadores al mapa
      ),
    );
  }

  Set<Marker> _createMarkers() {
    return <Marker>{
      Marker(
        markerId: MarkerId('mascota-1'), // Identificador único del marcador
        position: LatLng(0, 0), // Posición del marcador en coordenadas (latitud, longitud)
        infoWindow: InfoWindow(
          title: 'Mascota perdida', // Título del infoWindow
          snippet: 'Descripción de la mascota', // Descripción adicional del infoWindow
        ),
      ),
      // Agrega más marcadores según sea necesario
    };
  }

}

