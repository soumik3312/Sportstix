import 'package:flutter/material.dart';

enum SportType {
  football,
  hockey,
  cricket,
  badminton,
  tableTennis,
  basketball
}

class Sport {
  final String id;
  final String name;
  final SportType type;
  final IconData icon;
  final String imagePath;

  Sport({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.imagePath,
  });
}

final List<Sport> sports = [
  Sport(
    id: '1',
    name: 'Football',
    type: SportType.football,
    icon: Icons.sports_soccer,
    imagePath: 'assets/images/football.jpg',
  ),
  Sport(
    id: '2',
    name: 'Hockey',
    type: SportType.hockey,
    icon: Icons.sports_hockey,
    imagePath: 'assets/images/hockey.jpg',
  ),
  Sport(
    id: '3',
    name: 'Cricket',
    type: SportType.cricket,
    icon: Icons.sports_cricket,
    imagePath: 'assets/images/cricket.jpg',
  ),
  Sport(
    id: '4',
    name: 'Badminton',
    type: SportType.badminton,
    icon: Icons.sports_tennis,
    imagePath: 'assets/images/badminton.jpg',
  ),
  Sport(
    id: '5',
    name: 'Table Tennis',
    type: SportType.tableTennis,
    icon: Icons.table_bar,
    imagePath: 'assets/images/table_tennis.jpg',
  ),
  Sport(
    id: '6',
    name: 'Basketball',
    type: SportType.basketball,
    icon: Icons.sports_basketball,
    imagePath: 'assets/images/basketball.jpg',
  ),
];

bool isIndoorSport(SportType type) {
  return type == SportType.badminton || 
         type == SportType.tableTennis || 
         type == SportType.basketball;
}

