import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Appearance',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose how Sports Ticket Booking looks to you',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.grey[600]
                    : Colors.grey[400],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            _buildThemeCard(
              context,
              title: 'System Default',
              subtitle: 'Follow your device theme settings',
              icon: Icons.brightness_auto,
              isSelected: themeProvider.themePreference == ThemePreference.system,
              onTap: () => themeProvider.setThemePreference(ThemePreference.system),
            ),
            _buildThemeCard(
              context,
              title: 'Light Mode',
              subtitle: 'Use light theme regardless of system settings',
              icon: Icons.brightness_5,
              isSelected: themeProvider.themePreference == ThemePreference.light,
              onTap: () => themeProvider.setThemePreference(ThemePreference.light),
            ),
            _buildThemeCard(
              context,
              title: 'Dark Mode',
              subtitle: 'Use dark theme regardless of system settings',
              icon: Icons.brightness_4,
              isSelected: themeProvider.themePreference == ThemePreference.dark,
              onTap: () => themeProvider.setThemePreference(ThemePreference.dark),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),
            const Text(
              'Current Theme',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildCurrentThemeInfo(context, themeProvider),
            const SizedBox(height: 24),
            const Text(
              'Preview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildThemePreview(context),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: isSelected ? 2 : 1,
      color: isSelected 
          ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
          : null,
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected 
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).iconTheme.color,
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: isSelected
            ? Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              )
            : null,
        onTap: onTap,
      ),
    );
  }

  Widget _buildCurrentThemeInfo(BuildContext context, ThemeProvider themeProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark 
            ? Colors.grey[800]
            : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isDark ? Icons.dark_mode : Icons.light_mode,
                color: isDark ? Colors.amber : Colors.orange,
              ),
              const SizedBox(width: 12),
              Text(
                isDark ? 'Dark Mode Active' : 'Light Mode Active',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            themeProvider.themePreference == ThemePreference.system
                ? 'Following system settings'
                : themeProvider.themePreference == ThemePreference.light
                    ? 'Manually set to Light Mode'
                    : 'Manually set to Dark Mode',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemePreview(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sample app bar
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).appBarTheme.backgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.arrow_back,
                  color: Theme.of(context).appBarTheme.foregroundColor,
                ),
                const SizedBox(width: 16),
                Text(
                  'App Bar',
                  style: TextStyle(
                    color: Theme.of(context).appBarTheme.foregroundColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.more_vert,
                  color: Theme.of(context).appBarTheme.foregroundColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Sample text
          Text(
            'Headline',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'This is how body text will appear in the app.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          
          // Sample buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {},
                child: const Text('Primary'),
              ),
              OutlinedButton(
                onPressed: () {},
                child: const Text('Secondary'),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Text'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Sample form field
          TextField(
            decoration: const InputDecoration(
              labelText: 'Input Field',
              hintText: 'Enter text here',
            ),
          ),
          const SizedBox(height: 16),
          
          // Sample switches
          SwitchListTile(
            title: const Text('Switch Example'),
            value: true,
            onChanged: (_) {},
          ),
          CheckboxListTile(
            title: const Text('Checkbox Example'),
            value: true,
            onChanged: (_) {},
          ),
        ],
      ),
    );
  }
}

