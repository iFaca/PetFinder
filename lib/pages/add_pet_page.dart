import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petfinder/firebase_service.dart';

class AddPetPage extends StatefulWidget {
  const AddPetPage({super.key});

  @override
  State<AddPetPage> createState() => _AddPetPageState();
}

class _AddPetPageState extends State<AddPetPage> {
  TextEditingController typeController = TextEditingController(text: "");
  TextEditingController nameController = TextEditingController(text: "");
  LatLng? _selectedLocation; // Variable para almacenar la ubicación seleccionada
  String gender = "Macho";
  bool lost = false;
  bool _isLoadingLocation = true; // Indicador de carga de ubicación

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      setState(() {
        _isLoadingLocation = false; // Actualizar indicador de carga
      });
      return;
    }

    final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _selectedLocation = LatLng(position.latitude, position.longitude);
      _isLoadingLocation = false; // Actualizar indicador de carga
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar mascota'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView( // Para que no haya problemas de scroll
          child: Column(
            children: [
              TextField(
                controller: typeController,
                decoration: const InputDecoration(
                  hintText: 'Ingrese tipo mascota',
                ),
              ),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: 'Ingrese nombre',
                ),
              ),
              Container(
                height: 300,
                width: double.infinity,
                child: _isLoadingLocation
                    ? const Center(child: CircularProgressIndicator()) // Indicador de carga mientras se obtiene la ubicación
                    : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _selectedLocation ?? const LatLng(0, 0), // Centrar en la ubicación obtenida
                    zoom: 14.0,
                  ),
                  onTap: (LatLng location) {
                    setState(() {
                      _selectedLocation = location;
                    });
                  },
                  markers: _selectedLocation == null
                      ? {}
                      : {
                    Marker(
                      markerId: MarkerId('selectedLocation'),
                      position: _selectedLocation!,
                    ),
                  },
                ),
              ),
              DropdownButton<String>( // Dropdown para género
                value: gender,
                items: <String>['Macho', 'Hembra'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    gender = newValue!;
                  });
                },
              ),
              Row(
                children: [
                  Checkbox(
                    value: lost,
                    onChanged: (bool? value) {
                      setState(() {
                        lost = value!;
                      });
                    },
                  ),
                  const Text('Perdido'),
                ],
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_selectedLocation != null) {
                  GeoPoint location = GeoPoint(
                  _selectedLocation!.latitude,
                  _selectedLocation!.longitude,
                  );
                  await addPets(
                    typeController.text,
                    nameController.text,
                    location,
                    gender, // Cambio
                    lost,
                  ).then((_) {
                    Navigator.pop(context);
                  });
                  } else {
                    // Manejo de error si la ubicación no está seleccionada
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Por favor selecciona una ubicación')),
                    );
                  }
                },
                child: const Text("Guardar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
