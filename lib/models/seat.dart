enum SeatCategory {
  vip,
  premium,
  regular
}

class Seat {
  final String id;
  final String row;
  final int number;
  final SeatCategory category;
  final double price;
  bool isAvailable;
  bool isSelected;

  Seat({
    required this.id,
    required this.row,
    required this.number,
    required this.category,
    required this.price,
    this.isAvailable = true,
    this.isSelected = false,
  });

  String get seatLabel => '$row$number';

  String get categoryName {
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

// Generate seats for a stadium
List<Seat> generateStadiumSeats(Map<String, double> ticketPrices) {
  final List<Seat> seats = [];
  
  // VIP Seats (Rows A-C)
  for (String row in ['A', 'B', 'C']) {
    for (int i = 1; i <= 20; i++) {
      seats.add(
        Seat(
          id: '$row$i',
          row: row,
          number: i,
          category: SeatCategory.vip,
          price: ticketPrices['VIP'] ?? 5000.0,
          isAvailable: true,
        ),
      );
    }
  }
  
  // Premium Seats (Rows D-H)
  for (String row in ['D', 'E', 'F', 'G', 'H']) {
    for (int i = 1; i <= 30; i++) {
      seats.add(
        Seat(
          id: '$row$i',
          row: row,
          number: i,
          category: SeatCategory.premium,
          price: ticketPrices['Premium'] ?? 3000.0,
          isAvailable: true,
        ),
      );
    }
  }
  
  // Regular Seats (Rows I-P)
  for (String row in ['I', 'J', 'K', 'L', 'M', 'N', 'O', 'P']) {
    for (int i = 1; i <= 40; i++) {
      seats.add(
        Seat(
          id: '$row$i',
          row: row,
          number: i,
          category: SeatCategory.regular,
          price: ticketPrices['Regular'] ?? 1500.0,
          isAvailable: true,
        ),
      );
    }
  }
  
  // Randomly mark some seats as unavailable
  final random = DateTime.now().millisecondsSinceEpoch;
  for (int i = 0; i < seats.length; i++) {
    if ((random + i) % 7 == 0) {
      seats[i].isAvailable = false;
    }
  }
  
  return seats;
}

// Generate seats for indoor venues
List<Seat> generateIndoorVenueSeats(Map<String, double> ticketPrices) {
  final List<Seat> seats = [];
  
  // VIP Seats (Rows A-B)
  for (String row in ['A', 'B']) {
    for (int i = 1; i <= 15; i++) {
      seats.add(
        Seat(
          id: '$row$i',
          row: row,
          number: i,
          category: SeatCategory.vip,
          price: ticketPrices['VIP'] ?? 2500.0,
          isAvailable: true,
        ),
      );
    }
  }
  
  // Premium Seats (Rows C-E)
  for (String row in ['C', 'D', 'E']) {
    for (int i = 1; i <= 20; i++) {
      seats.add(
        Seat(
          id: '$row$i',
          row: row,
          number: i,
          category: SeatCategory.premium,
          price: ticketPrices['Premium'] ?? 1500.0,
          isAvailable: true,
        ),
      );
    }
  }
  
  // Regular Seats (Rows F-J)
  for (String row in ['F', 'G', 'H', 'I', 'J']) {
    for (int i = 1; i <= 25; i++) {
      seats.add(
        Seat(
          id: '$row$i',
          row: row,
          number: i,
          category: SeatCategory.regular,
          price: ticketPrices['Regular'] ?? 800.0,
          isAvailable: true,
        ),
      );
    }
  }
  
  // Randomly mark some seats as unavailable
  final random = DateTime.now().millisecondsSinceEpoch;
  for (int i = 0; i < seats.length; i++) {
    if ((random + i) % 5 == 0) {
      seats[i].isAvailable = false;
    }
  }
  
  return seats;
}

