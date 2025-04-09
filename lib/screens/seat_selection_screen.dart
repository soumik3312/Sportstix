import 'package:flutter/material.dart';
import '../models/match.dart';
import '../models/seat.dart';
import '../models/sport.dart';
import 'booking_summary_screen.dart';

class SeatSelectionScreen extends StatefulWidget {
  final Match match;
  final int numberOfAttendees;

  const SeatSelectionScreen({
    Key? key,
    required this.match,
    required this.numberOfAttendees,
  }) : super(key: key);

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  late List<Seat> _seats;
  final List<Seat> _selectedSeats = [];

  @override
  void initState() {
    super.initState();
    _seats = isIndoorSport(widget.match.sportType)
        ? generateIndoorVenueSeats(widget.match.ticketPrices)
        : generateStadiumSeats(widget.match.ticketPrices);
  }

  void _toggleSeatSelection(Seat seat) {
    if (!seat.isAvailable) return;

    setState(() {
      if (seat.isSelected) {
        seat.isSelected = false;
        _selectedSeats.remove(seat);
      } else {
        if (_selectedSeats.length < widget.numberOfAttendees) {
          seat.isSelected = true;
          _selectedSeats.add(seat);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('You can only select ${widget.numberOfAttendees} seats'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    });
  }

  double get _totalAmount =>
      _selectedSeats.fold(0, (sum, seat) => sum + seat.price);

  Color _getCategoryColor(SeatCategory category) {
    switch (category) {
      case SeatCategory.vip:
        return Colors.purple.shade200;
      case SeatCategory.premium:
        return Colors.blue.shade200;
      case SeatCategory.regular:
        return Colors.grey.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Select Seats'),
        centerTitle: true,
        backgroundColor: Colors.black87,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          _buildMiniStadiumIllustration(),
          _buildSeatLegend(),
          Expanded(child: _buildSeatLayout(screenSize)),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildMiniStadiumIllustration() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Colors.deepPurple, Colors.indigo],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.3),
              blurRadius: 12,
              spreadRadius: 2,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 20,
              child: Icon(Icons.stadium, size: 80, color: Colors.white70),
            ),
            Positioned(
              bottom: 20,
              child: Text(
                isIndoorSport(widget.match.sportType)
                    ? 'Indoor Arena View'
                    : 'Stadium View',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSeatLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Wrap(
        spacing: 16,
        alignment: WrapAlignment.center,
        children: [
          _buildLegendItem(Colors.grey[300]!, 'Available'),
          _buildLegendItem(Colors.grey[700]!, 'Unavailable'),
          _buildLegendItem(Theme.of(context).primaryColor, 'Selected'),
          _buildLegendItem(Colors.purple.shade200, 'VIP'),
          _buildLegendItem(Colors.blue.shade200, 'Premium'),
          _buildLegendItem(Colors.grey.shade400, 'Regular'),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          margin: const EdgeInsets.only(right: 4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.black12),
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildSeatLayout(Size screenSize) {
    final Map<String, List<Seat>> seatsByRow = {};
    for (var seat in _seats) {
      seatsByRow.putIfAbsent(seat.row, () => []).add(seat);
    }

    final sortedRows = seatsByRow.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedRows.length,
      itemBuilder: (context, index) {
        final row = sortedRows[index];
        final seats = seatsByRow[row]!;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(row,
                    style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        seats.map((seat) => _buildSeat(seat, screenSize)).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSeat(Seat seat, Size screenSize) {
    final double seatSize = screenSize.width < 360 ? 28.0 : 32.0;
    bool isSelected = seat.isSelected;
    bool isUnavailable = !seat.isAvailable;

    Color seatColor = isUnavailable
        ? Colors.grey[700]!
        : isSelected
            ? Colors.deepOrange
            : _getCategoryColor(seat.category);

    Color borderColor = isSelected ? Colors.deepOrange.shade700 : Colors.black26;
    Color textColor = isUnavailable || isSelected ? Colors.white : Colors.black87;

    return GestureDetector(
      onTap: () => _toggleSeatSelection(seat),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 3),
        width: seatSize,
        height: seatSize,
        decoration: BoxDecoration(
          color: seatColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: seatColor.withOpacity(0.5),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: AnimatedScale(
          scale: isSelected ? 1.1 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          child: Center(
            child: Text(
              seat.number.toString(),
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 12, color: textColor),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, -3),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_selectedSeats.isNotEmpty)
            Row(
              children: [
                const Text('Selected: ',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                Expanded(
                  child: Text(
                    _selectedSeats.map((s) => '${s.row}${s.number}').join(', '),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: ₹${_totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor),
              ),
              ElevatedButton(
                onPressed: _selectedSeats.length == widget.numberOfAttendees
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookingSummaryScreen(
                              match: widget.match,
                              selectedSeats: _selectedSeats,
                              numberOfAttendees: widget.numberOfAttendees,
                            ),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  backgroundColor: Colors.deepPurple,
                ),
                child: Text(
                  _selectedSeats.length == widget.numberOfAttendees
                      ? 'Continue'
                      : 'Select ${widget.numberOfAttendees - _selectedSeats.length} more',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
