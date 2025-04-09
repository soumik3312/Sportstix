import 'package:flutter/material.dart';
import '../models/location.dart';

class LocationSelector extends StatelessWidget {
  final Location selectedLocation;
  final Function(Location) onLocationChanged;

  const LocationSelector({
    Key? key,
    required this.selectedLocation,
    required this.onLocationChanged,
  }) : super(key: key);

  void _showLocationPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _LocationPickerSheet(
        selectedLocation: selectedLocation,
        onLocationChanged: (location) {
          onLocationChanged(location);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get available width for the location text
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    return GestureDetector(
      onTap: () => _showLocationPicker(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.location_on,
            color: Colors.blue,
            size: 18,
          ),
          const SizedBox(width: 4), // Reduced spacing
          // Constrain the text width to prevent overflow
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: isSmallScreen ? 100 : 150, // Adjust based on screen size
              ),
              child: Text(
                selectedLocation.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isSmallScreen ? 14 : 16, // Smaller font on small screens
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis, // Add ellipsis for long text
                maxLines: 1,
              ),
            ),
          ),
          const SizedBox(width: 2), // Reduced spacing
          const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.grey,
            size: 16,
          ),
        ],
      ),
    );
  }
}

class _LocationPickerSheet extends StatefulWidget {
  final Location selectedLocation;
  final Function(Location) onLocationChanged;

  const _LocationPickerSheet({
    Key? key,
    required this.selectedLocation,
    required this.onLocationChanged,
  }) : super(key: key);

  @override
  State<_LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<_LocationPickerSheet> {
  late TextEditingController _searchController;
  List<Location> _filteredLocations = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredLocations = indianStates; // All India is already included in the list
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterLocations(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredLocations = indianStates;
      } else {
        _filteredLocations = indianStates.where((location) => 
          location.name.toLowerCase().contains(query.toLowerCase())
        ).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text(
                'Select Location',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search location',
              prefixIcon: const Icon(Icons.search, size: 20),
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            onChanged: _filterLocations,
          ),
          const SizedBox(height: 16),
          
          // Location list
          Expanded(
            child: ListView.builder(
              itemCount: _filteredLocations.length,
              itemBuilder: (context, index) {
                final location = _filteredLocations[index];
                final isSelected = widget.selectedLocation.id == location.id;
                
                return ListTile(
                  leading: Icon(
                    index == 0 ? Icons.public : Icons.location_city,
                    color: isSelected ? Colors.blue : Colors.grey,
                  ),
                  title: Text(
                    location.name,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected 
                    ? const Icon(Icons.check_circle, color: Colors.blue)
                    : null,
                  onTap: () => widget.onLocationChanged(location),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

