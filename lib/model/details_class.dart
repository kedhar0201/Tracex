class Details {
  Details({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.place,
    required this.date,
    required this.time,
    required this.name,
    required this.phoneNumber,
    required this.whatsAppNumber,
    required this.reportedBy, // ADDED: stores UID of user who reported
  });

  String id;
  String title;
  String description;
  String imageUrl;
  String place;
  String date;
  String time;
  String name;
  String phoneNumber;
  String whatsAppNumber;
  String reportedBy; // ADDED
}