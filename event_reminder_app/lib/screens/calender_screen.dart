import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_reminder_app/providers/user_provider.dart';
import 'package:event_reminder_app/widgets/bottom_nav_bar.dart';
import 'package:event_reminder_app/widgets/appbar.dart';
import 'package:event_reminder_app/widgets/build_event_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class Calenderscreen extends StatefulWidget {
  const Calenderscreen({super.key});

  static const String routeName = 'CALENDER';
  static const String routePath = '/calender';

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
    // Enable Firestore offline persistence
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
    );
    // Pre-select today's date
    _selectedDay = DateTime.now();
    _focusedDay = _selectedDay!;
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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: buildAppBar('Calendar', context),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: Theme.of(context).textTheme.bodyLarge?.color,
                unselectedLabelColor:
                    Theme.of(context).textTheme.bodyMedium?.color,
                labelStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                indicator: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                tabs: const [Tab(text: 'Month'), Tab(text: 'Week')],
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
        bottomNavigationBar: const BottomNavBar(currentIndex: 1),
      ),
    );
  }

  Widget _buildCalendarView(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userId = userProvider.user?.uid;

    if (userId == null) {
      return Center(
        child: Text(
          'User not logged in.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  blurRadius: 5,
                  color: Theme.of(context).shadowColor.withValues(alpha: 0.12),
                  offset: const Offset(0, 1),
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
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                defaultTextStyle: Theme.of(context).textTheme.bodyLarge!,
                weekendTextStyle: Theme.of(context).textTheme.bodyLarge!,
                outsideTextStyle: Theme.of(
                  context,
                ).textTheme.bodyMedium!.copyWith(color: Colors.grey),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleTextStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: Theme.of(
                  context,
                ).textTheme.bodyMedium!.copyWith(fontSize: 14),
                weekendStyle: Theme.of(
                  context,
                ).textTheme.bodyMedium!.copyWith(fontSize: 14),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 0, 0),
            child: Text(
              'Coming Up',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(fontSize: 14),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection('events')
                    .where('userId', isEqualTo: userId)
                    .where('date', isEqualTo: _formatDateToString(_selectedDay))
                    .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error fetching events. Changes may be saved offline and will sync later.',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                );
              }

              final events = snapshot.data?.docs ?? [];
              if (events.isEmpty) {
                return Center(
                  child: Text(
                    'No upcoming events.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final eventDoc = events[index];
                  final event = eventDoc.data() as Map<String, dynamic>;
                  final docId = eventDoc.id;

                  return buildEventCard(event, context, docId);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatDateToString(DateTime? date) {
    if (date == null) return '';

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
