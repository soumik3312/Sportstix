import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({Key? key}) : super(key: key);

  Future<void> _launchUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (!await launchUrl(uri)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }

  Future<void> _sendEmail(String email) async {
    try {
      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: email,
        queryParameters: {
          'subject': 'Support Request - Sports Ticket Booking App',
        },
      );
      
      if (!await launchUrl(emailUri)) {
        throw Exception('Could not launch email client');
      }
    } catch (e) {
      print('Error launching email: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSupportHeader(context),
            const SizedBox(height: 24),
            const Text(
              'Contact Us',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildContactCard(
              title: 'Customer Support',
              subtitle: 'Get help with your bookings and account',
              icon: Icons.support_agent,
              onTap: () => _sendEmail('support@sportsticket.app'),
            ),
            _buildContactCard(
              title: 'Technical Support',
              subtitle: 'Report app issues or technical problems',
              icon: Icons.bug_report,
              onTap: () => _sendEmail('tech@sportsticket.app'),
            ),
            _buildContactCard(
              title: 'Feedback & Suggestions',
              subtitle: 'Share your ideas to improve the app',
              icon: Icons.feedback,
              onTap: () => _sendEmail('feedback@sportsticket.app'),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildFaqItem(
              question: 'How do I book tickets?',
              answer: 'To book tickets, select your location, choose a sport, browse available matches, select a match, choose the number of attendees, select your seats, and complete the payment process.',
            ),
            _buildFaqItem(
              question: 'How can I cancel my booking?',
              answer: 'You can cancel your booking by going to My Bookings, selecting the booking you want to cancel, and tapping the Cancel button. Please note that refund amounts depend on how close to the match date you cancel.',
            ),
            _buildFaqItem(
              question: 'What is the 3D stadium view?',
              answer: 'The 3D stadium view is a holographic representation of the venue that allows you to visualize the stadium layout before selecting your seats. It helps you understand the venue structure and make better seating choices.',
            ),
            _buildFaqItem(
              question: 'How do I set match reminders?',
              answer: 'You can set match reminders by adding a match to your favorites and enabling the reminder toggle. You\'ll receive a notification 3 hours before the match starts.',
            ),
            _buildFaqItem(
              question: 'What payment methods are accepted?',
              answer: 'We accept credit/debit cards, UPI payments, net banking, and digital wallets like Paytm, PhonePe, Google Pay, and Amazon Pay.',
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),
            const Text(
              'Resources',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildResourceCard(
              title: 'Home-Sportstix',
              subtitle: 'Visit our website to know our app more',
              icon: Icons.build_circle_rounded,
              onTap: () => _launchUrl('https://v0-sportix-website-design-q6ryl0.vercel.app'),
            ),
            _buildResourceCard(
              title: 'User Guide',
              subtitle: 'Learn how to use all features of the app',
              icon: Icons.menu_book,
              onTap: () => _launchUrl('https://v0-sportix-website-design-q6ryl0.vercel.app/guide'),
            ),
            _buildContactCard(
              title: 'Terms & Conditions',
              subtitle: 'Understand our terms of Service',
              icon: Icons.article,
              onTap:() => _launchUrl('https://v0-sportix-website-design-q6ryl0.vercel.app/terms'),
            ),
            _buildResourceCard(
              title: 'Privacy Policy',
              subtitle: 'Learn how we handle your data',
              icon: Icons.privacy_tip,
              onTap: () => _launchUrl('https://v0-sportix-website-design-q6ryl0.vercel.app/privacy'),
            ),
            _buildResourceCard(
              title: 'About Us',
              subtitle: 'Learn more about our company',
              icon: Icons.info,
              onTap: () => _launchUrl('https://v0-sportix-website-design-q6ryl0.vercel.app/about-us'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.support,
            size: 60,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 16),
          const Text(
            'How can we help you?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Our support team is here to assist you with any questions or issues you may have.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              // Open chat with support
              Navigator.pushNamed(context, '/chat');
            },
            icon: const Icon(Icons.chat),
            label: const Text('Chat with Support'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade50,
          child: Icon(icon, color: Colors.blue),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildFaqItem({
    required String question,
    required String answer,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(answer),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade50,
          child: Icon(icon, color: Colors.green),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

