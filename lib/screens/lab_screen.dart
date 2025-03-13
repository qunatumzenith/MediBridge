import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LabScreen extends StatelessWidget {
  const LabScreen({super.key});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $launchUri';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Static list of labs (to be replaced with dynamic data in future)
    final labs = [
      {
        'name': 'HealthCare Diagnostics',
        'address': '123 Main Street, City',
        'phone': '+1234567890',
        'services': ['Blood Tests', 'X-Ray', 'MRI', 'CT Scan'],
        'rating': 4.5,
      },
      {
        'name': 'City Medical Lab',
        'address': '456 Park Avenue, City',
        'phone': '+1234567891',
        'services': ['Blood Tests', 'Ultrasound', 'ECG'],
        'rating': 4.2,
      },
      {
        'name': 'Central Diagnostics',
        'address': '789 Hospital Road, City',
        'phone': '+1234567892',
        'services': ['Blood Tests', 'X-Ray', 'Pathology'],
        'rating': 4.7,
      },
      {
        'name': 'Modern Lab Services',
        'address': '321 Health Street, City',
        'phone': '+1234567893',
        'services': ['Blood Tests', 'MRI', 'Ultrasound', 'ECG'],
        'rating': 4.3,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Laboratories'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: labs.length,
        itemBuilder: (context, index) {
          final lab = labs[index];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          lab['name'] as String,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${lab['rating']}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    lab['address'] as String,
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Services:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (lab['services'] as List<String>)
                        .map(
                          (service) => Chip(
                            label: Text(service),
                            backgroundColor:
                                Theme.of(context).primaryColor.withOpacity(0.1),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _makePhoneCall(lab['phone'] as String),
                    icon: const Icon(Icons.phone),
                    label: const Text('Call Laboratory'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
} 