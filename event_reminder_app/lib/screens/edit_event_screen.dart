import 'package:event_reminder_app/services/notification_services.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:event_reminder_app/widgets/bottom_nav_bar.dart';
import 'package:intl/intl.dart';

class EditEventScreen extends StatefulWidget {
  final Map<String, dynamic> event;
  final String documentId;

  const EditEventScreen({
    super.key,
    required this.event,
    required this.documentId,
  });

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  late String title;
  late String location;
  late String description;
  late DateTime? selectedDate;
  late TimeOfDay? selectedTime;
  late bool notificationEnabled;

  @override
  void initState() {
    super.initState();
    // Initialize fields with event data
    title = widget.event['title'] ?? '';
    location = widget.event['location'] ?? '';
    description = widget.event['description'] ?? '';
    notificationEnabled = widget.event['notificationId'] != null;

    selectedDate = _parseDate(widget.event['date']);
    selectedTime = _parseTime(widget.event['time']);
    if (selectedDate == null || selectedTime == null) {
      selectedDate ??= DateTime.now();
      selectedTime ??= TimeOfDay.now();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Failed to load event date/time, defaulting to now",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.surface,
          ),
        );
      });
    }
  }

  DateTime? _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) {
      print('Debug: Date string is null or empty in event: ${widget.event}');
      return null;
    }
    try {
      final parsedDate = DateFormat('EEEE, MMMM d, yyyy').parse(dateStr.trim());
      return parsedDate;
    } catch (e) {
      print('Debug: Error parsing date "$dateStr": $e, event: ${widget.event}');
      return null;
    }
  }

  TimeOfDay? _parseTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) {
      print('Debug: Time string is null or empty in event: ${widget.event}');
      return null;
    }
    try {
      final cleanedTimeString =
          timeStr
              .replaceAll(
                RegExp(r'[\u202F\u00A0\u2007\u2060\uFEFF\u200B]'),
                ' ',
              )
              .replaceAll(RegExp(r'[^\x00-\x7F]'), '')
              .replaceAll(RegExp(r'\s+'), ' ')
              .trim();
      final timeParts = cleanedTimeString.split(' ');
      if (timeParts.length != 2) {
        throw FormatException('Invalid time format: $cleanedTimeString');
      }

      final timeValue = timeParts[0];
      final period = timeParts[1].toUpperCase();

      final timeComponents = timeValue.split(':');
      if (timeComponents.length != 2) {
        throw FormatException('Invalid time components: $timeValue');
      }

      int hour = int.parse(timeComponents[0]);
      final minute = int.parse(timeComponents[1]);

      // Convert to 24-hour format
      if (period == 'PM' && hour != 12) {
        hour += 12;
      } else if (period == 'AM' && hour == 12) {
        hour = 0;
      }

      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      print('Debug: Error parsing time "$timeStr": $e, event: ${widget.event}');
      return null;
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
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

    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() &&
        selectedDate != null &&
        selectedTime != null) {
      _formKey.currentState!.save();

      final formattedDate = DateFormat(
        'EEEE, MMMM d, yyyy',
      ).format(selectedDate!);

      final timeFormatted = selectedTime!.format(context);
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Please log in to edit an event",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.surface,
          ),
        );
        return;
      }

      final combinedDateTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );

      int? notificationId = widget.event['notificationId'];
      if (notificationEnabled && notificationId == null) {
        notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      }

      final updatedEvent = {
        'id': widget.event['id'],
        'remainingTime': 'TBC',
        'title': title,
        'date': formattedDate,
        'time': timeFormatted,
        'location': location,
        'description': description,
        'timeColor': widget.event['timeColor'],
        'userId': user.uid,
        'notificationId': notificationEnabled ? notificationId : null,
      };

      await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.documentId) // Use the correct documentId
          .update(updatedEvent);

      if (notificationEnabled && notificationId != null) {
        if (widget.event['notificationId'] != null) {
          await cancelNotification(widget.event['notificationId']);
        }
        // Schedule new notification
        await scheduleNotification(
          id: notificationId,
          title: 'Event: $title',
          body: 'Reminder for your event at $timeFormatted',
          scheduledDateTime: combinedDateTime,
        );
      } else if (!notificationEnabled &&
          widget.event['notificationId'] != null) {
        // Cancel existing notification if notification is disabled
        await cancelNotification(widget.event['notificationId']);
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Event Updated Successfully",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              backgroundColor: Theme.of(context).colorScheme.surface,
            ),
          );
        }
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pop(context, updatedEvent);
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Please complete all fields",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
        ),
      );
    }
  }

  Widget buildCard({required Widget child}) {
    return Card(
      elevation: 3,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: child,
      ),
    );
  }

  String _formatDateDisplay(DateTime date) {
    return DateFormat('EEEE, MMMM d, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Edit Event"),
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
                  initialValue: title,
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
                  initialValue: location,
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
                              : _formatDateDisplay(selectedDate!),
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
                  initialValue: description,
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
                  'Update Event',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 0),
    );
  }
}
