import 'package:flutter/material.dart';

Widget buildEventCard(Map<String, String> event) {
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: event['remainingTime']!.length > 6 ? 100.0 : 80.0,
                      height: 30.0,
                      decoration: BoxDecoration(
                        color: Color(int.parse(event['timeColor']!)),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.timer_rounded,
                              color: Color(int.parse(event['timeColor']!)),
                              size: 16.0,
                            ),
                            const SizedBox(width: 4.0),
                            Text(
                              event['remainingTime']!,
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                color: Color(int.parse(event['timeColor']!)),
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
                        print('Edit ${event['title']} pressed ...');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Text(
                  event['title']!,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    color: Color(0xFF15161E),
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      color: Color(0xFF606A85),
                      size: 16.0,
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      event['date']!,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        color: Color(0xFF606A85),
                        fontSize: 14.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      color: Color(0xFF606A85),
                      size: 16.0,
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      event['time']!,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        color: Color(0xFF606A85),
                        fontSize: 14.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: Color(0xFF606A85),
                      size: 16.0,
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      event['location']!,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        color: Color(0xFF606A85),
                        fontSize: 14.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Text(
                  event['description']!,
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
