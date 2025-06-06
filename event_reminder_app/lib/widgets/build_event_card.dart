import 'package:event_reminder_app/screens/edit_event_screen.dart';
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
    if (timeComponents.length != 2) {
      throw FormatException('Invalid time components');
    }

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
    if (diff.inDays > 0) {
      return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} left';
    }
    if (diff.inHours > 0) {
      return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} left';
    }
    if (diff.inMinutes > 0) {
      return '${diff.inMinutes} min${diff.inMinutes > 1 ? 's' : ''} left';
    }
    return '< 1 min left'; // Shortened for consistency
  } catch (e) {
    return 'TBC';
  }
}

Widget buildEventCard(
  Map<String, dynamic> event,
  BuildContext context,
  String docId,
) {
  final remainingTime = calculateRemainingTime(event);
  final eventStatus = calculateRemainingTime(event, returnStatus: true);

  // Determine color based on event status, using theme colors where possible
  final Color timeColor;
  switch (eventStatus) {
    case 'passed':
      timeColor = Theme.of(context).colorScheme.secondary.withOpacity(0.6);
      break;
    case 'near':
      timeColor = Colors.orange; // Keep orange for urgency
      break;
    case 'soon':
      timeColor = Theme.of(context).colorScheme.primary.withOpacity(0.7);
      break;
    case 'future':
      timeColor = Theme.of(context).primaryColor; // 0xFF6F61EF
      break;
    default:
      timeColor = Theme.of(context).primaryColor;
  }

  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor, // White (light), 0xFF1E1E1E (dark)
      boxShadow: [
        BoxShadow(
          blurRadius: 4.0,
          color: Theme.of(context).shadowColor.withOpacity(0.1),
          offset: const Offset(0.0, 2.0),
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
                    Flexible(
                      child: Container(
                        height: 30.0,
                        decoration: BoxDecoration(
                          color: timeColor,
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.timer_rounded,
                                color: Theme.of(context).colorScheme.onPrimary,
                                size: 16.0,
                              ),
                              const SizedBox(width: 4.0),
                              Text(
                                remainingTime,
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.edit_rounded,
                        color: Theme.of(context).primaryColor,
                        size: 20.0,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => EditEventScreen(
                                  event: event,
                                  documentId: docId,
                                ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                // Title
                Text(
                  event['title'] ?? '',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                // Date row
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      size: 16.0,
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      event['date'] ?? '',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(fontSize: 14.0),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                // Time row
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      size: 16.0,
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      event['time'] ?? '',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(fontSize: 14.0),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                // Location row
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      size: 16.0,
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        event['location'] ?? '',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(fontSize: 14.0),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                // Description
                Text(
                  event['description'] ?? '',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontSize: 14.0),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
