import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petfinder/firebase_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AddPetPage extends StatefulWidget {
  const AddPetPage({Key? key}) : super(key: key);

  @override
  State<AddPetPage> createState() => _AddPetPageState();
}

class _AddPetPageState extends State<AddPetPage> {
  TextEditingController nameController = TextEditingController(text: "");
  TextEditingController rewardController = TextEditingController(text: "");
  LatLng? _selectedLocation;
  String gender = "Macho";
  bool lost = false;
  bool _isLoadingLocation = true;
  late CameraPosition _initialCameraPosition;
  List<Marker> _markers = [];
  File? _image;
  String isOwned = "No";
  String petType = "Perro";

  final _formKey = GlobalKey<FormState>(); // Llave para el formulario
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      setState(() {
        _isLoadingLocation = false;
      });
      return;
    }

    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _selectedLocation = LatLng(position.latitude, position.longitude);
      _initialCameraPosition = CameraPosition(
        target: _selectedLocation!,
        zoom: 14.0,
      );
      _isLoadingLocation = false;
    });

    // Agrega el marcador de la ubicación actual
    _addCurrentLocationMarker();
  }

  void _addCurrentLocationMarker() {
    setState(() {
      _markers.clear(); // Limpia los marcadores anteriores
      _markers.add(
        Marker(
          markerId: const MarkerId('currentLocation'),
          position: _selectedLocation!,
          infoWindow: const InfoWindow(title: 'Mi ubicación'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
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
        child: SingleChildScrollView(
          child: Form(
            key: _formKey, // Asignar la llave del formulario
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tipo de mascota:'),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    petType = 'Perro';
                                  });
                                },
                                icon: Icon(FontAwesomeIcons.dog),
                                color: petType == 'Perro'
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    petType = 'Gato';
                                  });
                                },
                                icon: Icon(FontAwesomeIcons.cat),
                                color: petType == 'Gato'
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                            ],
                          ),
                          if (petType.isEmpty)
                            const Text(
                              'Por favor selecciona el tipo de mascota',
                              style: TextStyle(color: Colors.red),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Género:'),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    gender = 'Macho';
                                  });
                                },
                                icon: Icon(FontAwesomeIcons.mars),
                                color: gender == 'Macho'
                                    ? Colors.blue
                                    : Colors.grey,
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    gender = 'Hembra';
                                  });
                                },
                                icon: Icon(FontAwesomeIcons.venus),
                                color: gender == 'Hembra'
                                    ? Colors.pink
                                    : Colors.grey,
                              ),
                            ],
                          ),
                          if (gender.isEmpty)
                            const Text(
                              'Por favor selecciona el género de la mascota',
                              style: TextStyle(color: Colors.red),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('¿Es tu mascota?'),
                          DropdownButtonFormField<String>(
                            value: isOwned,
                            items: <String>['Sí', 'No'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                isOwned = newValue!;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('¿Está perdida?'),
                          DropdownButtonFormField<bool>(
                            value: lost,
                            items: <bool>[true, false].map((bool value) {
                              return DropdownMenuItem<bool>(
                                value: value,
                                child: Text(
                                  value ? 'Sí' : 'No',
                                  style: TextStyle(
                                      color: value ? Colors.red : Colors.black),
                                ),
                              );
                            }).toList(),
                            onChanged: (bool? newValue) {
                              setState(() {
                                lost = newValue!;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (isOwned == 'Sí' && lost == true)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      const Text('Recompensa:'),
                      TextFormField(
                        controller: rewardController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: '\$0',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese una recompensa';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                const SizedBox(height: 10),
                const Text('Foto de la mascota:'),
                _image == null
                    ? const Text('No se ha seleccionado una imagen.')
                    : Image.file(_image!, height: 200),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text('Seleccionar imagen'),
                ),
                const SizedBox(height: 10),
                const Text('Elije la última ubicación de la mascota:'),
                Container(
                  height: 300,
                  width: double.infinity,
                  child: _isLoadingLocation
                      ? const Center(child: CircularProgressIndicator())
                      : GoogleMap(
                          initialCameraPosition: _initialCameraPosition,
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
                if (_selectedLocation ==
                    null) // Mostrar error si no hay ubicación
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Por favor selecciona una ubicación en el mapa',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    hintText: 'Ingrese nombre',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese el nombre de la mascota';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate() &&
                        _selectedLocation != null &&
                        petType.isNotEmpty &&
                        gender.isNotEmpty) {
                      GeoPoint location = GeoPoint(
                        _selectedLocation!.latitude,
                        _selectedLocation!.longitude,
                      );

                      await addPets(
                        petType,
                        nameController.text,
                        location,
                        gender,
                        lost,
                        isOwned,
                        _image?.path ?? '',
                        isOwned == 'Sí' && lost == true
                            ? rewardController.text
                            : '0',
                      ).then((_) {
                        Navigator.pop(context);
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Por favor completa todos los campos')),
                      );
                    }
                  },
                  child: const Text("Guardar"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
