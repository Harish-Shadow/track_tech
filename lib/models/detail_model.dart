class DetailModel {
  final String itemNumber;
  final String color;
  final String dcNumber;
  final Map<String, dynamic> rollDetails;
  final String timestamp;

  DetailModel({
    required this.itemNumber,
    required this.color,
    required this.dcNumber,
    required this.rollDetails,
    required this.timestamp,
  });

  // Convenience getters
  double get width => (rollDetails['width'] ?? 0.0).toDouble();
  double get shrinkageLength => (rollDetails['internalLength'] ?? 0.0).toDouble();
  double get shrinkageWidth => (rollDetails['internalWidth'] ?? 0.0).toDouble();
  String get shade => rollDetails['shade'] ?? '';
  String get rollNumber => rollDetails['rollNumber'] ?? '';
  double get length => (rollDetails['length'] ?? 0.0).toDouble();
  String get widthUnit => rollDetails['widthUnit'] ?? 'INCH';

  factory DetailModel.fromMap(Map<String, dynamic> map) {
    return DetailModel(
      itemNumber: map['itemNumber'] ?? '',
      color: map['color'] ?? '',
      dcNumber: map['dcNumber'] ?? '',
      rollDetails: Map<String, dynamic>.from(map['rollDetails'] ?? {}),
      timestamp: map['timestamp'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemNumber': itemNumber,
      'color': color,
      'dcNumber': dcNumber,
      'rollDetails': rollDetails,
      'timestamp': timestamp,
    };
  }
} 