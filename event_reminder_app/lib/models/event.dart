class Event {
  String eventID;
  String title;
  String date;
  String time;
  String description;
  String Location;
  bool notificationEnabled;

  Event({
    required this.eventID,
    required this.title,
    required this.date,
    required this.time,
    required this.description,
    required this.Location,
    required this.notificationEnabled,
  });
}
