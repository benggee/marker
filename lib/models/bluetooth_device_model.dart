class BluetoothDeviceModel {
  final String id;
  final String name;
  final String address;
  final bool isConnected;
  final DateTime lastConnected;
  final bool isRemembered;

  BluetoothDeviceModel({
    required this.id,
    required this.name,
    required this.address,
    required this.isConnected,
    required this.lastConnected,
    required this.isRemembered,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'is_connected': isConnected ? 1 : 0,
      'last_connected': lastConnected.millisecondsSinceEpoch,
      'is_remembered': isRemembered ? 1 : 0,
    };
  }

  factory BluetoothDeviceModel.fromMap(Map<String, dynamic> map) {
    return BluetoothDeviceModel(
      id: map['id'],
      name: map['name'],
      address: map['address'],
      isConnected: map['is_connected'] == 1,
      lastConnected: DateTime.fromMillisecondsSinceEpoch(map['last_connected']),
      isRemembered: map['is_remembered'] == 1,
    );
  }

  BluetoothDeviceModel copyWith({
    String? id,
    String? name,
    String? address,
    bool? isConnected,
    DateTime? lastConnected,
    bool? isRemembered,
  }) {
    return BluetoothDeviceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      isConnected: isConnected ?? this.isConnected,
      lastConnected: lastConnected ?? this.lastConnected,
      isRemembered: isRemembered ?? this.isRemembered,
    );
  }
}
