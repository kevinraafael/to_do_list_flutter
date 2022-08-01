class ToDo {
  String title;
  DateTime dateTime;

  ToDo({required this.title, required this.dateTime});
  ToDo.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        dateTime = DateTime.parse(json['dateTime']);

  toJson() {
    return {
      'title': title,
      'dateTime': dateTime.toIso8601String(),
    };
  }
}
