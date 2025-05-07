import 'package:event_reminder_app/widgets/BottomNavBar.dart';
import 'package:event_reminder_app/widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:event_reminder_app/widgets/buildEventCard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:event_reminder_app/providers/user_provider.dart';

class Calenderscreen extends StatefulWidget {
  const Calenderscreen({super.key});

  static String routeName = 'CALENDER';
  static String routePath = '/calender';

  @override
  State<Calenderscreen> createState() => _CalenderScreen();
}

class _CalenderScreen extends State<Calenderscreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this)..addListener(() {
      setState(() {
        _calendarFormat =
            _tabController.index == 0
                ? CalendarFormat.month
                : CalendarFormat.week;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: buildAppBar("Calender"),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                labelStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                tabs: [Tab(text: 'Month'), Tab(text: 'Week')],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildCalendarView(context),
                  _buildCalendarView(context),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavBar(currentIndex: 1),
      ),
    );
  }

  Widget _buildCalendarView(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userId = userProvider.user?.uid;

    if (userId == null) {
      return Center(child: Text('User not logged in.'));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  blurRadius: 5,
                  color: Colors.black12,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: TableCalendar(
              firstDay: DateTime.utc(2025, 1, 1),
              lastDay: DateTime.utc(2035, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withAlpha(128),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleTextStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(fontSize: 14),
                weekendStyle: TextStyle(fontSize: 14),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 0, 0),
            child: Text(
              'Coming Up',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
          // Fetch events for the selected day
          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection('events')
                    .where('userId', isEqualTo: userId)
                    .where(
                      'date',
                      isEqualTo: _formatDateToString(_selectedDay),
                    ) // Call the helper function
                    .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error fetching events.'));
              }

              final events = snapshot.data?.docs ?? [];
              if (events.isEmpty) {
                return Center(child: Text('No upcoming events.'));
              }

              return ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index].data() as Map<String, dynamic>;
                  return buildEventCard(event);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // Helper function to format the date to string
  String _formatDateToString(DateTime? date) {
    if (date == null) return '';

    // Get the weekday and month names
    final dayNames = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];
    final monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final dayName = dayNames[date.weekday % 7];
    final monthName = monthNames[date.month - 1];

    return '$dayName, $monthName ${date.day}, ${date.year}';
  }
}
