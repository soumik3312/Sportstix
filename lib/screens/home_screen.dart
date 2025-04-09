import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/match.dart';
import '../models/location.dart';
import '../models/sport.dart';
import '../services/booking_service.dart';
import '../services/auth_service.dart';
import '../widgets/sports_filter.dart';
import '../widgets/featured_matches_carousel.dart';
import '../widgets/upcoming_matches_list.dart';
import '../widgets/location_selector.dart';
import '../widgets/match_search_bar.dart';
import '../theme/app_theme.dart';
import 'favorite_matches_screen.dart';
import 'chatbot_screen.dart';
import 'games_hub_screen.dart';
import 'my_bookings_screen.dart';
import 'profile/profile_screen.dart';
import 'profile/settings/theme_settings_screen.dart';
import 'auth/login_screen.dart';
import 'booking_confirmation_screen.dart';
import 'match_details_screen.dart';
import 'all_matches_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, required initialLocation, required initialSport}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Match> _matches = generateSampleMatches();
  final List<Match> _favoriteMatches = [];
  late Location _selectedLocation;
  SportType? _selectedSportType;
  int _currentNavIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;
  String _searchQuery = '';
  List<Match> _searchResults = [];

  @override
  void initState() {
    super.initState();
    
    // Set system UI overlay style for a more immersive experience
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    
    // Initialize with default location and load saved location
    _selectedLocation = indianStates[0]; // Default to "All India"
    _loadSavedLocation();
  }

  // Load the saved location from SharedPreferences
  Future<void> _loadSavedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLocationId = prefs.getString('selectedLocationId');
      
      if (savedLocationId != null) {
        final location = indianStates.firstWhere(
          (loc) => loc.id == savedLocationId,
          orElse: () => indianStates[0], // Default to "All India" if not found
        );
        
        setState(() {
          _selectedLocation = location;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading saved location: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Save the selected location to SharedPreferences
  Future<void> _saveLocation(Location location) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selectedLocationId', location.id);
    } catch (e) {
      print('Error saving location: $e');
    }
  }

  void _toggleFavorite(Match match) {
    setState(() {
      if (_favoriteMatches.any((m) => m.id == match.id)) {
        _favoriteMatches.removeWhere((m) => m.id == match.id);
        //NotificationService.cancelMatchReminder(match);
        match.hasReminder = false;
      } else {
        _favoriteMatches.add(match);
        _showReminderDialog(match);
      }
    });
  }

  void _showReminderDialog(Match match) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Reminder'),
        content: const Text('Would you like to set a reminder for this match?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                match.hasReminder = true;
                //NotificationService.scheduleMatchReminder(match);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Reminder set for 3 hours before the match'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  void _onLocationChanged(Location location) {
    setState(() {
      _selectedLocation = location;
    });
    _saveLocation(location); // Save the selected location
  }

  void _onSportTypeChanged(SportType? sportType) {
    setState(() {
      _selectedSportType = sportType;
    });
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _searchResults = [];
      } else {
        _searchResults = _matches.where((match) {
          final team1 = match.team1.toLowerCase();
          final team2 = match.team2.toLowerCase();
          final venue = match.venue.toLowerCase();
          return team1.contains(query.toLowerCase()) || 
                 team2.contains(query.toLowerCase()) ||
                 venue.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _onMatchSelected(Match match) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MatchDetailsScreen(
          match: match,
          isFavorite: _favoriteMatches.any((m) => m.id == match.id),
          onToggleFavorite: () => _toggleFavorite(match),
        ),
      ),
    );
  }

  void _navigateToAllMatches({required MatchListType listType}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AllMatchesScreen(
          matches: _matches,
          favoriteMatches: _favoriteMatches,
          onToggleFavorite: _toggleFavorite,
          listType: listType,
          selectedSportType: _selectedSportType,
          location: _selectedLocation.name,
        ),
      ),
    );
  }

  List<Match> get _filteredMatches {
    if (_searchQuery.isNotEmpty) {
      return _searchResults.where((match) => 
        (match.location == _selectedLocation.name || _selectedLocation.name == 'All India') &&
        (_selectedSportType == null || match.sportType == _selectedSportType)
      ).toList();
    }
    
    return _matches.where((match) => 
      (match.location == _selectedLocation.name || _selectedLocation.name == 'All India') &&
      (_selectedSportType == null || match.sportType == _selectedSportType)
    ).toList();
  }

  List<Match> get _featuredMatches {
    return _filteredMatches.where((match) => match.isFeatured).toList();
  }

  void _onNavItemTapped(int index) {
    if (index == _currentNavIndex) return;
    
    setState(() {
      _currentNavIndex = index;
    });
    
    switch (index) {
      case 0: // Home - already here
        break;
      case 1: // Games
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const GamesHubScreen(),
          ),
        ).then((_) => setState(() => _currentNavIndex = 0));
        break;
      case 2: // Chatbot
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ChatbotScreen(),
          ),
        ).then((_) => setState(() => _currentNavIndex = 0));
        break;
      case 3: // Profile
        final authService = Provider.of<AuthService>(context, listen: false);
        if (authService.isAuthenticated) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProfileScreen(),
            ),
          ).then((_) => setState(() => _currentNavIndex = 0));
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
          ).then((_) => setState(() => _currentNavIndex = 0));
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
          ),
        ),
      );
    }
    
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App bar with location selector - fixed to prevent overflow
            SliverAppBar(
              floating: true,
              pinned: false,
              backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
              elevation: 0,
              toolbarHeight: 56, // Standard height
              leading: IconButton(
                icon: Icon(
                  Icons.menu, 
                  color: Theme.of(context).appBarTheme.foregroundColor,
                ),
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
              ),
              title: LocationSelector(
                selectedLocation: _selectedLocation,
                onLocationChanged: _onLocationChanged,
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.favorite, 
                    color: Colors.red,
                  ),
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
                if (!isSmallScreen) // Hide some icons on small screens
                  IconButton(
                    icon: Stack(
                      children: [
                        Icon(
                          Icons.confirmation_number_outlined, 
                          color: Theme.of(context).iconTheme.color,
                        ),
                        Consumer<BookingService>(
                          builder: (context, bookingService, child) {
                            final upcomingBookings = bookingService.bookings.where((booking) => 
                              booking.match.dateTime.isAfter(DateTime.now())
                            ).length;
                            
                            if (upcomingBookings > 0) {
                              return Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: Text(
                                    '$upcomingBookings',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyBookingsScreen(),
                        ),
                      );
                    },
                  ),
                IconButton(
                  icon: Icon(
                    Icons.person, 
                    color: Theme.of(context).iconTheme.color,
                  ),
                  onPressed: () {
                    if (authService.isAuthenticated) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: MatchSearchBar(
                  allMatches: _matches,
                  onSearch: _onSearch,
                  onMatchSelected: _onMatchSelected,
                ),
              ),
            ),
            
            // Sports filter
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: SportsFilter(
                  selectedSportType: _selectedSportType,
                  onSportTypeChanged: _onSportTypeChanged,
                ),
              ),
            ),
            
            // Content sections
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Featured matches carousel
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Featured Matches',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.titleLarge?.color,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            _navigateToAllMatches(listType: MatchListType.featured);
                          },
                          child: Text(
                            'See All',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Make carousel height responsive
                  SizedBox(
                    height: screenSize.height * 0.28, // Responsive height
                    child: FeaturedMatchesCarousel(
                      matches: _featuredMatches.isNotEmpty 
                          ? _featuredMatches 
                          : _filteredMatches.where((m) => 
                              m.isLive || m.dateTime.difference(DateTime.now()).inDays < 3
                            ).toList(),
                      onToggleFavorite: _toggleFavorite,
                      favoriteMatches: _favoriteMatches,
                    ),
                  ),
                  
                  // Upcoming matches
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Upcoming Matches',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.titleLarge?.color,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            _navigateToAllMatches(listType: MatchListType.upcoming);
                          },
                          child: Text(
                            'View All',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  UpcomingMatchesList(
                    matches: _filteredMatches,
                    favoriteMatches: _favoriteMatches,
                    onToggleFavorite: _toggleFavorite,
                  ),
                  
                  // My Bookings Section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'My Bookings',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.titleLarge?.color,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MyBookingsScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'View All',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildRecentBookings(),
                  
                  // Bottom padding for floating action button
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
      drawer: _buildDrawer(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildRecentBookings() {
    return Consumer<BookingService>(
      builder: (context, bookingService, child) {
        if (bookingService.isLoading) {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
          );
        }
        
        final upcomingBookings = bookingService.bookings
          .where((booking) => booking.match.dateTime.isAfter(DateTime.now()))
          .take(2)
          .toList();
        
        if (upcomingBookings.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.confirmation_number_outlined,
                      size: 48,
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.grey[600] 
                          : Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No upcoming bookings',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Book tickets for upcoming matches to see them here',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Scroll to featured matches
                      },
                      child: const Text('Browse Matches'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        
        return Column(
          children: upcomingBookings.map((booking) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingConfirmationScreen(booking: booking),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark 
                              ? Colors.blue.shade800 
                              : Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.confirmation_number,
                          size: 30,
                          color: Theme.of(context).brightness == Brightness.dark 
                              ? Colors.blue.shade200 
                              : Colors.blue.shade700,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking.match.matchTitle,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Theme.of(context).textTheme.titleMedium?.color,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_formatDate(booking.match.dateTime)} at ${_formatTime(booking.match.dateTime)}',
                              style: TextStyle(
                                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${booking.selectedSeats.length} tickets • ${booking.selectedSeats.map((s) => s.seatLabel).join(', ')}',
                              style: TextStyle(
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.grey[400] 
                            : Colors.grey[600],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )).toList(),
        );
      },
    );
  }

  Widget _buildDrawer() {
    final authService = Provider.of<AuthService>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  isDarkMode ? Colors.blue.shade900 : Colors.blue.shade700,
                  isDarkMode ? Colors.blue.shade800 : Colors.blue.shade500,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (authService.isAuthenticated) ...[
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Text(
                      authService.currentUser!.name.isNotEmpty 
                          ? authService.currentUser!.name[0].toUpperCase() 
                          : '?',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    authService.currentUser!.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    authService.currentUser!.email,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ] else ...[
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.sports,
                      size: 30,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Sports Ticket Booking',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Book tickets for your favorite sports',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Favorites'),
            onTap: () {
              Navigator.pop(context);
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
          ListTile(
            leading: const Icon(Icons.confirmation_number),
            title: const Text('My Bookings'),
            trailing: Consumer<BookingService>(
              builder: (context, bookingService, child) {
                final upcomingBookings = bookingService.bookings.where((booking) => 
                  booking.match.dateTime.isAfter(DateTime.now())
                ).length;
                
                if (upcomingBookings > 0) {
                  return Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$upcomingBookings',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyBookingsScreen(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.sports_esports),
            title: const Text('Mini Games'),
            subtitle: const Text('Play & win rewards'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GamesHubScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.chat),
            title: const Text('Chat Assistant'),
            subtitle: const Text('Get help with booking and more'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChatbotScreen(),
                ),
              );
            },
          ),
          const Divider(),
          if (authService.isAuthenticated) ...[
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign Out'),
              onTap: () async {
                Navigator.pop(context);
                await authService.signOut();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Signed out successfully'),
                    ),
                  );
                }
              },
            ),
          ] else ...[
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Sign In'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              },
            ),
          ],
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Theme Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ThemeSettingsScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context);
              // Show about dialog
              showAboutDialog(
                context: context,
                applicationName: 'Sports Ticket Booking',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(
                  Icons.sports,
                  size: 50,
                  color: Colors.blue,
                ),
                children: [
                  const Text(
                    'A comprehensive sports ticket booking application with features like 3D stadium view, match reminders, mini-games, and chatbot assistance.',
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentNavIndex,
      onTap: _onNavItemTapped,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Theme.of(context).brightness == Brightness.dark 
          ? Colors.grey[400] 
          : Colors.grey[600],
      backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.sports_esports),
          label: 'Games',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: 'Chat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
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
}

