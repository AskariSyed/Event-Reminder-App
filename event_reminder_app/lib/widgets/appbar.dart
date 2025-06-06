import 'package:flutter/material.dart';

AppBar buildAppBar(String title, BuildContext context) {
  return AppBar(
    backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
    automaticallyImplyLeading: false,
    title: Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        color: Theme.of(context).appBarTheme.foregroundColor,
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
              icon: Icon(
                Icons.search_rounded,
                color: Theme.of(context).primaryColor,
                size: 24.0,
              ),
              onPressed: () {},
            ),
            const SizedBox(width: 12.0),
            IconButton(
              icon: Icon(
                Icons.filter_list_rounded,
                color: Theme.of(context).primaryColor,
                size: 24.0,
              ),
              onPressed: () {},
            ),
          ],
        ),
      ),
    ],
    centerTitle: false,
    elevation: Theme.of(context).appBarTheme.elevation,
  );
}
