import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
      stream: FirebaseFirestore.instance
          .collection('pets')
          .where('lost', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        final List<DocumentSnapshot> allPets = snapshot.data!.docs;
        final List<DocumentSnapshot> filteredPets = allPets.where((pet) {
          final type = pet['type'].toString().toLowerCase();
          final name = pet['name'].toString().toLowerCase();
          final gender = pet['gender'].toString().toLowerCase();
          final query = _searchQuery.toLowerCase();
          return type.contains(query) || name.contains(query) || gender.contains(query);
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
            final reward = pet['reward'] ?? '0';
            final petType = pet['type'];
            final gender = pet['gender'];
            final genderColor = gender.toLowerCase() == 'macho' ? Colors.blue : Colors.pink;

            return ListTile(
              leading: Icon(
                petType.toLowerCase() == 'perro'
                    ? FontAwesomeIcons.dog
                    : FontAwesomeIcons.cat,
                color: petType.toLowerCase() == 'perro' ? Colors.brown : Colors.orange,
              ),
              title: Text(pet['name']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tipo: $petType'),
                  Text(
                    'Género: $gender',
                    style: TextStyle(color: genderColor),
                  ),
                  Text(
                    'Recompensa: \$${reward}',
                    style: TextStyle(color: Colors.green),
                  ),
                  InkWell(
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