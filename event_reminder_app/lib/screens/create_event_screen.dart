import 'package:flutter/material.dart';
import 'package:event_reminder_app/widgets/BottomNavBar.dart';
import 'package:event_reminder_app/mixin/event_list.dart';

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

  void _submitForm() {
    if (_formKey.currentState!.validate() &&
        selectedDate != null &&
        selectedTime != null) {
      _formKey.currentState!.save();

      // Format the date and time as desired
      final formattedDate =
          "${selectedDate!.weekday == DateTime.monday
              ? "Monday"
              : selectedDate!.weekday == DateTime.tuesday
              ? "Tuesday"
              : selectedDate!.weekday == DateTime.wednesday
              ? "Wednesday"
              : selectedDate!.weekday == DateTime.thursday
              ? "Thursday"
              : selectedDate!.weekday == DateTime.friday
              ? "Friday"
              : selectedDate!.weekday == DateTime.saturday
              ? "Saturday"
              : "Sunday"}, ${selectedDate!.month == 1
              ? "January"
              : selectedDate!.month == 2
              ? "February"
              : selectedDate!.month == 3
              ? "March"
              : selectedDate!.month == 4
              ? "April"
              : selectedDate!.month == 5
              ? "May"
              : selectedDate!.month == 6
              ? "June"
              : selectedDate!.month == 7
              ? "July"
              : selectedDate!.month == 8
              ? "August"
              : selectedDate!.month == 9
              ? "September"
              : selectedDate!.month == 10
              ? "October"
              : selectedDate!.month == 11
              ? "November"
              : "December"} ${selectedDate!.day}, ${selectedDate!.year}";

      final timeFormatted = selectedTime!.format(context);

      final newEvent = {
        'id': (events.length + 1).toString(),
        'remainingTime': 'TBC',
        'title': title,
        'date': formattedDate,
        'time': timeFormatted,
        'location': location,
        'description': description,
        'timeColor': '0xFF6F61EE',
      };

      events.add(newEvent);
      Navigator.pop(context, newEvent);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields")),
      );
    }
  }

  Widget buildCard({required Widget child}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create New Event"),
        backgroundColor: const Color(0xFFF1F4F8),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              buildCard(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Event Title',
                    border: InputBorder.none,
                  ),
                  validator:
                      (value) => value!.isEmpty ? 'Please enter a title' : null,
                  onSaved: (value) => title = value!,
                ),
              ),
              const SizedBox(height: 12),
              buildCard(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    border: InputBorder.none,
                  ),
                  onSaved: (value) => location = value ?? '',
                ),
              ),
              const SizedBox(height: 12),

              // Date and Time Row
              Row(
                children: [
                  Expanded(
                    child: buildCard(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          selectedDate == null
                              ? 'Select Date'
                              : '${selectedDate!.toLocal()}'.split(' ')[0],
                        ),
                        trailing: const Icon(Icons.calendar_today),
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
                        ),
                        trailing: const Icon(Icons.access_time),
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
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    border: InputBorder.none,
                  ),
                  onSaved: (value) => description = value ?? '',
                ),
              ),
              const SizedBox(height: 12),

              buildCard(
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Enable Notification'),
                  value: notificationEnabled,
                  onChanged: (value) {
                    setState(() {
                      notificationEnabled = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6F61EF),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Create Event'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(context),
    );
  }
}
