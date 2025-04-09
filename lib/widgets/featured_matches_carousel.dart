import 'package:flutter/material.dart';
import 'package:sports_ticket_booking/models/sport.dart';
import '../models/match.dart';
import '../screens/match_details_screen.dart';

class FeaturedMatchesCarousel extends StatefulWidget {
  final List<Match> matches;
  final List<Match> favoriteMatches;
  final Function(Match) onToggleFavorite;

  const FeaturedMatchesCarousel({
    Key? key,
    required this.matches,
    required this.favoriteMatches,
    required this.onToggleFavorite,
  }) : super(key: key);

  @override
  State<FeaturedMatchesCarousel> createState() => _FeaturedMatchesCarouselState();
}

class _FeaturedMatchesCarouselState extends State<FeaturedMatchesCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      int next = _pageController.page!.round();
      if (_currentPage != next) {
        setState(() {
          _currentPage = next;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final cardWidth = screenSize.width < 600 
        ? screenSize.width * 0.85 
        : 500.0; // Limit card width on larger screens
    
    if (widget.matches.isEmpty) {
      return Container(
        height: screenSize.height * 0.25,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.grey[100]
              : Colors.grey[800],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.sports_outlined,
                size: 48,
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.grey[400]
                    : Colors.grey[600],
              ),
              const SizedBox(height: 16),
              Text(
                'No featured matches available',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.grey[600]
                      : Colors.grey[400],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: screenSize.height * 0.25, // Responsive height
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.matches.length,
            itemBuilder: (context, index) {
              final match = widget.matches[index];
              final isFavorite = widget.favoriteMatches.any((m) => m.id == match.id);
              
              return _buildFeaturedMatchCard(match, isFavorite, index, cardWidth);
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.matches.length,
            (index) => _buildIndicator(index == _currentPage),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedMatchCard(Match match, bool isFavorite, int index, double cardWidth) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MatchDetailsScreen(
              match: match,
              isFavorite: isFavorite,
              onToggleFavorite: () => widget.onToggleFavorite(match),
            ),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: cardWidth,
        margin: EdgeInsets.symmetric(
          horizontal: 8,
          vertical: _currentPage == index ? 8 : 16,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: match.isLive
                ? [Colors.red.shade700, Colors.red.shade900]
                : [
                    _getSportColor(match.sportType).withOpacity(0.8),
                    _getSportColor(match.sportType),
                  ],
          ),
        ),
        child: Stack(
          children: [
            // Sport icon watermark
            Positioned(
              right: -20,
              bottom: -20,
              child: Opacity(
                opacity: 0.1,
                child: Icon(
                  _getSportIcon(match.sportType),
                  size: 120,
                  color: Colors.white,
                ),
              ),
            ),
            
            // Content with responsive text sizes
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (match.isLive)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.fiber_manual_record, color: Colors.white, size: 12),
                              SizedBox(width: 4),
                              Text(
                                'LIVE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            match.categoryName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: Colors.white,
                        ),
                        onPressed: () => widget.onToggleFavorite(match),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    match.matchTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.white, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        '${_formatDate(match.dateTime)} at ${_formatTime(match.dateTime)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.white, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          match.venue,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 12 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? Theme.of(context).primaryColor : Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dateTime.day} ${months[dateTime.month - 1]}, ${dateTime.year}';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  Color _getSportColor(SportType sportType) {
    switch (sportType) {
      case SportType.cricket:
        return Colors.blue;
      case SportType.football:
        return Colors.green;
      case SportType.hockey:
        return Colors.orange;
      case SportType.badminton:
        return Colors.purple;
      case SportType.tableTennis:
        return Colors.teal;
      case SportType.basketball:
        return Colors.deepOrange;
      default:
        return Colors.blue;
    }
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
      case SportType.tableTennis:
        return Icons.table_bar;
      case SportType.basketball:
        return Icons.sports_basketball;
      default:
        return Icons.sports;
    }
  }
}

