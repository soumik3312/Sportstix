import 'package:flutter/material.dart';
import 'package:sports_ticket_booking/theme/app_theme.dart';
import '../models/match.dart';
import '../widgets/attendees_selector.dart';
import 'seat_selection_screen.dart';
import 'holographic_stadium_screen.dart';

class MatchDetailsScreen extends StatelessWidget {
  final Match match;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  const MatchDetailsScreen({
    Key? key,
    required this.match,
    required this.isFavorite,
    required this.onToggleFavorite,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;
    final responsivePadding = AppTheme.getResponsivePadding(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: screenSize.height * 0.25,
            pinned: true,
            centerTitle: true,
            flexibleSpace: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final top = constraints.biggest.height;
                return FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: top <= kToolbarHeight + 20
                      ? Text(
                          match.matchTitle,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.visible,
                          maxLines: 2,
                        )
                      : null,
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        color: Theme.of(context).primaryColor,
                        child: const Icon(
                          Icons.sports,
                          size: 80,
                          color: Colors.white24,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Text(
                          match.matchTitle,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 18 : 22,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.visible,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : null,
                ),
                onPressed: onToggleFavorite,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: responsivePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth < 600) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow(
                              Icons.calendar_today,
                              'Date & Time',
                              '${_formatDate(match.dateTime)} at ${_formatTime(match.dateTime)}',
                            ),
                            SizedBox(height: AppTheme.getResponsiveSpacing(context)),
                            _buildInfoRow(
                              Icons.location_on,
                              'Venue',
                              match.venue,
                            ),
                            SizedBox(height: AppTheme.getResponsiveSpacing(context)),
                            _buildInfoRow(
                              Icons.category,
                              'Category',
                              match.categoryName,
                            ),
                          ],
                        );
                      } else {
                        return Row(
                          children: [
                            Expanded(
                              child: _buildInfoRow(
                                Icons.calendar_today,
                                'Date & Time',
                                '${_formatDate(match.dateTime)} at ${_formatTime(match.dateTime)}',
                              ),
                            ),
                            Expanded(
                              child: _buildInfoRow(
                                Icons.location_on,
                                'Venue',
                                match.venue,
                              ),
                            ),
                            Expanded(
                              child: _buildInfoRow(
                                Icons.category,
                                'Category',
                                match.categoryName,
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                  SizedBox(height: AppTheme.getResponsiveSpacing(context, factor: 1.5)),
                  Text(
                    'Ticket Prices',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: AppTheme.getResponsiveSpacing(context, factor: 0.5)),
                  _buildTicketPricesList(),
                  SizedBox(height: AppTheme.getResponsiveSpacing(context, factor: 1.5)),
                  if (match.isLive) _buildLiveMatchSection(),
                  if (match.isLive) SizedBox(height: AppTheme.getResponsiveSpacing(context)),
                  _build3DViewButton(context),
                  SizedBox(height: AppTheme.getResponsiveSpacing(context, factor: 2)),
                  _buildBookTicketsButton(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }

  Widget _buildTicketPricesList() {
    return Card(
      elevation: 0,
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: match.ticketPrices.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.key, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  Text('₹${entry.value.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLiveMatchSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8)),
            child: const Row(
              children: [
                Icon(Icons.fiber_manual_record, color: Colors.white, size: 12),
                SizedBox(width: 4),
                Text('LIVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'This match is currently in progress. Get live updates!',
              style: TextStyle(fontSize: 14),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward, color: Colors.red),
            onPressed: () {
              // Navigate to live updates
            },
          ),
        ],
      ),
    );
  }

  Widget _build3DViewButton(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    return OutlinedButton.icon(
      onPressed: () {
        _showAttendeesSelector(context, true);
      },
      icon: const Icon(Icons.view_in_ar),
      label: Text(
        'Book with 3D Stadium View',
        style: TextStyle(fontSize: isSmallScreen ? 13 : 16),
      ),
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          vertical: isSmallScreen ? 10 : 12,
          horizontal: isSmallScreen ? 12 : 16,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildBookTicketsButton(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          _showAttendeesSelector(context, false);
        },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 14 : 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          'Book Tickets',
          style: TextStyle(fontSize: isSmallScreen ? 15 : 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _showAttendeesSelector(BuildContext context, bool use3DView) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => AttendeesSelector(
        onContinue: (numberOfAttendees) {
          Navigator.pop(context);
          if (use3DView) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HolographicStadiumScreen(
                  match: match,
                  numberOfAttendees: numberOfAttendees,
                ),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SeatSelectionScreen(
                  match: match,
                  numberOfAttendees: numberOfAttendees,
                ),
              ),
            );
          }
        },
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dateTime.day} ${months[dateTime.month - 1]}, ${dateTime.year}';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
}
