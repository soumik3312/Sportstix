import 'package:flutter/material.dart';

/// A utility class to help with responsive design
class ResponsiveHelper {
  /// Returns true if the screen width is less than 360 pixels
  static bool isSmallMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 360;
  }

  /// Returns true if the screen width is between 360 and 600 pixels
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width >= 360 && 
           MediaQuery.of(context).size.width < 600;
  }

  /// Returns true if the screen width is between 600 and 900 pixels
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600 && 
           MediaQuery.of(context).size.width < 900;
  }

  /// Returns true if the screen width is greater than 900 pixels
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 900;
  }

  /// Returns a value based on the screen size
  static T valueBasedOnScreenSize<T>({
    required BuildContext context,
    required T mobileSmall,
    required T mobile,
    required T tablet,
    required T desktop,
  }) {
    if (isSmallMobile(context)) {
      return mobileSmall;
    } else if (isMobile(context)) {
      return mobile;
    } else if (isTablet(context)) {
      return tablet;
    } else {
      return desktop;
    }
  }

  /// Returns a responsive font size based on the screen width
  static double getResponsiveFontSize(BuildContext context, double baseFontSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Scale factor based on screen width
    final scaleFactor = screenWidth / 400; // Base scale on a 400px reference width
    final responsiveScale = scaleFactor.clamp(0.8, 1.2); // Limit scaling range
    
    return baseFontSize * responsiveScale;
  }

  /// Returns a responsive icon size based on the screen width
  static double getResponsiveIconSize(BuildContext context, double baseIconSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Scale factor based on screen width
    final scaleFactor = screenWidth / 400; // Base scale on a 400px reference width
    final responsiveScale = scaleFactor.clamp(0.8, 1.2); // Limit scaling range
    
    return baseIconSize * responsiveScale;
  }

  /// Returns a responsive padding based on the screen width
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < 360) {
      return const EdgeInsets.all(8.0);
    } else if (screenWidth < 600) {
      return const EdgeInsets.all(16.0);
    } else if (screenWidth < 900) {
      return const EdgeInsets.all(24.0);
    } else {
      return const EdgeInsets.all(32.0);
    }
  }

  /// Returns a responsive spacing based on the screen width
  static double getResponsiveSpacing(BuildContext context, {double factor = 1.0}) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < 360) {
      return 8.0 * factor;
    } else if (screenWidth < 600) {
      return 16.0 * factor;
    } else if (screenWidth < 900) {
      return 24.0 * factor;
    } else {
      return 32.0 * factor;
    }
  }

  /// Returns a responsive width constraint based on the screen width
  static double getResponsiveWidth(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.width * (percentage / 100);
  }

  /// Returns a responsive height constraint based on the screen height
  static double getResponsiveHeight(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.height * (percentage / 100);
  }

  /// Returns a responsive width for a card based on the screen width
  static double getResponsiveCardWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < 360) {
      return screenWidth * 0.9;
    } else if (screenWidth < 600) {
      return screenWidth * 0.85;
    } else if (screenWidth < 900) {
      return 500;
    } else {
      return 600;
    }
  }
}

