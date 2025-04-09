import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/booking.dart';
import '../models/user.dart';

class EmailService extends ChangeNotifier {
  bool _isSending = false;
  String? _lastError;
  bool _emailSent = false;
  int _retryCount = 0;
  static const int _maxRetries = 3;

  bool get isSending => _isSending;
  String? get lastError => _lastError;
  bool get emailSent => _emailSent;
  int get retryCount => _retryCount;

  // Reset the email status
  void resetEmailStatus() {
    _isSending = false;
    _lastError = null;
    _emailSent = false;
    _retryCount = 0;
    notifyListeners();
  }

  // Send a ticket confirmation email with retry logic
  Future<bool> sendTicketConfirmationEmail(User user, Booking booking) async {
    try {
      _isSending = true;
      _lastError = null;
      _emailSent = false;
      _retryCount = 0;
      notifyListeners();

      // Get EmailJS credentials from environment variables
      final serviceId = 'service_fvhca93';
      final templateId = 'template_10gl566';
      final userId = 'e4vvI5s1AKvB56jyK';

      // Check if credentials are available
      if (serviceId == null || templateId == null || userId == null) {
        _lastError = 'EmailJS credentials not configured';
        _isSending = false;
        notifyListeners();
        return false;
      }

      // Format date and time for email
      final matchDate = _formatDate(booking.match.dateTime);
      final matchTime = _formatTime(booking.match.dateTime);
      
      // Format seat information
      final seats = booking.selectedSeats.map((seat) => seat.seatLabel).join(', ');
      
      // Prepare template parameters
      final templateParams = {
        'to_name': user.name,
        'to_email': user.email,
        'booking_id': booking.id,
        'match_title': booking.match.matchTitle,
        'match_date': matchDate,
        'match_time': matchTime,
        'venue': booking.match.venue,
        'location': booking.match.location,
        'seats': seats,
        'attendees': booking.numberOfAttendees.toString(),
        'total_amount': '₹${booking.totalAmount.toStringAsFixed(2)}',
        'payment_method': booking.paymentMethod,
        'booking_status': booking.bookingStatus,
        'booking_time': _formatDateTime(booking.bookingTime),
      };

      bool success = false;
      while (!success && _retryCount < _maxRetries) {
        try {
          // Make API request to EmailJS
          final response = await http.post(
            Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
            headers: {
              'Content-Type': 'application/json',
               'origin': 'http://localhost'

            },
            body: jsonEncode({
              'service_id': serviceId,
              'template_id': templateId,
              'user_id': userId,
              'template_params': templateParams,
            }),
          );

          if (response.statusCode == 200) {
            success = true;
          } else {
            _retryCount++;
            // Wait before retrying (exponential backoff)
            if (_retryCount < _maxRetries) {
              await Future.delayed(Duration(seconds: _retryCount * 2));
            }
          }
        } catch (e) {
          _retryCount++;
          // Wait before retrying
          if (_retryCount < _maxRetries) {
            await Future.delayed(Duration(seconds: _retryCount * 2));
          }
        }
      }

      if (success) {
        _emailSent = true;
        _isSending = false;
        notifyListeners();
        return true;
      } else {
        _lastError = 'Failed to send email after $_maxRetries attempts';
        _isSending = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _lastError = 'Error sending email: $e';
      _isSending = false;
      notifyListeners();
      return false;
    }
  }

  // Format date for email
  String _formatDate(DateTime dateTime) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${dateTime.day} ${months[dateTime.month - 1]}, ${dateTime.year}';
  }

  // Format time for email
  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  // Format date and time together
  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} at ${_formatTime(dateTime)}';
  }
  
  // Check if email is valid
  bool isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    return emailRegExp.hasMatch(email);
  }
}