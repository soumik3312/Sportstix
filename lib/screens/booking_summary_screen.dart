import 'package:flutter/material.dart';
import 'package:sports_ticket_booking/theme/app_theme.dart';
import '../models/booking.dart';
import '../models/match.dart';
import '../models/seat.dart';
import 'payment_screen.dart';

class BookingSummaryScreen extends StatelessWidget {
  final Match match;
  final List<Seat> selectedSeats;
  final int numberOfAttendees;

  const BookingSummaryScreen({
    Key? key,
    required this.match,
    required this.selectedSeats,
    required this.numberOfAttendees,
  }) : super(key: key);

  double get totalAmount {
    return selectedSeats.fold(0, (sum, seat) => sum + seat.price);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;
    final responsivePadding = AppTheme.getResponsivePadding(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Summary'),
      ),
      body: SingleChildScrollView(
        padding: responsivePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMatchDetails(),
            SizedBox(height: AppTheme.getResponsiveSpacing(context, factor: 1.5)),
            _buildSeatDetails(),
            SizedBox(height: AppTheme.getResponsiveSpacing(context, factor: 1.5)),
            _buildPriceDetails(),
            SizedBox(height: AppTheme.getResponsiveSpacing(context, factor: 2)),
            _buildContinueButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchDetails() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Match Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Match', match.matchTitle),
            const SizedBox(height: 8),
            _buildInfoRow('Date & Time', '${_formatDate(match.dateTime)} at ${_formatTime(match.dateTime)}'),
            const SizedBox(height: 8),
            _buildInfoRow('Venue', match.venue),
            const SizedBox(height: 8),
            _buildInfoRow('Category', match.categoryName),
          ],
        ),
      ),
    );
  }

  Widget _buildSeatDetails() {
    // Group seats by category
    final Map<SeatCategory, List<Seat>> seatsByCategory = {};
    for (var seat in selectedSeats) {
      if (!seatsByCategory.containsKey(seat.category)) {
        seatsByCategory[seat.category] = [];
      }
      seatsByCategory[seat.category]!.add(seat);
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Seat Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$numberOfAttendees Attendees',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...seatsByCategory.entries.map((entry) {
              final seats = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${seats.first.categoryName} (${seats.length})',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      seats.map((s) => s.seatLabel).join(', '),
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceDetails() {
    // Calculate subtotal by category
    final Map<SeatCategory, double> subtotalByCategory = {};
    for (var seat in selectedSeats) {
      if (!subtotalByCategory.containsKey(seat.category)) {
        subtotalByCategory[seat.category] = 0;
      }
      subtotalByCategory[seat.category] = subtotalByCategory[seat.category]! + seat.price;
    }

    // Convenience fee (10% of total)
    final convenienceFee = totalAmount * 0.1;
    final grandTotal = totalAmount + convenienceFee;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Price Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...subtotalByCategory.entries.map((entry) {
              final category = entry.key;
              final subtotal = entry.value;
              final count = selectedSeats.where((s) => s.category == category).length;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_getCategoryName(category)} (${count}x ₹${selectedSeats.firstWhere((s) => s.category == category).price.toStringAsFixed(2)})',
                    ),
                    Text('₹${subtotal.toStringAsFixed(2)}'),
                  ],
                ),
              );
            }).toList(),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal'),
                Text('₹${totalAmount.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Convenience Fee (10%)'),
                Text('₹${convenienceFee.toStringAsFixed(2)}'),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Grand Total',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '₹${grandTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentScreen(
                match: match,
                selectedSeats: selectedSeats,
                numberOfAttendees: numberOfAttendees,
                totalAmount: totalAmount + (totalAmount * 0.1),
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 14 : 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          'Proceed to Payment',
          style: TextStyle(
            fontSize: isSmallScreen ? 15 : 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
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

  String _getCategoryName(SeatCategory category) {
    switch (category) {
      case SeatCategory.vip:
        return 'VIP';
      case SeatCategory.premium:
        return 'Premium';
      case SeatCategory.regular:
        return 'Regular';
    }
  }
}

