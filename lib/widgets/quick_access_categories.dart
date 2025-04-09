import 'package:flutter/material.dart';
import '../models/sport.dart';
import '../screens/sports_screen.dart';
import '../models/location.dart';

class QuickAccessCategories extends StatelessWidget {
  const QuickAccessCategories({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildCategoryItem(
            context,
            icon: Icons.sports_cricket,
            title: 'Cricket',
            color: Colors.blue,
            onTap: () {
              _navigateToSport(context, SportType.cricket);
            },
          ),
          _buildCategoryItem(
            context,
            icon: Icons.sports_soccer,
            title: 'Football',
            color: Colors.green,
            onTap: () {
              _navigateToSport(context, SportType.football);
            },
          ),
          _buildCategoryItem(
            context,
            icon: Icons.sports_hockey,
            title: 'Hockey',
            color: Colors.orange,
            onTap: () {
              _navigateToSport(context, SportType.hockey);
            },
          ),
          _buildCategoryItem(
            context,
            icon: Icons.sports_tennis,
            title: 'Badminton',
            color: Colors.purple,
            onTap: () {
              _navigateToSport(context, SportType.badminton);
            },
          ),
          _buildCategoryItem(
            context,
            icon: Icons.sports_basketball,
            title: 'Basketball',
            color: Colors.red,
            onTap: () {
              _navigateToSport(context, SportType.basketball);
            },
          ),
          _buildCategoryItem(
            context,
            icon: Icons.table_bar,
            title: 'Table Tennis',
            color: Colors.teal,
            onTap: () {
              _navigateToSport(context, SportType.tableTennis);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToSport(BuildContext context, SportType sportType) {
    // For demo purposes, we'll use Maharashtra as the default location
    final defaultLocation = indianStates.firstWhere((state) => state.name == 'Maharashtra');
    
    // Find the sport from the sports list
    final sport = sports.firstWhere((s) => s.type == sportType);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SportsScreen(
          location: defaultLocation,
          selectedSport: sport,
        ),
      ),
    );
  }
}

