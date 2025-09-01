class BarcodeModel {
  final int? id;
  final String barcodeId;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  BarcodeModel({
    this.id,
    required this.barcodeId,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'barcode_id': barcodeId,
      'content': content,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory BarcodeModel.fromMap(Map<String, dynamic> map) {
    return BarcodeModel(
      id: map['id'],
      barcodeId: map['barcode_id'],
      content: map['content'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }

  BarcodeModel copyWith({
    int? id,
    String? barcodeId,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BarcodeModel(
      id: id ?? this.id,
      barcodeId: barcodeId ?? this.barcodeId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
