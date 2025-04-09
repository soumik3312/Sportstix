import 'package:flutter/material.dart';

class PersistentChatbot extends StatefulWidget {
  final VoidCallback onTap;
  final VoidCallback onClose;

  const PersistentChatbot({
    Key? key,
    required this.onTap,
    required this.onClose,
  }) : super(key: key);

  @override
  State<PersistentChatbot> createState() => _PersistentChatbotState();
}

class _PersistentChatbotState extends State<PersistentChatbot> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool _isExpanded = false;
  String _message = "Hi there! Need help with booking tickets?";
  final List<String> _messages = [
    "Hi there! Need help with booking tickets?",
    "Want to find matches near you?",
    "Looking for the best seats?",
    "Need help with payment options?",
  ];
  int _messageIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    
    // Start pulsing animation
    _animationController.repeat(reverse: true);
    
    // Auto-expand after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isExpanded = true;
        });
      }
    });
    
    // Cycle through messages
    _startMessageCycle();
  }

  void _startMessageCycle() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _isExpanded) {
        setState(() {
          _messageIndex = (_messageIndex + 1) % _messages.length;
          _message = _messages[_messageIndex];
        });
        _startMessageCycle();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_isExpanded) {
          widget.onTap();
        } else {
          setState(() {
            _isExpanded = true;
            _startMessageCycle();
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: _isExpanded ? 250 : 60,
        height: _isExpanded ? 100 : 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_isExpanded ? 16 : 30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Colors.blue.shade100,
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            // Main content
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: _isExpanded
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.support_agent,
                                color: Colors.blue.shade700,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Chat Assistant',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Text(
                            _message,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.support_agent,
                            color: Colors.blue.shade700,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
            ),
            
            // Close button
            if (_isExpanded)
              Positioned(
                right: 8,
                top: 8,
                child: InkWell(
                  onTap: widget.onClose,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.grey[700],
                      size: 14,
                    ),
                  ),
                ),
              ),
              
            // Tap to chat indicator
            if (_isExpanded)
              Positioned(
                right: 12,
                bottom: 12,
                child: FadeTransition(
                  opacity: _opacityAnimation,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.touch_app,
                          color: Colors.blue.shade700,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Tap to chat',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

