import 'package:flutter/material.dart';
import 'package:sports_ticket_booking/models/sport.dart';
import 'package:sports_ticket_booking/screens/seat_selection_screen.dart';
import 'dart:math' as math;
import '../models/match.dart';
import '../models/seat.dart';
import 'booking_summary_screen.dart';

class HolographicStadiumScreen extends StatefulWidget {
  final Match match;
  final int numberOfAttendees;

  const HolographicStadiumScreen({
    Key? key,
    required this.match,
    required this.numberOfAttendees,
  }) : super(key: key);

  @override
  State<HolographicStadiumScreen> createState() => _HolographicStadiumScreenState();
}

class _HolographicStadiumScreenState extends State<HolographicStadiumScreen> with SingleTickerProviderStateMixin {
  late List<Seat> _seats;
  final List<Seat> _selectedSeats = [];
  double _rotationAngle = 0;
  double _zoomLevel = 1.0;
  bool _showLegend = true;
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;
  
  // Stadium dimensions
  double _stadiumWidth = 0;
  double _stadiumHeight = 0;
  double _fieldWidth = 0;
  double _fieldHeight = 0;
  
  // Stadium colors based on sport type
  late Color _primaryColor;
  late Color _secondaryColor;
  late Color _fieldColor;
  
  @override
  void initState() {
    super.initState();
    // Generate seats based on venue type (indoor or outdoor)
    if (isIndoorSport(widget.match.sportType)) {
      _seats = generateIndoorVenueSeats(widget.match.ticketPrices);
    } else {
      _seats = generateStadiumSeats(widget.match.ticketPrices);
    }
    
    // Set up animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    );
    
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _rotateAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _animationController.repeat(reverse: true);
    
    // Set stadium colors based on sport type
    _setStadiumColors();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _setStadiumColors() {
    switch (widget.match.sportType) {
      case SportType.cricket:
        _primaryColor = Colors.blue;
        _secondaryColor = Colors.lightBlue;
        _fieldColor = Colors.green[700]!;
        break;
      case SportType.football:
        _primaryColor = Colors.green;
        _secondaryColor = Colors.lightGreen;
        _fieldColor = Colors.green[500]!;
        break;
      case SportType.hockey:
        _primaryColor = Colors.orange;
        _secondaryColor = Colors.amber;
        _fieldColor = Colors.lightBlue[100]!;
        break;
      case SportType.badminton:
        _primaryColor = Colors.purple;
        _secondaryColor = Colors.purpleAccent;
        _fieldColor = Colors.brown[300]!;
        break;
      case SportType.tableTennis:
        _primaryColor = Colors.teal;
        _secondaryColor = Colors.tealAccent;
        _fieldColor = Colors.blue[100]!;
        break;
      case SportType.basketball:
        _primaryColor = Colors.deepOrange;
        _secondaryColor = Colors.orange;
        _fieldColor = Colors.brown[400]!;
        break;
      default:
        _primaryColor = Colors.blue;
        _secondaryColor = Colors.lightBlue;
        _fieldColor = Colors.green[500]!;
    }
  }

  void _toggleSeatSelection(Seat seat) {
    if (!seat.isAvailable) return;

    setState(() {
      if (seat.isSelected) {
        seat.isSelected = false;
        _selectedSeats.remove(seat);
      } else {
        // Check if we've reached the maximum number of attendees
        if (_selectedSeats.length < widget.numberOfAttendees) {
          seat.isSelected = true;
          _selectedSeats.add(seat);
        } else {
          // Show a message that max seats are selected
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'You can only select ${widget.numberOfAttendees} seats',
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    });
  }

  double get _totalAmount {
    return _selectedSeats.fold(0, (sum, seat) => sum + seat.price);
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions to ensure responsive design
    final screenSize = MediaQuery.of(context).size;
    _stadiumWidth = screenSize.width * 0.8;
    _stadiumHeight = screenSize.height * 0.4;
    _fieldWidth = _stadiumWidth * 0.7;
    _fieldHeight = _stadiumHeight * 0.5;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('3D Stadium View'),
        actions: [
          IconButton(
            icon: Icon(_showLegend ? Icons.visibility_off : Icons.visibility),
            onPressed: () {
              setState(() {
                _showLegend = !_showLegend;
              });
            },
            tooltip: _showLegend ? 'Hide Legend' : 'Show Legend',
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showLegend) _buildSeatLegend(),
          Expanded(
            child: _build3DHolographicStadium(),
          ),
          _buildControlPanel(),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildSeatLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLegendItem(_primaryColor.withOpacity(0.7), 'VIP Section'),
          _buildLegendItem(_secondaryColor.withOpacity(0.7), 'Regular Section'),
          _buildLegendItem(_fieldColor, 'Field/Court'),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _build3DHolographicStadium() {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _rotationAngle += details.delta.dx * 0.01;
        });
      },
      child: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001) // perspective
                ..rotateY(_rotationAngle + _rotateAnimation.value)
                ..scale(_zoomLevel * _pulseAnimation.value),
              alignment: Alignment.center,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer glow effect
                      Container(
                        width: _stadiumWidth + 20,
                        height: _stadiumHeight + 20,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(isIndoorSport(widget.match.sportType) ? 16 : 100),
                          boxShadow: [
                            BoxShadow(
                              color: _primaryColor.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                      ),
                      
                      // Stadium outer structure
                      Container(
                        width: _stadiumWidth,
                        height: _stadiumHeight,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              _primaryColor.withOpacity(0.7),
                              _secondaryColor.withOpacity(0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(isIndoorSport(widget.match.sportType) ? 16 : 100),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                      ),
                      
                      // Stadium inner structure
                      Container(
                        width: _stadiumWidth * 0.9,
                        height: _stadiumHeight * 0.9,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              _secondaryColor.withOpacity(0.5),
                              _primaryColor.withOpacity(0.5),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(isIndoorSport(widget.match.sportType) ? 12 : 80),
                        ),
                      ),
                      
                      // Field/Court
                      Container(
                        width: _fieldWidth,
                        height: _fieldHeight,
                        decoration: BoxDecoration(
                          color: _fieldColor,
                          borderRadius: BorderRadius.circular(isIndoorSport(widget.match.sportType) ? 4 : 60),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: _buildFieldMarkings(),
                        ),
                      ),
                      
                      // Stadium name
                      Positioned(
                        top: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.match.venue,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      
                      // Holographic effect lines
                      ..._buildHolographicLines(),
                      
                      // Match details
                      Positioned(
                        bottom: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.match.matchTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildFieldMarkings() {
    switch (widget.match.sportType) {
      case SportType.cricket:
        return _buildCricketPitch();
      case SportType.football:
        return _buildFootballField();
      case SportType.hockey:
        return _buildHockeyField();
      case SportType.badminton:
        return _buildBadmintonCourt();
      case SportType.tableTennis:
        return _buildTableTennisCourt();
      case SportType.basketball:
        return _buildBasketballCourt();
      default:
        return const SizedBox();
    }
  }
  
  Widget _buildCricketPitch() {
    return Container(
      width: _fieldWidth * 0.3,
      height: _fieldHeight * 0.7,
      decoration: BoxDecoration(
        color: Colors.brown[300],
        borderRadius: BorderRadius.circular(2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(height: 2, color: Colors.white),
          Container(height: 2, color: Colors.white),
          Container(height: 2, color: Colors.white),
        ],
      ),
    );
  }
  
  Widget _buildFootballField() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Center circle
        Container(
          width: _fieldWidth * 0.3,
          height: _fieldWidth * 0.3,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 2),
            shape: BoxShape.circle,
          ),
        ),
        // Center line
        Container(
          width: _fieldWidth,
          height: 2,
          color: Colors.white,
        ),
        // Penalty areas
        Positioned(
          top: 10,
          child: Container(
            width: _fieldWidth * 0.6,
            height: _fieldHeight * 0.25,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
        Positioned(
          bottom: 10,
          child: Container(
            width: _fieldWidth * 0.6,
            height: _fieldHeight * 0.25,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildHockeyField() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Center line
        Container(
          width: _fieldWidth,
          height: 2,
          color: Colors.white,
        ),
        // Center circle
        Container(
          width: _fieldWidth * 0.2,
          height: _fieldWidth * 0.2,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 2),
            shape: BoxShape.circle,
          ),
        ),
        // Goal areas
        Positioned(
          top: 10,
          child: Container(
            width: _fieldWidth * 0.5,
            height: _fieldHeight * 0.2,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        Positioned(
          bottom: 10,
          child: Container(
            width: _fieldWidth * 0.5,
            height: _fieldHeight * 0.2,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildBadmintonCourt() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Court outline
        Container(
          width: _fieldWidth * 0.9,
          height: _fieldHeight * 0.9,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 2),
          ),
        ),
        // Center line
        Container(
          width: _fieldWidth * 0.9,
          height: 2,
          color: Colors.white,
        ),
        // Service areas
        Positioned(
          top: _fieldHeight * 0.2,
          child: Container(
            width: _fieldWidth * 0.9,
            height: 2,
            color: Colors.white,
          ),
        ),
        Positioned(
          bottom: _fieldHeight * 0.2,
          child: Container(
            width: _fieldWidth * 0.9,
            height: 2,
            color: Colors.white,
          ),
        ),
        // Center service line
        Container(
          width: 2,
          height: _fieldHeight * 0.9,
          color: Colors.white,
        ),
      ],
    );
  }
  
  Widget _buildTableTennisCourt() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Table outline
        Container(
          width: _fieldWidth * 0.9,
          height: _fieldHeight * 0.9,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 2),
          ),
        ),
        // Center line
        Container(
          width: 2,
          height: _fieldHeight * 0.9,
          color: Colors.white,
        ),
        // Net
        Container(
          width: _fieldWidth * 0.9,
          height: 4,
          color: Colors.white.withOpacity(0.7),
        ),
      ],
    );
  }
  
  Widget _buildBasketballCourt() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Court outline
        Container(
          width: _fieldWidth * 0.9,
          height: _fieldHeight * 0.9,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 2),
          ),
        ),
        // Center circle
        Container(
          width: _fieldWidth * 0.3,
          height: _fieldWidth * 0.3,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 2),
            shape: BoxShape.circle,
          ),
        ),
        // Center line
        Container(
          width: _fieldWidth * 0.9,
          height: 2,
          color: Colors.white,
        ),
        // Three-point lines
        Positioned(
          top: 10,
          child: Container(
            width: _fieldWidth * 0.7,
            height: _fieldHeight * 0.3,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white, width: 2),
                left: BorderSide(color: Colors.white, width: 2),
                right: BorderSide(color: Colors.white, width: 2),
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 10,
          child: Container(
            width: _fieldWidth * 0.7,
            height: _fieldHeight * 0.3,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.white, width: 2),
                left: BorderSide(color: Colors.white, width: 2),
                right: BorderSide(color: Colors.white, width: 2),
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  List<Widget> _buildHolographicLines() {
    final lines = <Widget>[];
    final random = math.Random(42); // Fixed seed for consistent pattern
    
    // Horizontal lines
    for (int i = 0; i < 10; i++) {
      final y = 20 + (i * (_stadiumHeight - 40) / 9);
      final opacity = 0.1 + random.nextDouble() * 0.2;
      final dashWidth = 5 + random.nextDouble() * 10;
      final gapWidth = 3 + random.nextDouble() * 5;
      
      lines.add(
        Positioned(
          top: y,
          child: _buildDashedLine(
            width: _stadiumWidth,
            height: 1,
            color: Colors.white.withOpacity(opacity),
            dashWidth: dashWidth,
            gapWidth: gapWidth,
          ),
        ),
      );
    }
    
    // Vertical lines
    for (int i = 0; i < 10; i++) {
      final x = 20 + (i * (_stadiumWidth - 40) / 9);
      final opacity = 0.1 + random.nextDouble() * 0.2;
      final dashWidth = 5 + random.nextDouble() * 10;
      final gapWidth = 3 + random.nextDouble() * 5;
      
      lines.add(
        Positioned(
          left: x,
          child: _buildDashedLine(
            width: 1,
            height: _stadiumHeight,
            color: Colors.white.withOpacity(opacity),
            dashWidth: dashWidth,
            gapWidth: gapWidth,
            isVertical: true,
          ),
        ),
      );
    }
    
    return lines;
  }
  
  Widget _buildDashedLine({
    required double width,
    required double height,
    required Color color,
    required double dashWidth,
    required double gapWidth,
    bool isVertical = false,
  }) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: DashedLinePainter(
          color: color,
          dashWidth: dashWidth,
          gapWidth: gapWidth,
          isVertical: isVertical,
        ),
      ),
    );
  }

  Widget _buildControlPanel() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildControlButton(
            icon: Icons.zoom_in,
            onPressed: () {
              setState(() {
                _zoomLevel = _zoomLevel < 1.5 ? _zoomLevel + 0.1 : _zoomLevel;
              });
            },
          ),
          const SizedBox(width: 16),
          _buildControlButton(
            icon: Icons.zoom_out,
            onPressed: () {
              setState(() {
                _zoomLevel = _zoomLevel > 0.5 ? _zoomLevel - 0.1 : _zoomLevel;
              });
            },
          ),
          const SizedBox(width: 16),
          _buildControlButton(
            icon: Icons.rotate_left,
            onPressed: () {
              setState(() {
                _rotationAngle -= 0.2;
              });
            },
          ),
          const SizedBox(width: 16),
          _buildControlButton(
            icon: Icons.rotate_right,
            onPressed: () {
              setState(() {
                _rotationAngle += 0.2;
              });
            },
          ),
          const SizedBox(width: 16),
          _buildControlButton(
            icon: Icons.refresh,
            onPressed: () {
              setState(() {
                _rotationAngle = 0;
                _zoomLevel = 1.0;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
        color: _primaryColor,
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select ${widget.numberOfAttendees} seats',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap on the seat selection button to choose your seats',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Navigate to seat selection screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SeatSelectionScreen(
                    match: widget.match,
                    numberOfAttendees: widget.numberOfAttendees,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              backgroundColor: _primaryColor,
            ),
            child: const Text('Select Seats'),
          ),
        ],
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  final Color color;
  final double dashWidth;
  final double gapWidth;
  final bool isVertical;
  
  DashedLinePainter({
    required this.color,
    required this.dashWidth,
    required this.gapWidth,
    this.isVertical = false,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = isVertical ? size.width : size.height;
    
    final count = isVertical
        ? (size.height / (dashWidth + gapWidth)).floor()
        : (size.width / (dashWidth + gapWidth)).floor();
    
    for (int i = 0; i < count; i++) {
      final start = (dashWidth + gapWidth) * i;
      
      if (isVertical) {
        canvas.drawLine( 
          Offset(0, start),
          Offset(0, start + dashWidth),
          paint,
        );
      } else {
        canvas.drawLine(
          Offset(start, 0),
          Offset(start + dashWidth, 0),
          paint,
        );
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

