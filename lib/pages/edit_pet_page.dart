import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petfinder/firebase_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EditPetPage extends StatefulWidget {
  const EditPetPage({super.key});

  @override
  State<EditPetPage> createState() => _EditPetPageState();
}

class _EditPetPageState extends State<EditPetPage> {
  TextEditingController nameController = TextEditingController(text: "");
  String gender = "Macho";
  bool lost = false;
  bool _isInitialized = false;
  LatLng? _selectedLocation;
  late String uid;
  String _selectedIsOwned = 'Sí';
  File? _image;
  String? imageUrl;
  String petType = "Perro";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;

      uid = arguments['uid'];
      petType = arguments['type'];
      nameController.text = arguments['name'];
      gender = arguments['gender'] ?? 'Macho';
      lost = arguments['lost'] ?? false;
      _selectedLocation = LatLng(
        arguments['location'].latitude,
        arguments['location'].longitude,
      );
      _selectedIsOwned = arguments['isOwned'] ?? 'Sí';
      imageUrl = arguments['image'];

      _isInitialized = true;
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar mascota'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: Form(
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
                                color: petType == 'Perro' ? Colors.green : Colors.grey,
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    petType = 'Gato';
                                  });
                                },
                                icon: Icon(FontAwesomeIcons.cat),
                                color: petType == 'Gato' ? Colors.green : Colors.grey,
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
                                color: gender == 'Macho' ? Colors.blue : Colors.grey,
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    gender = 'Hembra';
                                  });
                                },
                                icon: Icon(FontAwesomeIcons.venus),
                                color: gender == 'Hembra' ? Colors.pink : Colors.grey,
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
                            value: _selectedIsOwned,
                            items: <String>['Sí', 'No'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedIsOwned = newValue!;
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
                                  style: TextStyle(color: value ? Colors.red : Colors.black),
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
                const SizedBox(height: 10),
                const Text('Foto de la mascota:'),
                _image == null
                    ? (imageUrl != null
                    ? Image.network(imageUrl!, height: 200)
                    : Text('No se ha seleccionado una imagen.'))
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
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _selectedLocation ?? LatLng(0, 0),
                      zoom: 11,
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
                    if (_selectedLocation != null &&
                        petType.isNotEmpty &&
                        gender.isNotEmpty) {
                      GeoPoint location = GeoPoint(
                        _selectedLocation!.latitude,
                        _selectedLocation!.longitude,
                      );

                      await updatePets(
                        uid,
                        petType,
                        nameController.text,
                        location,
                        gender,
                        lost,
                        _selectedIsOwned,
                        _image?.path ?? imageUrl ?? '',
                      ).then((_) {
                        Navigator.pop(context);
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Por favor completa todos los campos')),
                      );
                    }
                  },
                  child: const Text("Actualizar"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}