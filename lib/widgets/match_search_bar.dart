import 'package:flutter/material.dart';
import 'package:sports_ticket_booking/models/sport.dart';
import '../models/match.dart';

class MatchSearchBar extends StatefulWidget {
  final List<Match> allMatches;
  final Function(String) onSearch;
  final Function(Match) onMatchSelected;

  const MatchSearchBar({
    Key? key,
    required this.allMatches,
    required this.onSearch,
    required this.onMatchSelected,
  }) : super(key: key);

  @override
  State<MatchSearchBar> createState() => _MatchSearchBarState();
}

class _MatchSearchBarState extends State<MatchSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<Match> _suggestions = [];
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _focusNode.addListener(() {
      setState(() {
        _showSuggestions = _focusNode.hasFocus && _searchController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    widget.onSearch(query);
    
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    // Generate suggestions based on team names
    final suggestions = widget.allMatches.where((match) {
      final team1 = match.team1.toLowerCase();
      final team2 = match.team2.toLowerCase();
      return team1.contains(query) || team2.contains(query);
    }).toList();

    setState(() {
      _suggestions = suggestions;
      _showSuggestions = _focusNode.hasFocus && query.isNotEmpty;
    });
  }

  void _selectMatch(Match match) {
    widget.onMatchSelected(match);
    _searchController.text = '${match.team1} vs ${match.team2}';
    setState(() {
      _showSuggestions = false;
    });
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(25),
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: 'Search for matches...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        widget.onSearch('');
                        setState(() {
                          _showSuggestions = false;
                        });
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
        if (_showSuggestions && _suggestions.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            margin: const EdgeInsets.only(top: 4),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final match = _suggestions[index];
                return ListTile(
                  leading: Icon(
                    _getSportIcon(match.sportType),
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text('${match.team1} vs ${match.team2}'),
                  subtitle: Text('${match.venue}, ${_formatDate(match.dateTime)}'),
                  onTap: () => _selectMatch(match),
                );
              },
            ),
          ),
      ],
    );
  }

  IconData _getSportIcon(SportType sportType) {
    switch (sportType) {
      case SportType.cricket:
        return Icons.sports_cricket;
      case SportType.football:
        return Icons.sports_soccer;
      case SportType.hockey:
        return Icons.sports_hockey;
      case SportType.badminton:
        return Icons.sports_tennis;
      case SportType.basketball:
        return Icons.sports_basketball;
      case SportType.tableTennis:
        return Icons.sports;
      default:
        return Icons.sports;
    }
  }

  String _formatDate(DateTime dateTime) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dateTime.day} ${months[dateTime.month - 1]}, ${dateTime.year}';
  }
}

