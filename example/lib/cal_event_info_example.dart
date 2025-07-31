import 'package:flutter/material.dart';
import 'package:custom_calendar_bhagavati/src/custom/cal_event_info.dart';

class CalEventInfoExample extends StatelessWidget {
  const CalEventInfoExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CalEventInfo Examples'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Simple event
            CalEventInfo(
              width: double.infinity,
              eventTitle: 'Team Meeting',
              startTime: DateTime.now().add(const Duration(hours: 2)),
              endTime: DateTime.now().add(const Duration(hours: 3)),
              location: 'Conference Room A',
              eventColor: Colors.blue,
            ),
            
            const SizedBox(height: 16),
            
            // All-day event
            CalEventInfo(
              width: double.infinity,
              eventTitle: 'Company Retreat',
              isAllDay: true,
              eventDescription: 'Annual company retreat with team building activities and workshops.',
              location: 'Mountain Resort',
              eventColor: Colors.green,
              attendees: const [
                'John Doe',
                'Jane Smith',
                'Mike Johnson',
                'Sarah Wilson',
                'Tom Brown',
                'Lisa Davis',
                'Chris Lee',
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Event with detailed information
            CalEventInfo(
              width: double.infinity,
              eventTitle: 'Product Launch Presentation',
              startTime: DateTime.now().add(const Duration(days: 1, hours: 10)),
              endTime: DateTime.now().add(const Duration(days: 1, hours: 12)),
              eventDescription: 'Presenting our new product features to stakeholders and potential clients. This is a crucial meeting for our Q4 goals.',
              location: 'Main Auditorium, Building B',
              eventColor: Colors.orange,
              attendees: const [
                'CEO',
                'Product Manager',
                'Marketing Team',
                'Sales Team',
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Minimal event (no details)
            CalEventInfo(
              width: double.infinity,
              eventTitle: 'Quick Standup',
              startTime: DateTime.now().add(const Duration(minutes: 30)),
              endTime: DateTime.now().add(const Duration(minutes: 45)),
              eventColor: Colors.purple,
              showDetails: false,
            ),
            
            const SizedBox(height: 16),
            
            // Multi-day event
            CalEventInfo(
              width: double.infinity,
              eventTitle: 'Tech Conference 2024',
              startTime: DateTime.now().add(const Duration(days: 7)),
              endTime: DateTime.now().add(const Duration(days: 9)),
              eventDescription: 'Three-day technology conference featuring the latest innovations in software development, AI, and cloud computing.',
              location: 'Convention Center Downtown',
              eventColor: Colors.red,
              attendees: const [
                'Development Team',
                'Architecture Team',
                'DevOps Team',
              ],
            ),
          ],
        ),
      ),
    );
  }
}