import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsSettingsScreen> createState() => _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState extends State<NotificationsSettingsScreen> {
  bool _matchReminders = true;
  bool _bookingUpdates = true;
  bool _promotionalOffers = false;
  bool _appUpdates = true;
  bool _gameInvites = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _matchReminders = prefs.getBool('notifications_match_reminders') ?? true;
        _bookingUpdates = prefs.getBool('notifications_booking_updates') ?? true;
        _promotionalOffers = prefs.getBool('notifications_promotional_offers') ?? false;
        _appUpdates = prefs.getBool('notifications_app_updates') ?? true;
        _gameInvites = prefs.getBool('notifications_game_invites') ?? true;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading notification settings: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_match_reminders', _matchReminders);
      await prefs.setBool('notifications_booking_updates', _bookingUpdates);
      await prefs.setBool('notifications_promotional_offers', _promotionalOffers);
      await prefs.setBool('notifications_app_updates', _appUpdates);
      await prefs.setBool('notifications_game_invites', _gameInvites);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification settings saved'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error saving notification settings: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save settings'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notification Preferences',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildNotificationSwitch(
                    title: 'Match Reminders',
                    subtitle: 'Get notified about upcoming matches',
                    value: _matchReminders,
                    onChanged: (value) {
                      setState(() {
                        _matchReminders = value;
                      });
                    },
                    icon: Icons.sports,
                  ),
                  _buildNotificationSwitch(
                    title: 'Booking Updates',
                    subtitle: 'Get notified about your booking status',
                    value: _bookingUpdates,
                    onChanged: (value) {
                      setState(() {
                        _bookingUpdates = value;
                      });
                    },
                    icon: Icons.confirmation_number,
                  ),
                  _buildNotificationSwitch(
                    title: 'Promotional Offers',
                    subtitle: 'Get notified about discounts and special offers',
                    value: _promotionalOffers,
                    onChanged: (value) {
                      setState(() {
                        _promotionalOffers = value;
                      });
                    },
                    icon: Icons.local_offer,
                  ),
                  _buildNotificationSwitch(
                    title: 'App Updates',
                    subtitle: 'Get notified about new app features and updates',
                    value: _appUpdates,
                    onChanged: (value) {
                      setState(() {
                        _appUpdates = value;
                      });
                    },
                    icon: Icons.system_update,
                  ),
                  _buildNotificationSwitch(
                    title: 'Game Invites',
                    subtitle: 'Get notified about mini-game challenges',
                    value: _gameInvites,
                    onChanged: (value) {
                      setState(() {
                        _gameInvites = value;
                      });
                    },
                    icon: Icons.sports_esports,
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),
                  const Text(
                    'Notification Channels',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildChannelTile(
                    title: 'Push Notifications',
                    subtitle: 'Receive notifications on your device',
                    icon: Icons.notifications_active,
                  ),
                  _buildChannelTile(
                    title: 'Email Notifications',
                    subtitle: 'Receive notifications via email',
                    icon: Icons.email,
                  ),
                  _buildChannelTile(
                    title: 'SMS Notifications',
                    subtitle: 'Receive notifications via SMS',
                    icon: Icons.sms,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveSettings,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Save Settings',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildNotificationSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Theme.of(context).primaryColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.grey),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          value: value,
          onChanged: onChanged,
          secondary: value
              ? const Icon(Icons.check_circle, color: Colors.green)
              : const Icon(Icons.cancel, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildChannelTile({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$title settings coming soon'),
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }
}
