import 'package:flutter/material.dart';

class CulturalEventsScreen extends StatelessWidget {
  final List<Map<String, String>> events = List.generate(
    3,
        (index) => {
      'image': 'assets/plant.png', // Replace with your real asset path
      'title': "DrukYul's Literature Arts Festival",
      'date': '2-Aug-2025 to 4-Aug-2025',
    },
  );
  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> events = [
      {
        'image': 'assets/event1.jpg',
        'title': 'Bhutan Cultural Dance',
        'date': '25 June 2025',
      },
      {
        'image': 'assets/event2.jpg',
        'title': 'Traditional Festival Parade',
        'date': '30 June 2025',
      },
      {
        'image': 'assets/event3.jpg',
        'title': 'Monastery Art & Music',
        'date': '05 July 2025',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Cultural Events'),
        backgroundColor: Colors.green,
      ),
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.asset(
                      event['image']!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Event: ${event['title']}",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Date: ${event['date']}",
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

}
