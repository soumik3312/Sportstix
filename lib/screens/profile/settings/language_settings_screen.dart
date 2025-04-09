import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({Key? key}) : super(key: key);

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  String _selectedLanguage = 'English';
  bool _isLoading = true;
  
  final List<Map<String, dynamic>> _languages = [
    {
      'name': 'English',
      'code': 'en',
      'flag': '🇺🇸',
    },
    {
      'name': 'Hindi',
      'code': 'hi',
      'flag': '🇮🇳',
    },
    {
      'name': 'Bengali',
      'code': 'bn',
      'flag': '🇮🇳',
    },
    {
      'name': 'Tamil',
      'code': 'ta',
      'flag': '🇮🇳',
    },
    {
      'name': 'Telugu',
      'code': 'te',
      'flag': '🇮🇳',
    },
    {
      'name': 'Marathi',
      'code': 'mr',
      'flag': '🇮🇳',
    },
    {
      'name': 'Gujarati',
      'code': 'gu',
      'flag': '🇮🇳',
    },
    {
      'name': 'Kannada',
      'code': 'kn',
      'flag': '🇮🇳',
    },
    {
      'name': 'Malayalam',
      'code': 'ml',
      'flag': '🇮🇳',
    },
    {
      'name': 'Punjabi',
      'code': 'pa',
      'flag': '🇮🇳',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _selectedLanguage = prefs.getString('app_language') ?? 'English';
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading language settings: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings(String language) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_language', language);
      
      setState(() {
        _selectedLanguage = language;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Language changed to $language'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error saving language settings: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to change language'),
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
        title: const Text('Language Settings'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Language',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose your preferred language for the app',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _languages.length,
                    itemBuilder: (context, index) {
                      final language = _languages[index];
                      final isSelected = _selectedLanguage == language['name'];
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: isSelected ? 2 : 1,
                        color: isSelected ? Colors.blue.shade50 : null,
                        child: ListTile(
                          leading: Text(
                            language['flag'],
                            style: const TextStyle(fontSize: 24),
                          ),
                          title: Text(language['name']),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle, color: Colors.green)
                              : null,
                          onTap: () => _saveSettings(language['name']),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),
                  const Text(
                    'Language Preferences',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPreferenceTile(
                    title: 'Match Commentary Language',
                    subtitle: 'Set language for live match commentary',
                    icon: Icons.sports_cricket,
                  ),
                  _buildPreferenceTile(
                    title: 'Notifications Language',
                    subtitle: 'Set language for notifications',
                    icon: Icons.notifications,
                  ),
                  _buildPreferenceTile(
                    title: 'Date & Time Format',
                    subtitle: 'Set regional format for dates and times',
                    icon: Icons.calendar_today,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPreferenceTile({
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
          // Navigate to specific language settings
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

