import 'package:flutter/material.dart';
import '../models/sport.dart';

class SportsFilter extends StatelessWidget {
  final SportType? selectedSportType;
  final Function(SportType?) onSportTypeChanged;

  const SportsFilter({
    Key? key,
    required this.selectedSportType,
    required this.onSportTypeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;
    final itemWidth = isSmallScreen ? 70.0 : screenSize.width < 600 ? 80.0 : 100.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Select Sport',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: isSmallScreen ? 90 : 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // All Sports option
              _buildSportItem(
                context,
                icon: Icons.sports,
                title: 'All Sports',
                color: Colors.purple,
                isSelected: selectedSportType == null,
                onTap: () => onSportTypeChanged(null),
                width: itemWidth,
              ),
              
              // Individual sports
              _buildSportItem(
                context,
                icon: Icons.sports_cricket,
                title: 'Cricket',
                color: Colors.blue,
                isSelected: selectedSportType == SportType.cricket,
                onTap: () => onSportTypeChanged(SportType.cricket),
                width: itemWidth,
              ),
              _buildSportItem(
                context,
                icon: Icons.sports_soccer,
                title: 'Football',
                color: Colors.green,
                isSelected: selectedSportType == SportType.football,
                onTap: () => onSportTypeChanged(SportType.football),
                width: itemWidth,
              ),
              _buildSportItem(
                context,
                icon: Icons.sports_hockey,
                title: 'Hockey',
                color: Colors.orange,
                isSelected: selectedSportType == SportType.hockey,
                onTap: () => onSportTypeChanged(SportType.hockey),
                width: itemWidth,
              ),
              _buildSportItem(
                context,
                icon: Icons.sports_tennis,
                title: 'Badminton',
                color: Colors.red,
                isSelected: selectedSportType == SportType.badminton,
                onTap: () => onSportTypeChanged(SportType.badminton),
                width: itemWidth,
              ),
              _buildSportItem(
                context,
                icon: Icons.sports_basketball,
                title: 'Basketball',
                color: Colors.deepOrange,
                isSelected: selectedSportType == SportType.basketball,
                onTap: () => onSportTypeChanged(SportType.basketball),
                width: itemWidth,
              ),
              _buildSportItem(
                context,
                icon: Icons.table_bar,
                title: 'Table Tennis',
                color: Colors.teal,
                isSelected: selectedSportType == SportType.tableTennis,
                onTap: () => onSportTypeChanged(SportType.tableTennis),
                width: itemWidth,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSportItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
    required double width,
  }) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;
    
    return Container(
      width: width,
      margin: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
              decoration: BoxDecoration(
                color: isSelected ? color : color.withOpacity(0.1),
                shape: BoxShape.circle,
                border: isSelected 
                  ? Border.all(color: color, width: 2)
                  : null,
                boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : color,
                size: isSmallScreen ? 24 : 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isSmallScreen ? 10 : 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? color : Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

