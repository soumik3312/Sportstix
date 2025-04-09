import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../services/auth_service.dart';
import '../../services/booking_service.dart';
import '../../models/user.dart';
import '../auth/login_screen.dart';
import 'edit_profile_screen.dart';
import 'settings/notifications_settings_screen.dart';
import 'settings/language_settings_screen.dart';
import 'settings/security_settings_screen.dart';
import 'settings/help_support_screen.dart';
import '../../theme/app_theme.dart';
// Add the import for the theme settings screen
import 'settings/theme_settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final bookingService = Provider.of<BookingService>(context);
    
    if (authService.currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Please sign in to view your profile',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                child: const Text('Sign In'),
              ),
            ],
          ),
        ),
      );
    }
    
    final user = authService.currentUser!;
    final upcomingBookings = bookingService.bookings.where((booking) => 
      booking.match.dateTime.isAfter(DateTime.now())
    ).length;
    
    final pastBookings = bookingService.bookings.where((booking) => 
      booking.match.dateTime.isBefore(DateTime.now())
    ).length;
    
    // Update the profile screen to be responsive
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;
    final responsivePadding = AppTheme.getResponsivePadding(context);
    
    // Responsive layout for stats cards
    Widget buildStatsSection() {
      if (screenSize.width < 600) {
        // Mobile layout - row with 3 cards
        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                title: 'Upcoming',
                value: upcomingBookings.toString(),
                icon: Icons.event,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                context,
                title: 'Past',
                value: pastBookings.toString(),
                icon: Icons.history,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                context,
                title: 'Total',
                value: (upcomingBookings + pastBookings).toString(),
                icon: Icons.confirmation_number,
                color: Colors.purple,
              ),
            ),
          ],
        );
      } else {
        // Tablet/Desktop layout - grid with more space
        return GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildStatCard(
              context,
              title: 'Upcoming',
              value: upcomingBookings.toString(),
              icon: Icons.event,
              color: Colors.blue,
              isLarge: true,
            ),
            _buildStatCard(
              context,
              title: 'Past',
              value: pastBookings.toString(),
              icon: Icons.history,
              color: Colors.green,
              isLarge: true,
            ),
            _buildStatCard(
              context,
              title: 'Total',
              value: (upcomingBookings + pastBookings).toString(),
              icon: Icons.confirmation_number,
              color: Colors.purple,
              isLarge: true,
            ),
          ],
        );
      }
    }
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with profile header
          SliverAppBar(
            expandedHeight: screenSize.height * 0.25, // Responsive height
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.blue.shade700,
                      Colors.blue.shade900,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: user.profileImagePath != null
                              ? FileImage(File(user.profileImagePath!))
                              : null,
                          child: user.profileImagePath == null
                              ? Text(
                                  user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          user.name,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 18 : 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          user.email,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 12 : 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          
          // Profile content
          SliverToBoxAdapter(
            child: Padding(
              padding: responsivePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats cards
                  buildStatsSection(),
                  
                  SizedBox(height: AppTheme.getResponsiveSpacing(context, factor: 1.5)),
                  
                  // Personal information
                  Text(
                    'Personal Information',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  SizedBox(height: AppTheme.getResponsiveSpacing(context)),
                  
                  _buildInfoCard(
                    context,
                    user: user,
                    onEdit: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfileScreen(),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Account settings
                  const Text(
                    'Account Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSettingsCard(context),
                  
                  const SizedBox(height: 24),
                  
                  // Sign out button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await authService.signOut();
                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                            (route) => false,
                          );
                        }
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Sign Out'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(User user) {
    if (user.profileImagePath != null) {
      return CircleAvatar(
        radius: 50,
        backgroundImage: FileImage(File(user.profileImagePath!)),
      );
    } else {
      return CircleAvatar(
        radius: 50,
        backgroundColor: Colors.white,
        child: Text(
          user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      );
    }
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    bool isLarge = false,
  }) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;
    
    return Container(
      padding: EdgeInsets.all(isLarge ? 24 : (isSmallScreen ? 12 : 16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(isLarge ? 12 : (isSmallScreen ? 6 : 8)),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: isLarge ? 32 : (isSmallScreen ? 20 : 24),
            ),
          ),
          SizedBox(height: isLarge ? 16 : (isSmallScreen ? 8 : 12)),
          Text(
            value,
            style: TextStyle(
              fontSize: isLarge ? 32 : (isSmallScreen ? 20 : 24),
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: isSmallScreen ? 2 : 4),
          Text(
            title,
            style: TextStyle(
              fontSize: isLarge ? 16 : (isSmallScreen ? 12 : 14),
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required User user,
    required VoidCallback onEdit,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow(
              icon: Icons.person,
              title: 'Name',
              value: user.name,
            ),
            const Divider(height: 24),
            _buildInfoRow(
              icon: Icons.email,
              title: 'Email',
              value: user.email,
            ),
            if (user.phoneNumber != null) ...[
              const Divider(height: 24),
              _buildInfoRow(
                icon: Icons.phone,
                title: 'Phone',
                value: user.phoneNumber!,
              ),
            ],
            if (user.address != null) ...[
              const Divider(height: 24),
              _buildInfoRow(
                icon: Icons.location_on,
                title: 'Address',
                value: user.address!,
              ),
            ],
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit),
              label: const Text('Edit Information'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSettingsCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Manage your notification preferences',
            onTap: () {
              // Navigate to notifications settings
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsSettingsScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            icon: Icons.language,
            title: 'Language',
            subtitle: 'Change app language',
            onTap: () {
              // Navigate to language settings
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LanguageSettingsScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            icon: Icons.security,
            title: 'Security',
            subtitle: 'Manage your security settings',
            onTap: () {
              // Navigate to security settings
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SecuritySettingsScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'Get help and contact support',
            onTap: () {
              // Navigate to help & support
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HelpSupportScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1),
          // Add a theme settings option in the settings section
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text('Theme Settings'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ThemeSettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}

