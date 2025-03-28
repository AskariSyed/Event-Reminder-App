import 'package:flutter/material.dart';

AppBar buildAppBar() {
  return AppBar(
    backgroundColor: const Color(0xFFF1F4F8),
    automaticallyImplyLeading: false,
    title: const Text(
      'Upcoming Events',
      style: TextStyle(
        fontFamily: 'Outfit',
        color: Color(0xFF15161E),
        fontSize: 32.0,
        fontWeight: FontWeight.bold,
      ),
    ),
    actions: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.search_rounded,
                color: Color(0xFF6F61EF),
                size: 24.0,
              ),
              onPressed: () {
                print('Search pressed ...');
              },
            ),
            const SizedBox(width: 12.0),
            IconButton(
              icon: const Icon(
                Icons.filter_list_rounded,
                color: Color(0xFF6F61EF),
                size: 24.0,
              ),
              onPressed: () {
                print('Filter pressed ...');
              },
            ),
          ],
        ),
      ),
    ],
    centerTitle: false,
    elevation: 0.0,
  );
}
