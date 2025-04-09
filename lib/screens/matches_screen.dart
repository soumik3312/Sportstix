import 'package:flutter/material.dart';
import '../models/location.dart';
import '../models/match.dart';
import '../models/sport.dart';
import '../widgets/match_card.dart';
import 'favorite_matches_screen.dart';

class MatchesScreen extends StatefulWidget {
  final Location location;
  final Sport sport;

  const MatchesScreen({
    Key? key,
    required this.location,
    required this.sport,
  }) : super(key: key);

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<Match> _matches;
  late List<Match> _favoriteMatches;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _matches = generateSampleMatches().where((match) => 
      match.sportType == widget.sport.type && 
      match.location == widget.location.name
    ).toList();
    
    // If no matches found for the specific location, show all matches for the sport
    if (_matches.isEmpty) {
      _matches = generateSampleMatches().where((match) => 
        match.sportType == widget.sport.type
      ).toList();
    }
    
    _favoriteMatches = [];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleFavorite(Match match) {
    setState(() {
      if (_favoriteMatches.any((m) => m.id == match.id)) {
        _favoriteMatches.removeWhere((m) => m.id == match.id);
      } else {
        _favoriteMatches.add(match);
      }
    });
  }

  List<Match> _getFilteredMatches(MatchCategory? category) {
    if (category == null) {
      return _matches;
    }
    return _matches.where((match) => match.category == category).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.sport.name} Matches'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FavoriteMatchesScreen(
                    favoriteMatches: _favoriteMatches,
                    onToggleFavorite: _toggleFavorite,
                  ),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'National'),
            Tab(text: 'League'),
            Tab(text: 'International'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMatchesList(null),
          _buildMatchesList(MatchCategory.national),
          _buildMatchesList(MatchCategory.league),
          _buildMatchesList(MatchCategory.international),
        ],
      ),
    );
  }

  Widget _buildMatchesList(MatchCategory? category) {
    final filteredMatches = _getFilteredMatches(category);
    
    if (filteredMatches.isEmpty) {
      return const Center(
        child: Text(
          'No matches available',
          style: TextStyle(fontSize: 16),
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredMatches.length,
      itemBuilder: (context, index) {
        final match = filteredMatches[index];
        final isFavorite = _favoriteMatches.any((m) => m.id == match.id);
        
        return MatchCard(
          match: match,
          isFavorite: isFavorite,
          onToggleFavorite: () => _toggleFavorite(match),
        );
      },
    );
  }
}

