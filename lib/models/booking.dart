import 'match.dart';
import 'seat.dart';

class Booking {
  final String id;
  final String userId;
  final Match match;
  final List<Seat> selectedSeats;
  final int numberOfAttendees;
  final DateTime bookingTime;
  final double totalAmount;
  final String paymentMethod;
  String bookingStatus;
  DateTime? cancellationTime;
  double? refundAmount;
  String? cancellationReason;

  Booking({
    required this.id,
    required this.userId,
    required this.match,
    required this.selectedSeats,
    required this.numberOfAttendees,
    required this.bookingTime,
    required this.totalAmount,
    required this.paymentMethod,
    this.bookingStatus = 'Confirmed',
    this.cancellationTime,
    this.refundAmount,
    this.cancellationReason,
  });

  // Create a copy of the booking with updated fields
  Booking copyWith({
    String? id,
    String? userId,
    Match? match,
    List<Seat>? selectedSeats,
    int? numberOfAttendees,
    DateTime? bookingTime,
    double? totalAmount,
    String? paymentMethod,
    String? bookingStatus,
    DateTime? cancellationTime,
    double? refundAmount,
    String? cancellationReason,
  }) {
    return Booking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      match: match ?? this.match,
      selectedSeats: selectedSeats ?? this.selectedSeats,
      numberOfAttendees: numberOfAttendees ?? this.numberOfAttendees,
      bookingTime: bookingTime ?? this.bookingTime,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      bookingStatus: bookingStatus ?? this.bookingStatus,
      cancellationTime: cancellationTime ?? this.cancellationTime,
      refundAmount: refundAmount ?? this.refundAmount,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }
}

