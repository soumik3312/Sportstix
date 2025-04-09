import 'package:flutter/material.dart';
import '../models/match.dart';
import '../widgets/match_card.dart';
import '../screens/match_details_screen.dart';

class UpcomingMatchesList extends StatelessWidget {
  final List<Match> matches;
  final List<Match> favoriteMatches;
  final Function(Match) onToggleFavorite;

  const UpcomingMatchesList({
    Key? key,
    required this.matches,
    required this.favoriteMatches,
    required this.onToggleFavorite,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sort matches by date
    final sortedMatches = List<Match>.from(matches)
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    
    // Take only upcoming matches
    final upcomingMatches = sortedMatches
      .where((match) => match.dateTime.isAfter(DateTime.now()))
      .take(5)
      .toList();
    
    if (upcomingMatches.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(
                Icons.event_busy,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              const Text(
                'No upcoming matches found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try changing your location or sport filter',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: upcomingMatches.length,
      itemBuilder: (context, index) {
        final match = upcomingMatches[index];
        final isFavorite = favoriteMatches.any((m) => m.id == match.id);
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MatchDetailsScreen(
                    match: match,
                    isFavorite: isFavorite,
                    onToggleFavorite: () => onToggleFavorite(match),
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: MatchCard(
              match: match,
              isFavorite: isFavorite,
              onToggleFavorite: () => onToggleFavorite(match),
            ),
          ),
        );
      },
    );
  }
}

