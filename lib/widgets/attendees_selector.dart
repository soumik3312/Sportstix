import 'package:flutter/material.dart';

class AttendeesSelector extends StatefulWidget {
  final Function(int) onContinue;

  const AttendeesSelector({
    Key? key,
    required this.onContinue,
  }) : super(key: key);

  @override
  State<AttendeesSelector> createState() => _AttendeesSelectorState();
}

class _AttendeesSelectorState extends State<AttendeesSelector> {
  int _numberOfAttendees = 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'How many people are attending?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _numberOfAttendees > 1
                    ? () {
                        setState(() {
                          _numberOfAttendees--;
                        });
                      }
                    : null,
                icon: const Icon(Icons.remove_circle_outline),
                iconSize: 32,
                color: _numberOfAttendees > 1 ? Theme.of(context).primaryColor : Colors.grey,
              ),
              Container(
                width: 80,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  _numberOfAttendees.toString(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: _numberOfAttendees < 10
                    ? () {
                        setState(() {
                          _numberOfAttendees++;
                        });
                      }
                    : null,
                icon: const Icon(Icons.add_circle_outline),
                iconSize: 32,
                color: _numberOfAttendees < 10 ? Theme.of(context).primaryColor : Colors.grey,
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onContinue(_numberOfAttendees);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

