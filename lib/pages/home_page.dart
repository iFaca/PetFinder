import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:petfinder/firebase_service.dart';
import 'search_page.dart'; // Importa la clase SearchPage desde su archivo correspondiente

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
                  builder: (context) =>
                      SearchPage())); // Vincula a la página de búsqueda
            }),
            _bottomAction(FontAwesomeIcons.dog, () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => PetsPage()));
            }),
            const SizedBox(width: 48.0),
            _bottomAction(FontAwesomeIcons.user, () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => UserPage()));
            }),
            _bottomAction(Icons.settings, () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => ConfigPage()));
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
          builder: ((context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data?.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                    onDismissed: (direction) async {
                      await deletePets(snapshot.data?[index]['uid']);
                      snapshot.data?.removeAt(index);
                    },
                    confirmDismiss: (direction) async {
                      bool result = false;
                      result = await showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text(
                                  "Está seguro que quiere eliminar a ${snapshot.data?[index]['type']}?"),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      return Navigator.pop(
                                        context,
                                        false,
                                      );
                                    },
                                    child: const Text("Cancelar",
                                        style: TextStyle(color: Colors.red))),
                                TextButton(
                                    onPressed: () {
                                      return Navigator.pop(
                                        context,
                                        true,
                                      );
                                    },
                                    child: const Text("Aceptar"))
                              ],
                            );
                          });
                      return result;
                    },
                    background: Container(
                      color: Colors.red,
                      child: const Icon(Icons.delete),
                    ),
                    direction: DismissDirection.endToStart,
                    key: UniqueKey(),
                    child: ListTile(
                        title: Text(snapshot.data?[index]['name']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Especie: ${snapshot.data?[index]['type']}"),
                            Text(
                                "Ubicación: Latitud ${snapshot.data?[index]['location'].latitude}, Longitud ${snapshot.data?[index]['location'].longitude}"),
                            Text("Género: ${snapshot.data?[index]['gender']}"),
                            Text(
                              "Perdido: ${snapshot.data?[index]['lost'] ? 'Sí' : 'No'}",
                              style: TextStyle(
                                color: snapshot.data?[index]['lost']
                                    ? Colors.red
                                    : Colors.black,
                              ),
                            ),
                          ],
                        ),
                        onTap: () async {
                          await Navigator.pushNamed(context, "/edit",
                              arguments: {
                                "type": snapshot.data?[index]['type'],
                                "uid": snapshot.data?[index]['uid'],
                                "name": snapshot.data?[index]['name'],
                                "location": snapshot.data?[index]['location'],
                                "gender": snapshot.data?[index]['gender'],
                                "lost": snapshot.data?[index]['lost'],
                              });
                          setState(() {});
                        }),
                  );
                },
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          })),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, '/add');
          setState(() {});
        },
        child: const Icon(Icons.add),
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
