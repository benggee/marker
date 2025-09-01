class InventoryItemModel {
  final int? id;
  final String barcodeId;
  final String name;
  final String description;
  final int quantity;
  final DateTime createdAt;
  final DateTime updatedAt;

  InventoryItemModel({
    this.id,
    required this.barcodeId,
    required this.name,
    required this.description,
    required this.quantity,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'barcode_id': barcodeId,
      'name': name,
      'description': description,
      'quantity': quantity,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory InventoryItemModel.fromMap(Map<String, dynamic> map) {
    return InventoryItemModel(
      id: map['id'],
      barcodeId: map['barcode_id'],
      name: map['name'],
      description: map['description'],
      quantity: map['quantity'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }

  InventoryItemModel copyWith({
    int? id,
    String? barcodeId,
    String? name,
    String? description,
    int? quantity,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InventoryItemModel(
      id: id ?? this.id,
      barcodeId: barcodeId ?? this.barcodeId,
      name: name ?? this.name,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
