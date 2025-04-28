class AbsensiModel {
  final int? id;
  final int userId;
  final String type; // masuk / pulang
  final String date;
  final String time;
  final double latitude;
  final double longitude;

  AbsensiModel({
    this.id,
    required this.userId,
    required this.type,
    required this.date,
    required this.time,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'date': date,
      'time': time,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory AbsensiModel.fromMap(Map<String, dynamic> map) {
    return AbsensiModel(
      id: map['id'],
      userId: map['userId'],
      type: map['type'],
      date: map['date'],
      time: map['time'],
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }
}
