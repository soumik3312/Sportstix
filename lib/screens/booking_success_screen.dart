import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math';
import '../models/booking.dart';
import '../models/match.dart';
import '../models/seat.dart';
import '../services/booking_service.dart';
import '../services/auth_service.dart';
import '../services/email_service.dart';
import 'booking_confirmation_screen.dart';

class BookingSuccessScreen extends StatefulWidget {
  final Match match;
  final List<Seat> selectedSeats;
  final int numberOfAttendees;
  final double totalAmount;
  final String paymentMethod;

  const BookingSuccessScreen({
    Key? key,
    required this.match,
    required this.selectedSeats,
    required this.numberOfAttendees,
    required this.totalAmount,
    required this.paymentMethod,
  }) : super(key: key);

  @override
  State<BookingSuccessScreen> createState() => _BookingSuccessScreenState();
}

class _BookingSuccessScreenState extends State<BookingSuccessScreen> with TickerProviderStateMixin {
  late AnimationController _ticketAnimationController;
  late Animation<double> _ticketScaleAnimation;
  late Animation<double> _ticketRotationAnimation;

  late AnimationController _checkmarkAnimationController;
  late Animation<double> _checkmarkAnimation;

  late AnimationController _countAnimationController;
  late Animation<int> _countAnimation;

  bool _showDetails = false;
  late Booking _booking;
  bool _isProcessingBooking = true;

  @override
  void initState() {
    super.initState();
    
    // Get the current user ID
    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.currentUser?.id ?? 'unknown_user';
    
    // Create booking object with user ID
    _booking = Booking(
      id: 'BKG${DateTime.now().millisecondsSinceEpoch}',
      userId: userId, // Associate booking with current user
      match: widget.match,
      selectedSeats: widget.selectedSeats,
      numberOfAttendees: widget.numberOfAttendees,
      bookingTime: DateTime.now(),
      totalAmount: widget.totalAmount,
      paymentMethod: widget.paymentMethod,
    );
    
    // Add booking to service
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookingService>(context, listen: false).addBooking(_booking).then((_) {
        setState(() {
          _isProcessingBooking = false;
        });
      });
    });
    
    // Ticket animation
    _ticketAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _ticketScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ticketAnimationController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );
    
    _ticketRotationAnimation = Tween<double>(begin: -0.2, end: 0.0).animate(
      CurvedAnimation(
        parent: _ticketAnimationController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );
    
    // Checkmark animation
    _checkmarkAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _checkmarkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _checkmarkAnimationController,
        curve: Curves.elasticOut,
      ),
    );
    
    // Count animation
    _countAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _countAnimation = IntTween(begin: 0, end: widget.selectedSeats.length).animate(
      CurvedAnimation(
        parent: _countAnimationController,
        curve: Curves.easeOut,
      ),
    );
    
    // Start animations in sequence
    _ticketAnimationController.forward();
    
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        _checkmarkAnimationController.forward();
      }
    });
    
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        _countAnimationController.forward();
      }
    });
    
    // Show details after animations
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() {
          _showDetails = true;
        });
      }
    });
    
    // Navigate to confirmation screen after delay
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        _navigateToConfirmation();
      }
    });
  }

  void _navigateToConfirmation() {
    // Send email confirmation before navigating
    final emailService = Provider.of<EmailService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    
    if (authService.currentUser != null) {
      // Reset email status before sending
      emailService.resetEmailStatus();
      
      // Send confirmation email in the background
      emailService.sendTicketConfirmationEmail(
        authService.currentUser!,
        _booking,
      ).then((success) {
        // Email status will be shown on the confirmation screen
        print('Email sent: $success');
      });
    }
    
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => BookingConfirmationScreen(booking: _booking),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;
          
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _ticketAnimationController.dispose();
    _checkmarkAnimationController.dispose();
    _countAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade700,
              Colors.blue.shade900,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Background particles
              _buildParticles(),
              
              // Main content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Ticket animation
                    AnimatedBuilder(
                      animation: _ticketAnimationController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _ticketScaleAnimation.value,
                          child: Transform.rotate(
                            angle: _ticketRotationAnimation.value,
                            child: child,
                          ),
                        );
                      },
                      child: _buildTicketIcon(),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Success message
                    AnimatedOpacity(
                      opacity: _showDetails ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: Text(
                        'Booking Successful!',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Ticket count
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'You have booked ',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        AnimatedBuilder(
                          animation: _countAnimationController,
                          builder: (context, child) {
                            return Text(
                              '${_countAnimation.value}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                        Text(
                          ' tickets',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Ticket details
                    if (_showDetails) _buildTicketDetails(),
                    
                    const SizedBox(height: 40),
                    
                    // Processing message
                    AnimatedOpacity(
                      opacity: _showDetails ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Preparing your tickets and confirmation email...',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketIcon() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Ticket background
        Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
        ),
        
        // Ticket icon
        const Icon(
          Icons.confirmation_number,
          size: 80,
          color: Colors.blue,
        ),
        
        // Checkmark overlay
        Positioned(
          bottom: 10,
          right: 10,
          child: AnimatedBuilder(
            animation: _checkmarkAnimationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _checkmarkAnimation.value,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTicketDetails() {
    return AnimatedOpacity(
      opacity: _showDetails ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            _buildDetailRow(
              icon: Icons.sports,
              label: 'Match',
              value: widget.match.matchTitle,
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              icon: Icons.calendar_today,
              label: 'Date',
              value: _formatDate(widget.match.dateTime),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              icon: Icons.event_seat,
              label: 'Seats',
              value: widget.selectedSeats.map((s) => s.seatLabel).join(', '),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              icon: Icons.payments,
              label: 'Amount',
              value: '₹${widget.totalAmount.toStringAsFixed(2)}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.8),
          size: 18,
        ),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildParticles() {
    return IgnorePointer(
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: CustomPaint(
          painter: ParticlesPainter(),
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dateTime.day} ${months[dateTime.month - 1]}, ${dateTime.year} at ${_formatTime(dateTime)}';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
}

class ParticlesPainter extends CustomPainter {
  final Random random = Random();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    // Draw particles
    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = 1.0 + random.nextDouble() * 3.0;
      
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}



