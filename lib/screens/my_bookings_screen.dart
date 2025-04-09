import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/booking.dart';
import '../services/booking_service.dart';
import '../services/auth_service.dart';
import 'booking_confirmation_screen.dart';
import 'auth/login_screen.dart';
import 'ticket_cancellation_screen.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({Key? key}) : super(key: key);

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Check if user is logged in
    if (!authService.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Bookings'),
          backgroundColor: isDarkMode ? Colors.black : Colors.white,
          foregroundColor: isDarkMode ? Colors.white : Colors.black,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.account_circle,
                size: 80,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              const Text(
                'You need to be logged in to view your bookings',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                child: const Text('Log In'),
              ),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
          ],
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: isDarkMode ? Colors.grey[400] : Colors.grey[700],
        ),
        actions: [
          // Add a user indicator in the app bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(
                authService.currentUser?.email ?? '',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<BookingService>(
        builder: (context, bookingService, child) {
          if (bookingService.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          return TabBarView(
            controller: _tabController,
            children: [
              _buildBookingsList(bookingService, true),
              _buildBookingsList(bookingService, false),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBookingsList(BookingService bookingService, bool upcoming) {
    final filteredBookings = bookingService.bookings.where((booking) {
      final isUpcoming = booking.match.dateTime.isAfter(DateTime.now());
      return upcoming ? isUpcoming : !isUpcoming;
    }).toList();
    
    if (filteredBookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              upcoming ? Icons.event_available : Icons.history,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              upcoming ? 'No upcoming bookings' : 'No past bookings',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              upcoming 
                ? 'Book tickets for upcoming matches to see them here'
                : 'Your booking history will appear here',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredBookings.length,
      itemBuilder: (context, index) {
        final booking = filteredBookings[index];
        return _buildBookingCard(booking);
      },
    );
  }

  Widget _buildBookingCard(Booking booking) {
    final isUpcoming = booking.match.dateTime.isAfter(DateTime.now());
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
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
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUpcoming 
                    ? (isDarkMode ? Colors.blue.shade900.withOpacity(0.3) : Colors.blue[50])
                    : (isDarkMode ? Colors.grey.shade800 : Colors.grey[100]),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isUpcoming 
                          ? (isDarkMode ? Colors.blue.withOpacity(0.2) : Colors.blue.withOpacity(0.1))
                          : (isDarkMode ? Colors.grey.withOpacity(0.2) : Colors.grey.withOpacity(0.1)),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isUpcoming ? Icons.confirmation_number : Icons.event_available,
                      color: isUpcoming ? Colors.blue : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.match.matchTitle,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_formatDate(booking.match.dateTime)} at ${_formatTime(booking.match.dateTime)}',
                          style: TextStyle(
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(booking.bookingStatus),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      booking.bookingStatus,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildInfoRow('Booking ID', booking.id),
                  const SizedBox(height: 8),
                  _buildInfoRow('Venue', booking.match.venue),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    'Seats',
                    booking.selectedSeats.map((s) => s.seatLabel).join(', '),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    'Amount Paid',
                    '₹${booking.totalAmount.toStringAsFixed(2)}',
                  ),
                  if (booking.bookingStatus == 'Cancelled' && booking.refundAmount != null)
                    Column(
                      children: [
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          'Refund Amount',
                          '₹${booking.refundAmount!.toStringAsFixed(2)}',
                          valueColor: Colors.green,
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  if (isUpcoming && booking.bookingStatus == 'Confirmed')
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BookingConfirmationScreen(booking: booking),
                                ),
                              );
                            },
                            icon: const Icon(Icons.visibility),
                            label: const Text('View Ticket'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TicketCancellationScreen(booking: booking),
                                ),
                              );
                            },
                            icon: const Icon(Icons.cancel),
                            label: const Text('Cancel'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              backgroundColor: Colors.red,
                            ),
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

  void _showCancellationDialog(Booking booking) {
    final bookingService = Provider.of<BookingService>(context, listen: false);
    final policyDetails = bookingService.getCancellationPolicyDetails(booking.id);
    
    if (!policyDetails['canCancel']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(policyDetails['reason']),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final TextEditingController reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to cancel your booking for ${booking.match.matchTitle}?',
              ),
              const SizedBox(height: 16),
              const Text(
                'Cancellation Policy:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('• ${policyDetails['timeFrame']}'),
              Text('• You will receive a ${(policyDetails['refundPercentage'] * 100).toInt()}% refund'),
              Text('• Refund amount: ₹${policyDetails['refundAmount'].toStringAsFixed(2)}'),
              const SizedBox(height: 16),
              const Text(
                'Please provide a reason for cancellation:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  hintText: 'Enter reason for cancellation',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('BACK'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please provide a reason for cancellation'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              Navigator.pop(context);
              
              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );
              
              final success = await bookingService.cancelBooking(
                booking.id,
                reasonController.text.trim(),
              );
              
              // Close loading indicator
              Navigator.pop(context);
              
              if (success) {
                _showCancellationSuccessDialog(policyDetails['refundAmount']);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to cancel booking. Please try again.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('CANCEL BOOKING'),
          ),
        ],
      ),
    );
  }

  void _showCancellationSuccessDialog(double refundAmount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            const Text('Booking Cancelled'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your booking has been successfully cancelled.'),
            const SizedBox(height: 16),
            Text('A refund of ₹${refundAmount.toStringAsFixed(2)} will be processed to your original payment method within 5-7 business days.'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {}); // Refresh the UI
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Confirmed':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      case 'Pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
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

