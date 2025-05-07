import 'package:event_reminder_app/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_reminder_app/widgets/BottomNavBar.dart';
import 'package:event_reminder_app/widgets/buildEventCard.dart';
import 'package:event_reminder_app/widgets/appbar.dart';
import 'package:provider/provider.dart';

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
    final userProvider = Provider.of<UserProvider>(context);
    final userId = userProvider.user?.uid;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color.fromARGB(255, 241, 244, 248),
        appBar: buildAppBar('Upcoming Events'),
        body: SafeArea(
          child: Column(
            children: [
              const Divider(
                height: 1.0,
                thickness: 1.0,
                color: Color.fromARGB(255, 229, 231, 235),
              ),
              Expanded(child: _buildEventList(userId)),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavBar(currentIndex: 0),
      ),
    );
  }

  // Fetch events for a specific user
  Widget _buildEventList(String? userId) {
    if (userId == null) {
      return const Center(child: Text('User not logged in.'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('events')
              .where('userId', isEqualTo: userId)
              .orderBy('date')
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error fetching events.'));
        }

        final events = snapshot.data?.docs ?? [];
        if (events.isEmpty) {
          return const Center(child: Text('No upcoming events.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index].data() as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Dismissible(
                key: Key(event['id']),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 20.0),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                secondaryBackground: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20.0),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  final docId =
                      events[index].id; // Access the Firestore document ID

                  // Delete the event using the Firestore document ID (docId)
                  FirebaseFirestore.instance
                      .collection('events')
                      .doc(docId) // Use the Firestore document ID
                      .delete()
                      .then((_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${event['title']} deleted')),
                        );
                      })
                      .catchError((error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error deleting event: $error'),
                          ),
                        );
                      });
                },

                child: buildEventCard(event),
              ),
            );
          },
        );
      },
    );
  }
}
