import 'package:badges/badges.dart' as badges;
import 'package:event_reminder_app/widgets/BottomNavBar.dart';
import 'package:event_reminder_app/widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:event_reminder_app/widgets/buildEventCard.dart';
import 'package:event_reminder_app/mixin/EventsList.dart';

class Calenderscreen extends StatefulWidget {
  const Calenderscreen({super.key});

  static String routeName = 'CALENDER';
  static String routePath = '/calender';

  @override
  State<Calenderscreen> createState() => _calenderScreen();
}

class _calenderScreen extends State<Calenderscreen>
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
                children: [_buildCalendarView(context)],
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavBar(context),
      ),
    );
  }

  Widget _buildCalendarView(BuildContext context) {
    final event = events[1];
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
                  color: Theme.of(context).primaryColor.withOpacity(0.5),
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
          ListView(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: [buildEventCard(event)],
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 0, 0),
            child: Text(
              'Past Due',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
          ListView(
            padding: EdgeInsets.fromLTRB(0, 12, 0, 24),
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: [buildEventCard(event)],
          ),
        ],
      ),
    );
  }
}
