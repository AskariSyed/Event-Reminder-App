import 'package:flutter/material.dart';

Widget BottomNavBar() {
  return Container(
    width: double.infinity,
    height: 80.0,
    decoration: const BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          blurRadius: 4.0,
          color: Color.fromARGB(26, 0, 0, 0),
          offset: Offset(0.0, -2.0),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.event_note_rounded,
                color: Color.fromARGB(255, 111, 97, 239),
                size: 28.0,
              ),
              const Text(
                'Events',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  color: Color.fromARGB(255, 111, 97, 239),
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                color: Color.fromARGB(255, 96, 106, 133),
                size: 28.0,
              ),
              const Text(
                'Calendar',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  color: Color(0xFF606A85),
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FloatingActionButton(
                onPressed: () {
                  print('Add event pressed ...');
                },
                backgroundColor: const Color.fromARGB(255, 111, 97, 239),
                elevation: 2.0,
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 28.0,
                ),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.notifications_none_rounded,
                color: Color(0xFF606A85),
                size: 28.0,
              ),
              const Text(
                'Alerts',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  color: Color.fromARGB(255, 96, 106, 133),
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.settings_outlined,
                color: Color.fromARGB(255, 96, 106, 133),
                size: 28.0,
              ),
              const Text(
                'Settings',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  color: Color.fromARGB(255, 96, 106, 133),
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
