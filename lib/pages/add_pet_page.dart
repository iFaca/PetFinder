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
  LatLng? _selectedLocation;
  String gender = "Macho";
  bool lost = false;
  bool _isLoadingLocation = true;

  final _formKey = GlobalKey<FormState>(); // Llave para el formulario

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      setState(() {
        _isLoadingLocation = false;
      });
      return;
    }

    final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _selectedLocation = LatLng(position.latitude, position.longitude);
      _isLoadingLocation = false;
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
              children: [
                TextFormField(
                  controller: typeController,
                  decoration: const InputDecoration(
                    hintText: 'Ingrese tipo mascota',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese el tipo de mascota';
                    }
                    return null;
                  },
                ),
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
                Container(
                  height: 300,
                  width: double.infinity,
                  child: _isLoadingLocation
                      ? const Center(child: CircularProgressIndicator())
                      : GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _selectedLocation ?? const LatLng(0, 0),
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
                if (_selectedLocation == null) // Mostrar error si no hay ubicación
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Por favor selecciona una ubicación en el mapa',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                DropdownButtonFormField<String>(
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor selecciona el género';
                    }
                    return null;
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
                    if (_formKey.currentState!.validate() && _selectedLocation != null) {
                      GeoPoint location = GeoPoint(
                        _selectedLocation!.latitude,
                        _selectedLocation!.longitude,
                      );
                      await addPets(
                        typeController.text,
                        nameController.text,
                        location,
                        gender,
                        lost,
                      ).then((_) {
                        Navigator.pop(context);
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Por favor completa todos los campos')),
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
