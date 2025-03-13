import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class MedicineReminderScreen extends StatefulWidget {
  const MedicineReminderScreen({super.key});

  @override
  State<MedicineReminderScreen> createState() => _MedicineReminderScreenState();
}

class _MedicineReminderScreenState extends State<MedicineReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  TimeOfDay? _morningTime;
  TimeOfDay? _afternoonTime;
  TimeOfDay? _eveningTime;
  
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _notificationsInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  Future<void> _initializeNotifications() async {
    try {
      tz.initializeTimeZones();
      
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      final initialized = await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('Notification clicked: ${response.payload}');
        },
      );

      setState(() {
        _notificationsInitialized = initialized ?? false;
      });
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
      setState(() {
        _notificationsInitialized = false;
      });
    }
  }

  Future<void> _scheduleNotification(String medicine, TimeOfDay time) async {
    if (!_notificationsInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notifications are not initialized')),
      );
      return;
    }

    try {
      final now = DateTime.now();
      var scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      var scheduledTime = tz.TZDateTime.from(scheduledDate, tz.local);

      // If the time is in the past, schedule for next day
      if (scheduledTime.isBefore(tz.TZDateTime.now(tz.local))) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }

      const androidDetails = AndroidNotificationDetails(
        'medicine_reminders',
        'Medicine Reminders',
        channelDescription: 'Reminders to take medicines',
        importance: Importance.max,
        priority: Priority.high,
        enableLights: true,
        enableVibration: true,
        sound: RawResourceAndroidNotificationSound('notification_sound'),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'notification_sound.aiff',
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final uniqueId = time.hour * 60 + time.minute;
      
      await _notifications.zonedSchedule(
        uniqueId,
        'Medicine Reminder',
        'Time to take $medicine',
        scheduledTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      debugPrint('Scheduled notification for $medicine at ${time.format(context)}');
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to schedule notification: $e')),
      );
    }
  }

  Future<void> _addMedicine() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final medicine = {
        'name': _nameController.text.trim(),
        'dosage': _dosageController.text.trim(),
        'morningTime': _morningTime?.format(context),
        'afternoonTime': _afternoonTime?.format(context),
        'eveningTime': _eveningTime?.format(context),
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('medicines')
          .add(medicine);

      if (_morningTime != null) {
        await _scheduleNotification(_nameController.text, _morningTime!);
      }
      if (_afternoonTime != null) {
        await _scheduleNotification(_nameController.text, _afternoonTime!);
      }
      if (_eveningTime != null) {
        await _scheduleNotification(_nameController.text, _eveningTime!);
      }

      if (mounted) {
        _resetForm();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medicine reminder added successfully')),
        );
      }
    } catch (e) {
      debugPrint('Error adding medicine: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding medicine: $e')),
        );
      }
    }
  }

  void _resetForm() {
    _nameController.clear();
    _dosageController.clear();
    setState(() {
      _morningTime = null;
      _afternoonTime = null;
      _eveningTime = null;
    });
  }

  Future<void> _selectTime(BuildContext context, String period) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null && mounted) {
      setState(() {
        switch (period) {
          case 'morning':
            _morningTime = picked;
            break;
          case 'afternoon':
            _afternoonTime = picked;
            break;
          case 'evening':
            _eveningTime = picked;
            break;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine Reminders'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset(
              'images/medicine-pills.webp',
              height: 100,
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Medicine Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.medication),
                    ),
                    validator: (value) =>
                        value?.trim().isEmpty == true ? 'Please enter medicine name' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _dosageController,
                    decoration: const InputDecoration(
                      labelText: 'Dosage',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.scale),
                    ),
                    validator: (value) =>
                        value?.trim().isEmpty == true ? 'Please enter dosage' : null,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Reminder Times',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _TimePickerButton(
                        label: 'Morning',
                        time: _morningTime,
                        onTap: () => _selectTime(context, 'morning'),
                      ),
                      _TimePickerButton(
                        label: 'Afternoon',
                        time: _afternoonTime,
                        onTap: () => _selectTime(context, 'afternoon'),
                      ),
                      _TimePickerButton(
                        label: 'Evening',
                        time: _eveningTime,
                        onTap: () => _selectTime(context, 'evening'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _addMedicine,
                    icon: const Icon(Icons.add_alarm),
                    label: const Text('Add Medicine Reminder'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimePickerButton extends StatelessWidget {
  final String label;
  final TimeOfDay? time;
  final VoidCallback onTap;

  const _TimePickerButton({
    required this.label,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).primaryColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              time?.format(context) ?? 'Set Time',
              style: TextStyle(
                color: time != null ? Theme.of(context).primaryColor : Colors.grey,
                fontWeight: time != null ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
