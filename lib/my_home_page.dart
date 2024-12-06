import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _image;
  late GoogleMapController _mapController;
  String _selectedVisitType = "Impromptu";
  String _location = ''; // Store the entered location

  final CameraPosition _initialPosition =
      const CameraPosition(target: LatLng(5.7346, 115.9319), zoom: 12);

  final Map<String, String> _visitDescriptions = {
    "Scheduled": "Preplanned visits with a set date and time.",
    "Impromptu": "Spontaneous visits without prior planning.",
    "Recurring": "Regularly scheduled visits at fixed intervals.",
    "Ad Hoc": "Arranged on an as-needed basis.",
    "Remote": "Inspection conducted using technology.",
    "Unannounced": "Visits without prior notification.",
    "Compliance": "Ensures adherence to rules or standards.",
    "Safety": "Focus on safety measures and protocols.",
  };

  Future<void> _takePhoto() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateMapLocation(String location) async {
    try {
      List<Location> locations = await locationFromAddress(location);
      if (locations.isNotEmpty) {
        final LatLng newLocation =
            LatLng(locations.first.latitude, locations.first.longitude);
        _mapController.animateCamera(CameraUpdate.newLatLng(newLocation));
      }
    } catch (e) {
      // Handle location lookup errors
      print("Error finding location: $e");
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Widget _buildDropdown() {
    return FormBuilderDropdown<String>(
      name: 'visit_type',
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'Visit Type'),
      items: _visitDescriptions.entries.map((entry) {
        return DropdownMenuItem<String>(
          value: entry.key,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.key,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (_selectedVisitType != entry.key) ...[
                const SizedBox(height: 4),
                Text(
                  entry.value,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedVisitType = value!;
        });
      },
    );
  }

  Widget _buildTextInput({
    required IconData icon,
    required String hintText,
    required void Function(String) onChanged,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF18776F)),
        title: TextFormField(
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Color(0xFF18776F)),
            border: InputBorder.none,
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildImageAttachment() {
    return Row(
      children: [
        if (_image != null)
          Stack(
            alignment: Alignment.topLeft,
            children: [
              Image.file(
                _image!,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
              IconButton(
                icon: const Icon(Icons.cancel, color: Colors.red),
                onPressed: () {
                  setState(() {
                    _image = null;
                  });
                },
              ),
            ],
          ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: _takePhoto,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.add, size: 30, color: Color(0xFF626262)),
          ),
        ),
      ],
    );
  }

  // Show success dialog when the submit button is pressed
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Successfully submitted!'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Site Visit',
          style: TextStyle(
              fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF343434),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDropdown(),
              const SizedBox(height: 16),
              _buildTextInput(
                icon: Icons.location_pin,
                hintText: "Location",
                onChanged: (value) {
                  setState(() {
                    _location = value;
                  });
                  if (_location.isNotEmpty) {
                    _updateMapLocation(_location);
                  }
                },
              ),
              _buildTextInput(
                icon: Icons.home,
                hintText: "Address",
                onChanged: (value) {},
              ),
              _buildTextInput(
                icon: Icons.ads_click,
                hintText: "Objective",
                onChanged: (value) {},
              ),
              _buildTextInput(
                icon: Icons.notes,
                hintText: "Remark",
                onChanged: (value) {},
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: _initialPosition,
                  mapType: MapType.normal,
                ),
              ),
              const SizedBox(height: 20),
              const Row(
                children: [
                  Icon(Icons.attach_file, color: Color(0xFF626262)),
                  SizedBox(width: 8),
                  Text("Attachment:", style: TextStyle(fontSize: 16)),
                ],
              ),
              const SizedBox(height: 10),
              _buildImageAttachment(),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _showSuccessDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF43B053),
                    minimumSize: const Size(300, 50),
                  ),
                  child: const Text(
                    "Save",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
