import 'package:flutter/material.dart';
import 'package:event_reminder_app/widgets/BottomNavBar.dart';
import 'package:event_reminder_app/mixin/EventsList.dart';
import 'package:event_reminder_app/widgets/buildEventCard.dart';
import 'package:event_reminder_app/widgets/AppBar.dart';

class UpcomingEventScreenWidget extends StatefulWidget {
  const UpcomingEventScreenWidget({super.key});

  @override
  State<UpcomingEventScreenWidget> createState() =>
      _UpcomingEventScreenWidgetState();
}

class _UpcomingEventScreenWidgetState extends State<UpcomingEventScreenWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color.fromARGB(255, 241, 244, 248),
        appBar: buildAppBar(),
        body: SafeArea(
          child: Column(
            children: [
              const Divider(
                height: 1.0,
                thickness: 1.0,
                color: Color.fromARGB(255, 229, 231, 235),
              ),
              Expanded(child: _buildEventList()),
              BottomNavBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Dismissible(
            key: Key(event['id']!),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 20.0),
              child: const Icon(
                Icons.delete,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
            ),
            secondaryBackground: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20.0),
              child: const Icon(
                Icons.delete,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
            ),
            onDismissed: (direction) {
              setState(() {
                events.removeAt(index);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${event['title']} deleted')),
              );
            },
            child: buildEventCard(event),
          ),
        );
      },
    );
  }
}
