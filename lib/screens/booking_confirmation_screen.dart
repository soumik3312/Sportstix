import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../models/booking.dart';
import '../services/email_service.dart';
import '../services/auth_service.dart';
import '../widgets/adaptive_text.dart';

class BookingConfirmationScreen extends StatefulWidget {
  final Booking booking;

  const BookingConfirmationScreen({
    Key? key,
    required this.booking,
  }) : super(key: key);

  @override
  State<BookingConfirmationScreen> createState() => _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  bool _isEmailSending = false;
  bool _emailSent = false;
  String? _emailError;
  bool _showEmailStatus = false;
  Timer? _statusTimer;

  @override
  void initState() {
    super.initState();
    // Send confirmation email automatically
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendConfirmationEmail();
    });
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  Future<void> _sendConfirmationEmail() async {
    final emailService = Provider.of<EmailService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    
    if (authService.currentUser == null) {
      setState(() {
        _emailError = 'User information not available';
        _showEmailStatus = true;
      });
      return;
    }
    
    final user = authService.currentUser!;
    
    // Validate email
    if (!emailService.isValidEmail(user.email)) {
      setState(() {
        _emailError = 'Invalid email address';
        _showEmailStatus = true;
      });
      return;
    }
    
    setState(() {
      _isEmailSending = true;
      _emailError = null;
      _emailSent = false;
      _showEmailStatus = true;
    });
    
    final success = await emailService.sendTicketConfirmationEmail(user, widget.booking);
    
    setState(() {
      _isEmailSending = false;
      _emailSent = success;
      _emailError = success ? null : emailService.lastError;
    });
    
    // Hide status after 5 seconds if successful
    if (success) {
      _statusTimer = Timer(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _showEmailStatus = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Confirmation'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Email status indicator
            if (_showEmailStatus)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                color: _emailSent 
                    ? Colors.green.shade100 
                    : _emailError != null 
                        ? Colors.red.shade100 
                        : Colors.blue.shade100,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: Row(
                  children: [
                    if (_isEmailSending)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    else if (_emailSent)
                      Icon(Icons.check_circle, color: Colors.green.shade700)
                    else if (_emailError != null)
                      Icon(Icons.error, color: Colors.red.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _isEmailSending
                            ? 'Sending confirmation email...'
                            : _emailSent
                                ? 'Confirmation email sent successfully!'
                                : _emailError != null
                                    ? 'Failed to send email: $_emailError'
                                    : '',
                        style: TextStyle(
                          color: _emailSent 
                              ? Colors.green.shade700 
                              : _emailError != null 
                                  ? Colors.red.shade700 
                                  : Colors.blue.shade700,
                        ),
                      ),
                    ),
                    if (_emailError != null)
                      TextButton(
                        onPressed: _sendConfirmationEmail,
                        child: const Text('Retry'),
                      ),
                  ],
                ),
              ),
            
            // Booking details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Success header
                  Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 80,
                        ),
                        const SizedBox(height: 16),
                        AdaptiveText(
                          'Booking Confirmed!',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        AdaptiveText(
                          'Your tickets have been booked successfully',
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Booking ID
                  _buildInfoRow(
                    context,
                    'Booking ID',
                    widget.booking.id,
                    icon: Icons.confirmation_number,
                  ),
                  
                  const Divider(),
                  
                  // Match details
                  _buildInfoRow(
                    context,
                    'Match',
                    widget.booking.match.matchTitle,
                    icon: Icons.sports,
                  ),
                  
                  _buildInfoRow(
                    context,
                    'Date & Time',
                    '${_formatDate(widget.booking.match.dateTime)} at ${_formatTime(widget.booking.match.dateTime)}',
                    icon: Icons.calendar_today,
                  ),
                  
                  _buildInfoRow(
                    context,
                    'Venue',
                    widget.booking.match.venue,
                    icon: Icons.location_on,
                  ),
                  
                  const Divider(),
                  
                  // Ticket details
                  _buildInfoRow(
                    context,
                    'Seats',
                    widget.booking.selectedSeats.map((seat) => seat.seatLabel).join(', '),
                    icon: Icons.event_seat,
                  ),
                  
                  _buildInfoRow(
                    context,
                    'Attendees',
                    widget.booking.numberOfAttendees.toString(),
                    icon: Icons.people,
                  ),
                  
                  const Divider(),
                  
                  // Payment details
                  _buildInfoRow(
                    context,
                    'Total Amount',
                    '₹${widget.booking.totalAmount.toStringAsFixed(2)}',
                    icon: Icons.payments,
                    valueStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  
                  _buildInfoRow(
                    context,
                    'Payment Method',
                    widget.booking.paymentMethod,
                    icon: Icons.payment,
                  ),
                  
                  _buildInfoRow(
                    context,
                    'Booking Time',
                    '${_formatDate(widget.booking.bookingTime)} at ${_formatTime(widget.booking.bookingTime)}',
                    icon: Icons.access_time,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // QR Code
                  Center(
                    child: Column(
                      children: [
                        const Text(
                          'Show this QR code at the venue',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=${widget.booking.id}',
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey.shade200,
                                  child: const Center(
                                    child: Icon(
                                      Icons.qr_code,
                                      size: 80,
                                      color: Colors.grey,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SelectableText(
                          widget.booking.id,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _sendConfirmationEmail,
                        icon: const Icon(Icons.email),
                        label: const Text('Resend Email'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        },
                        icon: const Icon(Icons.home),
                        label: const Text('Go to Home'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, {
    IconData? icon,
    TextStyle? valueStyle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 20,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: valueStyle ?? const TextStyle(fontWeight: FontWeight.w500),
              textAlign: TextAlign.right,
            ),
          ),
        ],
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
}