import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petfinder/firebase_service.dart';
import 'package:petfinder/pages/search_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GoogleMapController? _mapController;
  List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    _loadMarkers();
    _goToCurrentLocation(); // Llama a la función para ir a la ubicación actual al iniciar
  }

  Future<void> _requestLocationPermission() async {
    final PermissionStatus status = await Permission.location.request();
    if (status.isGranted) {
      // Permiso otorgado, puedes acceder a la ubicación
    } else {
      // Permiso denegado
    }
  }

  Future<void> _loadMarkers() async {
    final List pets = await getPets();
    final lostPets = pets
        .where((pet) => pet['lost'] == true)
        .toList(); // Filtrar solo las mascotas perdidas
    setState(() {
      _markers = lostPets
          .map<Marker>((pet) => Marker(
                markerId: MarkerId(pet['uid']),
                position:
                    LatLng(pet['location'].latitude, pet['location'].longitude),
                infoWindow: InfoWindow(
                  title: pet['name'],
                  snippet: pet['type'],
                ),
              ))
          .toList();
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
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
          children: <Widget>[
            _bottomAction(FontAwesomeIcons.search, () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => SearchPage(),
              )); // Vincula a la página de búsqueda
            }),
            _bottomAction(FontAwesomeIcons.paw, () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => PetsPage(),
              ));
            }),
            const SizedBox(width: 48.0),
            _bottomAction(FontAwesomeIcons.user, () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => UserPage(),
              ));
            }),
            _bottomAction(Icons.settings, () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ConfigPage(),
              ));
            }),
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
          Expanded(child: _maps()),
        ],
      ),
    );
  }

  Widget _maps() {
    return Container(
      height: 300,
      child: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: LatLng(0, 0),
          zoom: 12,
        ),
        markers: _markers.toSet(),
        onTap: (LatLng location) {
          _loadMarkers(); // Actualizar los marcadores cuando se toca el mapa
        },
        onCameraIdle:
            _loadMarkers, // Actualizar los marcadores cuando la cámara se detiene
      ),
    );
  }
}

class PetsPage extends StatefulWidget {
  @override
  _PetsPageState createState() => _PetsPageState();
}

class _PetsPageState extends State<PetsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Mascotas'),
      ),
      body: FutureBuilder(
        future: getPets(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final User? user = FirebaseAuth.instance.currentUser;
            final userPets = snapshot.data
                ?.where((pet) => pet['userId'] == user?.uid)
                .toList();
            return ListView.builder(
              itemCount: userPets?.length,
              itemBuilder: (context, index) {
                final pet = userPets?[index];
                final location = pet['location'] as GeoPoint;
                final petType = pet['type'];
                final gender = pet['gender'];
                final genderColor =
                    gender.toLowerCase() == 'macho' ? Colors.blue : Colors.pink;
                final isLost = pet['lost'] == true;

                return Dismissible(
                  onDismissed: (direction) async {
                    await deletePets(pet['uid']);
                    userPets?.removeAt(index);
                  },
                  confirmDismiss: (direction) async {
                    bool result = false;
                    result = await showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text(
                              "¿Está seguro que quiere eliminar a ${pet['type']}?"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                return Navigator.pop(context, false);
                              },
                              child: const Text("Cancelar",
                                  style: TextStyle(color: Colors.red)),
                            ),
                            TextButton(
                              onPressed: () {
                                return Navigator.pop(context, true);
                              },
                              child: const Text("Aceptar"),
                            ),
                          ],
                        );
                      },
                    );
                    return result;
                  },
                  background: Container(
                    color: Colors.red,
                    child: const Icon(Icons.delete),
                  ),
                  direction: DismissDirection.endToStart,
                  key: UniqueKey(),
                  child: Container(
                    color: isLost
                        ? Colors.red.withOpacity(0.1)
                        : Colors.transparent,
                    child: ListTile(
                      leading: Icon(
                        petType.toLowerCase() == 'perro'
                            ? FontAwesomeIcons.dog
                            : FontAwesomeIcons.cat,
                        color: petType.toLowerCase() == 'perro'
                            ? Colors.brown
                            : Colors.orange,
                      ),
                      title: Row(
                        children: [
                          Text(pet['name']),
                          if (isLost)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                'PERDIDA',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tipo: $petType'),
                          Text(
                            'Género: $gender',
                            style: TextStyle(color: genderColor),
                          ),
                          InkWell(
                            onTap: () {
                              _showLocationOnMap(
                                  location.latitude, location.longitude);
                            },
                            child: Text(
                              'Ubicación',
                              style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      onTap: () async {
                        await Navigator.pushNamed(context, "/edit", arguments: {
                          "type": pet['type'],
                          "uid": pet['uid'],
                          "name": pet['name'],
                          "location": pet['location'],
                          "gender": pet['gender'],
                          "lost": pet['lost'],
                          "isOwned": pet['isOwned'],
                          "reward": pet['reward'],
                          "image": pet['imagePath'],
                        });
                        setState(() {});
                      },
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, '/add');
          setState(() {});
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showLocationOnMap(double latitude, double longitude) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 300,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(latitude, longitude),
            zoom: 14.0,
          ),
          markers: {
            Marker(
              markerId: MarkerId('locationMarker'),
              position: LatLng(latitude, longitude),
            ),
          },
        ),
      ),
    );
  }
}

class UserPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Página de usuario'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (user != null) Text('Email: ${user.email}'),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.red, // Cambiar el color del botón a rojo
              ),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text('Cerrar sesión'),
            ),
          ],
        ),
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
