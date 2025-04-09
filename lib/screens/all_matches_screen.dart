import 'package:flutter/material.dart';
import '../models/match.dart';
import '../models/sport.dart';
import '../widgets/match_card.dart';
import '../screens/match_details_screen.dart';

enum MatchListType {
  featured,
  upcoming,
  all
}

class AllMatchesScreen extends StatefulWidget {
  final List<Match> matches;
  final List<Match> favoriteMatches;
  final Function(Match) onToggleFavorite;
  final MatchListType listType;
  final SportType? selectedSportType;
  final String? location;

  const AllMatchesScreen({
    Key? key,
    required this.matches,
    required this.favoriteMatches,
    required this.onToggleFavorite,
    this.listType = MatchListType.all,
    this.selectedSportType,
    this.location,
  }) : super(key: key);

  @override
  State<AllMatchesScreen> createState() => _AllMatchesScreenState();
}

class _AllMatchesScreenState extends State<AllMatchesScreen> {
  late List<Match> _filteredMatches;
  String _searchQuery = '';
  SportType? _selectedSportType;
  MatchCategory? _selectedCategory;
  bool _showLiveOnly = false;
  
  @override
  void initState() {
    super.initState();
    _selectedSportType = widget.selectedSportType;
    _filterMatches();
  }
  
  void _filterMatches() {
    // Start with all matches
    List<Match> result = List.from(widget.matches);
    
    // Apply location filter if provided
    if (widget.location != null && widget.location != 'All India') {
      result = result.where((m) => m.location == widget.location).toList();
    }
    
    // Filter by list type
    if (widget.listType == MatchListType.featured) {
      result = result.where((m) => 
        m.isLive || m.dateTime.difference(DateTime.now()).inDays < 3
      ).toList();
    } else if (widget.listType == MatchListType.upcoming) {
      result = result.where((m) => 
        m.dateTime.isAfter(DateTime.now())
      ).toList();
    }
    
    // Apply sport type filter
    if (_selectedSportType != null) {
      result = result.where((m) => m.sportType == _selectedSportType).toList();
    }
    
    // Apply category filter
    if (_selectedCategory != null) {
      result = result.where((m) => m.category == _selectedCategory).toList();
    }
    
    // Apply live filter
    if (_showLiveOnly) {
      result = result.where((m) => m.isLive).toList();
    }
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((m) => 
        m.team1.toLowerCase().contains(query) || 
        m.team2.toLowerCase().contains(query) ||
        m.venue.toLowerCase().contains(query) ||
        m.location.toLowerCase().contains(query)
      ).toList();
    }
    
    // Sort by date
    result.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    
    setState(() {
      _filteredMatches = result;
    });
  }

  void _navigateToMatchDetails(Match match) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MatchDetailsScreen(
          match: match,
          isFavorite: widget.favoriteMatches.any((m) => m.id == match.id),
          onToggleFavorite: () => widget.onToggleFavorite(match),
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    String title;
    switch (widget.listType) {
      case MatchListType.featured:
        title = 'Featured Matches';
        break;
      case MatchListType.upcoming:
        title = 'Upcoming Matches';
        break;
      case MatchListType.all:
      default:
        title = 'All Matches';
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: Icon(_showLiveOnly ? Icons.fiber_manual_record : Icons.fiber_manual_record_outlined, 
                  color: _showLiveOnly ? Colors.red : Colors.grey),
            onPressed: () {
              setState(() {
                _showLiveOnly = !_showLiveOnly;
                _filterMatches();
              });
            },
            tooltip: 'Show Live Matches',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search matches...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _filterMatches();
                });
              },
            ),
          ),
          
          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Sport type filter
                _buildFilterChip(
                  label: 'All Sports',
                  selected: _selectedSportType == null,
                  onSelected: (selected) {
                    setState(() {
                      _selectedSportType = null;
                      _filterMatches();
                    });
                  },
                ),
                ...SportType.values.map((sport) => _buildFilterChip(
                  label: getSportName(sport),
                  selected: _selectedSportType == sport,
                  onSelected: (selected) {
                    setState(() {
                      _selectedSportType = selected ? sport : null;
                      _filterMatches();
                    });
                  },
                )),
                const SizedBox(width: 16),
                
                // Category filter
                _buildFilterChip(
                  label: 'All Categories',
                  selected: _selectedCategory == null,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = null;
                      _filterMatches();
                    });
                  },
                ),
                ...MatchCategory.values.map((category) {
                  String label;
                  switch (category) {
                    case MatchCategory.national:
                      label = 'National';
                      break;
                    case MatchCategory.league:
                      label = 'League';
                      break;
                    case MatchCategory.international:
                      label = 'International';
                      break;
                  }
                  return _buildFilterChip(
                    label: label,
                    selected: _selectedCategory == category,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = selected ? category : null;
                        _filterMatches();
                      });
                    },
                  );
                }),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Match list
          Expanded(
            child: _filteredMatches.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredMatches.length,
                    itemBuilder: (context, index) {
                      final match = _filteredMatches[index];
                      final isFavorite = widget.favoriteMatches.any((m) => m.id == match.id);
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: InkWell(
                          onTap: () => _navigateToMatchDetails(match),
                          borderRadius: BorderRadius.circular(12),
                          child: MatchCard(
                            match: match,
                            isFavorite: isFavorite,
                            onToggleFavorite: () => widget.onToggleFavorite(match),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required Function(bool) onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: onSelected,
        backgroundColor: Colors.grey[200],
        selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
        checkmarkColor: Theme.of(context).primaryColor,
        labelStyle: TextStyle(
          color: selected ? Theme.of(context).primaryColor : Colors.black87,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sports_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No matches found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _selectedSportType = null;
                _selectedCategory = null;
                _showLiveOnly = false;
                _searchQuery = '';
                _filterMatches();
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reset Filters'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
  
  getSportName(SportType sport) {}
}

