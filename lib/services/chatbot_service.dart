class ChatbotService {
  String getBotResponse(String userMessage) {
    final String lowercaseMessage = userMessage.toLowerCase();
    
    // Ticket booking related queries
    if (lowercaseMessage.contains('book') && lowercaseMessage.contains('ticket') ||
        lowercaseMessage.contains('how to book') ||
        lowercaseMessage.contains('booking procedure')) {
      return "To book tickets, follow these steps:\n\n"
          "1. Select your location\n"
          "2. Choose a sport\n"
          "3. Browse available matches\n"
          "4. Select a match\n"
          "5. Choose the number of attendees\n"
          "6. Select your seats\n"
          "7. Complete payment\n\n"
          "You can also use our 3D stadium view to select seats visually!";
    }
    
    // Match details related queries
    else if (lowercaseMessage.contains('match') && 
            (lowercaseMessage.contains('detail') || 
             lowercaseMessage.contains('info') || 
             lowercaseMessage.contains('update'))) {
      return "Match details include information about teams, venue, date, time, and ticket prices. "
          "You can view live updates for ongoing matches. "
          "To get updates about a specific match, add it to your favorites and enable reminders!";
    }
    
    // Payment related queries
    else if (lowercaseMessage.contains('payment') || 
            lowercaseMessage.contains('pay') || 
            lowercaseMessage.contains('card') ||
            lowercaseMessage.contains('upi')) {
      return "We support multiple payment methods:\n\n"
          "• Credit/Debit Cards\n"
          "• UPI (Google Pay, PhonePe, etc.)\n"
          "• Net Banking\n"
          "• Digital Wallets (Paytm, Amazon Pay)\n\n"
          "All transactions are secure and encrypted. If you face any payment issues, please let me know!";
    }
    
    // Venue related queries
    else if (lowercaseMessage.contains('venue') || 
             lowercaseMessage.contains('stadium') || 
             lowercaseMessage.contains('arena') ||
             lowercaseMessage.contains('location')) {
      return "Our app provides detailed information about venues including seating arrangements. "
          "You can use the 3D holographic stadium view to explore the venue and select your preferred seats. "
          "This feature helps you understand the view from your selected seats before booking!";
    }
    
    // Refund related queries
    else if (lowercaseMessage.contains('refund') || 
             lowercaseMessage.contains('cancel') || 
             lowercaseMessage.contains('reschedule')) {
      return "For ticket cancellations and refunds:\n\n"
          "• Cancellations made 48+ hours before the match: 100% refund\n"
          "• Cancellations made 24-48 hours before the match: 50% refund\n"
          "• Cancellations made less than 24 hours before the match: No refund\n\n"
          "To cancel a booking, go to My Bookings section and select the Cancel option.";
    }
    
    // 3D stadium view related queries
    else if (lowercaseMessage.contains('3d') || 
             lowercaseMessage.contains('holograph') || 
             lowercaseMessage.contains('stadium view')) {
      return "Our 3D holographic stadium view allows you to:\n\n"
          "• Explore the venue in a virtual 3D environment\n"
          "• See the view from different seating sections\n"
          "• Select seats directly from the 3D model\n"
          "• Understand the stadium layout better\n\n"
          "This feature is available when booking tickets for any match!";
    }
    
    // Reminder related queries
    else if (lowercaseMessage.contains('reminder') || 
             lowercaseMessage.contains('notification') || 
             lowercaseMessage.contains('alert')) {
      return "You can set reminders for your favorite matches! When you add a match to favorites, "
          "you'll be asked if you want to set a reminder. Reminders are sent 3 hours before the match starts. "
          "You can manage your reminders in the Favorites section.";
    }
    
    // Greeting
    else if (lowercaseMessage.contains('hi') || 
             lowercaseMessage.contains('hello') || 
             lowercaseMessage.contains('hey')) {
      return "Hello! How can I assist you with your sports ticket booking today?";
    }
    
    // Thank you
    else if (lowercaseMessage.contains('thank') || 
             lowercaseMessage.contains('thanks')) {
      return "You're welcome! Is there anything else I can help you with?";
    }
    
    // Default response
    else {
      return "I'm not sure I understand your question. You can ask me about:\n\n"
          "• Ticket booking procedure\n"
          "• Match details and updates\n"
          "• Venue information\n"
          "• Payment options\n"
          "• Refund policy\n"
          "• 3D stadium view\n"
          "• Match reminders";
    }
  }
}

