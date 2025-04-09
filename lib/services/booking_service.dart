import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sports_ticket_booking/models/sport.dart';
import 'dart:convert';
import '../models/booking.dart';
import '../models/match.dart';
import '../models/seat.dart';
import '../services/auth_service.dart';

class BookingService extends ChangeNotifier {
  List<Booking> _bookings = [];
  bool _isLoading = true;
  final AuthService _authService;

  BookingService(this._authService) {
    _loadBookings();
    
    // Listen for auth changes to reload bookings when user changes
    _authService.addListener(_handleAuthChange);
  }

  @override
  void dispose() {
    _authService.removeListener(_handleAuthChange);
    super.dispose();
  }

  void _handleAuthChange() {
    // Reload bookings when auth status changes
    if (_authService.status == AuthStatus.authenticated) {
      _loadBookings();
    } else if (_authService.status == AuthStatus.unauthenticated) {
      // Clear bookings when user logs out
      _bookings = [];
      notifyListeners();
    }
  }

  List<Booking> get bookings => _bookings;
  bool get isLoading => _isLoading;

  Future<void> _loadBookings() async {
    if (_authService.currentUser == null) {
      _bookings = [];
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      notifyListeners();
      
      final prefs = await SharedPreferences.getInstance();
      final allBookingsJson = prefs.getStringList('all_bookings') ?? [];
      
      // Filter bookings by current user ID
      final currentUserId = _authService.currentUser!.id;
      _bookings = allBookingsJson
          .map((json) => _bookingFromJson(jsonDecode(json)))
          .where((booking) => booking.userId == currentUserId)
          .toList();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading bookings: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveBookings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get all existing bookings first
      final allBookingsJson = prefs.getStringList('all_bookings') ?? [];
      final allBookings = allBookingsJson
          .map((json) => _bookingFromJson(jsonDecode(json)))
          .toList();
      
      // Remove current user's bookings from the list
      final currentUserId = _authService.currentUser!.id;
      allBookings.removeWhere((booking) => booking.userId == currentUserId);
      
      // Add current user's updated bookings
      allBookings.addAll(_bookings);
      
      // Save all bookings back to storage
      final updatedBookingsJson = allBookings
          .map((booking) => jsonEncode(_bookingToJson(booking)))
          .toList();
      
      await prefs.setStringList('all_bookings', updatedBookingsJson);
    } catch (e) {
      print('Error saving bookings: $e');
    }
  }

  Future<Booking> addBooking(Booking booking) async {
    if (_authService.currentUser == null) {
      throw Exception('User must be logged in to add a booking');
    }
    
    // Ensure the booking has the current user's ID
    final bookingWithUserId = booking.copyWith(
      userId: _authService.currentUser!.id,
    );
    
    _bookings.add(bookingWithUserId);
    notifyListeners();
    await _saveBookings();
    return bookingWithUserId;
  }

  Future<void> removeBooking(String bookingId) async {
    _bookings.removeWhere((booking) => booking.id == bookingId);
    notifyListeners();
    await _saveBookings();
  }

  Future<void> updateBooking(Booking updatedBooking) async {
    final index = _bookings.indexWhere((booking) => booking.id == updatedBooking.id);
    if (index != -1) {
      // Ensure we preserve the user ID
      final bookingWithUserId = updatedBooking.copyWith(
        userId: _bookings[index].userId,
      );
      
      _bookings[index] = bookingWithUserId;
      notifyListeners();
      await _saveBookings();
    }
  }

  Future<bool> cancelBooking(String bookingId, String reason) async {
    try {
      final index = _bookings.indexWhere((booking) => booking.id == bookingId);
      if (index == -1) return false;
      
      final booking = _bookings[index];
      
      // Check if match is already past or too close to start time
      final now = DateTime.now();
      final matchTime = booking.match.dateTime;
      
      // Cannot cancel if match is already past
      if (now.isAfter(matchTime)) {
        return false;
      }
      
      // Calculate hours remaining until match
      final hoursRemaining = matchTime.difference(now).inHours;
      
      // Calculate refund amount based on cancellation policy
      double refundPercentage;
      if (hoursRemaining > 72) {
        // More than 72 hours: 90% refund
        refundPercentage = 0.9;
      } else if (hoursRemaining > 48) {
        // 48-72 hours: 75% refund
        refundPercentage = 0.75;
      } else if (hoursRemaining > 24) {
        // 24-48 hours: 50% refund
        refundPercentage = 0.5;
      } else if (hoursRemaining > 6) {
        // 6-24 hours: 25% refund
        refundPercentage = 0.25;
      } else {
        // Less than 6 hours: no refund
        refundPercentage = 0.0;
      }
      
      final refundAmount = booking.totalAmount * refundPercentage;
      
      // Remove the booking instead of updating it
      _bookings.removeAt(index);
      notifyListeners();
      await _saveBookings();
      
      return true;
    } catch (e) {
      print('Error cancelling booking: $e');
      return false;
    }
  }

  // Get cancellation policy details for a booking
  Map<String, dynamic> getCancellationPolicyDetails(String bookingId) {
    final booking = _bookings.firstWhere(
      (booking) => booking.id == bookingId,
      orElse: () => throw Exception('Booking not found'),
    );
    
    final now = DateTime.now();
    final matchTime = booking.match.dateTime;
    
    // Cannot cancel if match is already past
    if (now.isAfter(matchTime)) {
      return {
        'canCancel': false,
        'reason': 'Match has already started or ended',
        'refundPercentage': 0.0,
        'refundAmount': 0.0,
      };
    }
    
    // Calculate hours remaining until match
    final hoursRemaining = matchTime.difference(now).inHours;
    
    // Calculate refund amount based on cancellation policy
    double refundPercentage;
    String timeFrame;
    
    if (hoursRemaining > 72) {
      // More than 72 hours: 90% refund
      refundPercentage = 0.9;
      timeFrame = 'More than 72 hours before match';
    } else if (hoursRemaining > 48) {
      // 48-72 hours: 75% refund
      refundPercentage = 0.75;
      timeFrame = 'Between 48-72 hours before match';
    } else if (hoursRemaining > 24) {
      // 24-48 hours: 50% refund
      refundPercentage = 0.5;
      timeFrame = 'Between 24-48 hours before match';
    } else if (hoursRemaining > 6) {
      // 6-24 hours: 25% refund
      refundPercentage = 0.25;
      timeFrame = 'Between 6-24 hours before match';
    } else {
      // Less than 6 hours: no refund
      refundPercentage = 0.0;
      timeFrame = 'Less than 6 hours before match';
    }
    
    final refundAmount = booking.totalAmount * refundPercentage;
    
    return {
      'canCancel': true,
      'timeFrame': timeFrame,
      'hoursRemaining': hoursRemaining,
      'refundPercentage': refundPercentage,
      'refundAmount': refundAmount,
      'totalAmount': booking.totalAmount,
    };
  }

  // Convert Booking to JSON
  Map<String, dynamic> _bookingToJson(Booking booking) {
    return {
      'id': booking.id,
      'userId': booking.userId,
      'match': {
        'id': booking.match.id,
        'team1': booking.match.team1,
        'team2': booking.match.team2,
        'dateTime': booking.match.dateTime.toIso8601String(),
        'venue': booking.match.venue,
        'sportType': booking.match.sportType.index,
        'category': booking.match.category.index,
        'location': booking.match.location,
        'ticketPrices': booking.match.ticketPrices,
        'imagePath': booking.match.imagePath,
        'isLive': booking.match.isLive,
        'hasReminder': booking.match.hasReminder,
      },
      'selectedSeats': booking.selectedSeats.map((seat) => {
        'id': seat.id,
        'row': seat.row,
        'number': seat.number,
        'category': seat.category.index,
        'price': seat.price,
        'isAvailable': seat.isAvailable,
        'isSelected': seat.isSelected,
      }).toList(),
      'numberOfAttendees': booking.numberOfAttendees,
      'bookingTime': booking.bookingTime.toIso8601String(),
      'totalAmount': booking.totalAmount,
      'paymentMethod': booking.paymentMethod,
      'bookingStatus': booking.bookingStatus,
      'cancellationTime': booking.cancellationTime?.toIso8601String(),
      'refundAmount': booking.refundAmount,
      'cancellationReason': booking.cancellationReason,
    };
  }

  // Convert JSON to Booking
  Booking _bookingFromJson(Map<String, dynamic> json) {
    final matchJson = json['match'];
    final match = Match(
      id: matchJson['id'],
      team1: matchJson['team1'],
      team2: matchJson['team2'],
      dateTime: DateTime.parse(matchJson['dateTime']),
      venue: matchJson['venue'],
      sportType: SportType.values[matchJson['sportType']],
      category: MatchCategory.values[matchJson['category']],
      location: matchJson['location'],
      ticketPrices: Map<String, double>.from(matchJson['ticketPrices']),
      imagePath: matchJson['imagePath'],
      isLive: matchJson['isLive'],
      hasReminder: matchJson['hasReminder'],
    );

    final seats = (json['selectedSeats'] as List).map((seatJson) => Seat(
      id: seatJson['id'],
      row: seatJson['row'],
      number: seatJson['number'],
      category: SeatCategory.values[seatJson['category']],
      price: seatJson['price'],
      isAvailable: seatJson['isAvailable'],
      isSelected: seatJson['isSelected'],
    )).toList();

    return Booking(
      id: json['id'],
      userId: json['userId'] ?? '',
      match: match,
      selectedSeats: seats,
      numberOfAttendees: json['numberOfAttendees'],
      bookingTime: DateTime.parse(json['bookingTime']),
      totalAmount: json['totalAmount'],
      paymentMethod: json['paymentMethod'],
      bookingStatus: json['bookingStatus'],
      cancellationTime: json['cancellationTime'] != null 
          ? DateTime.parse(json['cancellationTime']) 
          : null,
      refundAmount: json['refundAmount'],
      cancellationReason: json['cancellationReason'],
    );
  }
}

