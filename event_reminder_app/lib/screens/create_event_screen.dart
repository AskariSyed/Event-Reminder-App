import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_reminder_app/services/notification_services.dart';
import 'package:event_reminder_app/widgets/bottom_nav_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String location = '';
  String description = '';
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool notificationEnabled = false;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null && mounted) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );

    if (picked != null && mounted) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() ||
        selectedDate == null ||
        selectedTime == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please complete all required fields.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          ),
        );
      }
      return;
    }

    _formKey.currentState!.save();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please log in to create an event.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          ),
        );
      }
      return;
    }

    // Combine date and time
    final combinedDateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    final tzScheduledDateTime = tz.TZDateTime.from(combinedDateTime, tz.local);
    if (tzScheduledDateTime.isBefore(tz.TZDateTime.now(tz.local))) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Cannot schedule an event in the past.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          ),
        );
      }
      return;
    }

    // Format date and time
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');
    final formattedDate = dateFormat.format(combinedDateTime);
    final formattedTime = timeFormat.format(combinedDateTime);

    final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    final newEvent = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'remainingTime': 'TBC',
      'title': title,
      'date': formattedDate,
      'time': formattedTime,
      'location': location,
      'description': description,
      'timeColor': '0xFF6F61EF',
      'userId': user.uid,
      'notificationId': notificationEnabled ? notificationId : null,
    };

    try {
      await FirebaseFirestore.instance.collection('events').add(newEvent);
      if (notificationEnabled) {
        await scheduleNotification(
          id: notificationId,
          title: title,
          body: '📍 $location\n📝 $description',
          scheduledDateTime: combinedDateTime,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Event created successfully!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          ),
        );
        Navigator.pop(context, newEvent);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error creating event: $e',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          ),
        );
      }
    }
  }

  Widget buildCard({required Widget child}) {
    return Card(
      elevation: 3,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Create Event'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: Theme.of(context).appBarTheme.elevation,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              buildCard(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Event Title',
                    border: InputBorder.none,
                    labelStyle: Theme.of(context).textTheme.bodyMedium,
                  ),
                  validator:
                      (value) => value!.isEmpty ? 'Please enter a title' : null,
                  onSaved: (value) => title = value!,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              const SizedBox(height: 12),
              buildCard(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Location',
                    border: InputBorder.none,
                    labelStyle: Theme.of(context).textTheme.bodyMedium,
                  ),
                  onSaved: (value) => location = value ?? '',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: buildCard(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          selectedDate == null
                              ? 'Select Date'
                              : DateFormat('yyyy-MM-dd').format(selectedDate!),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        trailing: Icon(
                          Icons.calendar_today,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        onTap: _pickDate,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: buildCard(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          selectedTime == null
                              ? 'Select Time'
                              : selectedTime!.format(context),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        trailing: Icon(
                          Icons.access_time,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        onTap: _pickTime,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              buildCard(
                child: TextFormField(
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Description (Optional)',
                    border: InputBorder.none,
                    labelStyle: Theme.of(context).textTheme.bodyMedium,
                  ),
                  onSaved: (value) => description = value ?? '',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              const SizedBox(height: 12),
              buildCard(
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Enable Notification',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  value: notificationEnabled,
                  onChanged: (value) {
                    setState(() {
                      notificationEnabled = value;
                    });
                  },
                  activeColor: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                style: Theme.of(context).elevatedButtonTheme.style,
                child: Text(
                  'Create Event',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }
}
