import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String calculateRemainingTime(
  Map<String, dynamic> event, {
  bool returnStatus = false,
}) {
  try {
    final dateString = event['date'] ?? '';
    final timeString = event['time'] ?? '';

    final parsedDate = DateFormat('EEEE, MMMM d, yyyy').parse(dateString);

    // Clean the time string
    final cleanedTimeString =
        timeString
            .replaceAll(RegExp(r'[\u202F\u00A0\u2007\u2060\uFEFF\u200B]'), ' ')
            .replaceAll(RegExp(r'[^\x00-\x7F]'), '')
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim();

    // Parse time
    final timeParts = cleanedTimeString.split(' ');
    if (timeParts.length != 2) throw FormatException('Invalid time format');

    final timeValue = timeParts[0];
    final period = timeParts[1].toUpperCase();

    final timeComponents = timeValue.split(':');
    if (timeComponents.length != 2)
      throw FormatException('Invalid time components');

    int hour = int.parse(timeComponents[0]);
    final minute = int.parse(timeComponents[1]);

    // Convert to 24-hour format
    if (period == 'PM' && hour != 12) {
      hour += 12;
    } else if (period == 'AM' && hour == 12) {
      hour = 0;
    }

    final eventDateTime = DateTime(
      parsedDate.year,
      parsedDate.month,
      parsedDate.day,
      hour,
      minute,
    );

    final now = DateTime.now();
    final diff = eventDateTime.difference(now);

    if (returnStatus) {
      if (diff.isNegative) return 'passed';
      if (diff.inMinutes < 60) return 'near'; // Less than 1 hour
      if (diff.inHours < 24) return 'soon'; // Less than 1 day
      return 'future';
    }

    if (diff.isNegative) return 'Passed';
    if (diff.inDays > 0)
      return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} left';
    if (diff.inHours > 0)
      return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} left';
    if (diff.inMinutes > 0)
      return '${diff.inMinutes} min${diff.inMinutes > 1 ? 's' : ''} left';
    return 'Less than a minute left';
  } catch (e) {
    return 'TBC';
  }
}

Widget buildEventCard(Map<String, dynamic> event) {
  final remainingTime = calculateRemainingTime(event);
  final eventStatus = calculateRemainingTime(event, returnStatus: true);

  // Determine color based on event status
  final Color timeColor;
  switch (eventStatus) {
    case 'passed':
      timeColor = Colors.grey; // Grey for past events
      break;
    case 'near':
      timeColor = Colors.orange; // Orange for events happening soon (<1 hour)
      break;
    case 'soon':
      timeColor = Colors.blue; // Blue for events happening today
      break;
    case 'future':
      timeColor = const Color(0xFF6F61EF); // Default purple for future events
      break;
    default:
      timeColor = const Color(0xFF6F61EF); // Default color
  }

  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: const [
        BoxShadow(
          blurRadius: 4.0,
          color: Color(0x1A000000),
          offset: Offset(0.0, 2.0),
        ),
      ],
      borderRadius: BorderRadius.circular(12.0),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Time badge and edit button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: remainingTime.length > 6 ? 100.0 : 80.0,
                      height: 30.0,
                      decoration: BoxDecoration(
                        color: timeColor,
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.timer_rounded,
                              color: Colors.white,
                              size: 16.0,
                            ),
                            const SizedBox(width: 4.0),
                            Text(
                              remainingTime,
                              style: const TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                color: Colors.white,
                                fontSize: 12.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.edit_rounded,
                        color: Color(0xFF6F61EF),
                        size: 20.0,
                      ),
                      onPressed: () {
                        // Edit button action here
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                // Title
                Text(
                  event['title'] ?? '',
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    color: Color(0xFF15161E),
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                // Date row
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      color: Color(0xFF606A85),
                      size: 16.0,
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      event['date'] ?? '',
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        color: Color(0xFF606A85),
                        fontSize: 14.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                // Time row
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      color: Color(0xFF606A85),
                      size: 16.0,
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      event['time'] ?? '',
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        color: Color(0xFF606A85),
                        fontSize: 14.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                // Location row
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: Color(0xFF606A85),
                      size: 16.0,
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        event['location'] ?? '',
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          color: Color(0xFF606A85),
                          fontSize: 14.0,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                // Description
                Text(
                  event['description'] ?? '',
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    color: Color(0xFF15161E),
                    fontSize: 14.0,
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
