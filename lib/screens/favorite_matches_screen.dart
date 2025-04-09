import 'package:flutter/material.dart';
import '../models/match.dart';
//import '../services/notification_service.dart';
import '../widgets/match_card.dart';

class FavoriteMatchesScreen extends StatefulWidget {
  final List<Match> favoriteMatches;
  final Function(Match) onToggleFavorite;

  const FavoriteMatchesScreen({
    Key? key,
    required this.favoriteMatches,
    required this.onToggleFavorite,
  }) : super(key: key);

  @override
  State<FavoriteMatchesScreen> createState() => _FavoriteMatchesScreenState();
}

class _FavoriteMatchesScreenState extends State<FavoriteMatchesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Matches'),
      ),
      body: widget.favoriteMatches.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No favorite matches yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add matches to your favorites to see them here',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.favoriteMatches.length,
              itemBuilder: (context, index) {
                final match = widget.favoriteMatches[index];
                return Column(
                  children: [
                    MatchCard(
                      match: match,
                      isFavorite: true,
                      onToggleFavorite: () => widget.onToggleFavorite(match),
                    ),
                    _buildReminderToggle(match),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildReminderToggle(Match match) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: Row(
        children: [
          const Icon(Icons.notifications, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          const Text(
            'Match Reminder',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Switch(
            value: match.hasReminder,
            onChanged: (value) {
              setState(() {
                match.hasReminder = value;
                if (value) {
                 // NotificationService.scheduleMatchReminder(match);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reminder set for 3 hours before the match'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                } else {
                  //NotificationService.cancelMatchReminder(match);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reminder cancelled'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              });
            },
          ),
        ],
      ),
    );
  }
}

