import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late TextEditingController _searchController;
  late String _searchQuery;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchQuery = '';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildSearchResults() {
    if (_searchQuery.isEmpty) {
      return Center(
        child: Text('Escribe algo para buscar'),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _searchQuery.isNotEmpty
          ? FirebaseFirestore.instance
          .collection('pets')
          .snapshots()
          : FirebaseFirestore.instance.collection('pets').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        final List<DocumentSnapshot> allPets = snapshot.data!.docs;
        final List<DocumentSnapshot> filteredPets = allPets.where((pet) {
          final type = pet['type'].toString().toLowerCase();
          return type.contains(_searchQuery.toLowerCase());
        }).toList();

        if (filteredPets.isEmpty) {
          return Center(
            child: Text('No se encontraron resultados'),
          );
        }

        return ListView.builder(
          itemCount: filteredPets.length,
          itemBuilder: (context, index) {
            final pet = filteredPets[index];
            final location = pet['location'] as GeoPoint;
            return ListTile(
              title: Text(pet['name']),
              subtitle: InkWell(
                onTap: () {
                  _showLocationOnMap(location.latitude, location.longitude);
                },
                child: Row(
                  children: [
                    Text('Tipo: ${pet['type']} - '),
                    GestureDetector(
                      onTap: () {
                        _showLocationOnMap(location.latitude, location.longitude);
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
              ),
            );
          },
        );
      },
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buscar Mascotas'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Buscar mascotas...',
              ),
            ),
          ),
          Expanded(
            child: _buildSearchResults(),
          ),
        ],
      ),
    );
  }
}