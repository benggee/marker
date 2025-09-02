import 'dart:io';
import 'package:sqlite3/sqlite3.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/barcode_model.dart';
import '../models/inventory_item_model.dart';
import '../models/bluetooth_device_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;
  static const String _databaseName = 'marker3.db';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final String path = join(documentsDirectory.path, _databaseName);
    
    final db = sqlite3.open(path);
    
    // 创建表
    await _createTables(db);
    
    return db;
  }

  Future<void> _createTables(Database db) async {
    // 创建条形码表
    db.execute('''
      CREATE TABLE IF NOT EXISTS barcodes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        barcodeId TEXT UNIQUE NOT NULL,
        content TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // 创建库存项目表
    db.execute('''
      CREATE TABLE IF NOT EXISTS inventory_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        barcodeId TEXT NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        quantity INTEGER NOT NULL DEFAULT 1,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (barcodeId) REFERENCES barcodes (barcodeId)
      )
    ''');

    // 创建蓝牙设备表
    db.execute('''
      CREATE TABLE IF NOT EXISTS bluetooth_devices (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        deviceId TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        address TEXT NOT NULL,
        isConnected INTEGER NOT NULL DEFAULT 0,
        lastConnected TEXT,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  // 条形码相关方法
  Future<int> insertBarcode(BarcodeModel barcode) async {
    final db = await database;
    db.execute('''
      INSERT INTO barcodes (barcodeId, content, createdAt, updatedAt)
      VALUES (?, ?, ?, ?)
    ''', [barcode.barcodeId, barcode.content, barcode.createdAt.toIso8601String(), barcode.updatedAt.toIso8601String()]);
    
    // 获取最后插入的ID
    final results = db.select('SELECT last_insert_rowid() as id');
    return results.first['id'] as int;
  }

  Future<List<BarcodeModel>> getAllBarcodes() async {
    final db = await database;
    final results = db.select('SELECT * FROM barcodes ORDER BY createdAt DESC');
    
    return results.map((row) => BarcodeModel(
      barcodeId: row['barcodeId'] as String,
      content: row['content'] as String,
      createdAt: DateTime.parse(row['createdAt'] as String),
      updatedAt: DateTime.parse(row['updatedAt'] as String),
    )).toList();
  }

  Future<BarcodeModel?> getBarcodeById(String barcodeId) async {
    final db = await database;
    final results = db.select('SELECT * FROM barcodes WHERE barcodeId = ?', [barcodeId]);
    
    if (results.isEmpty) return null;
    
    final row = results.first;
    return BarcodeModel(
      barcodeId: row['barcodeId'] as String,
      content: row['content'] as String,
      createdAt: DateTime.parse(row['createdAt'] as String),
      updatedAt: DateTime.parse(row['updatedAt'] as String),
    );
  }

  Future<int> deleteBarcode(int id) async {
    final db = await database;
    db.execute('DELETE FROM barcodes WHERE id = ?', [id]);
    return 1; // 简化返回
  }

  Future<String> getNextBarcodeId() async {
    final barcodes = await getAllBarcodes();
    if (barcodes.isEmpty) return '000001';
    
    final lastId = barcodes.first.barcodeId;
    final nextNumber = int.parse(lastId) + 1;
    return nextNumber.toString().padLeft(6, '0');
  }

  // 库存项目相关方法
  Future<int> insertInventoryItem(InventoryItemModel item) async {
    final db = await database;
    db.execute('''
      INSERT INTO inventory_items (barcodeId, name, description, quantity, createdAt, updatedAt)
      VALUES (?, ?, ?, ?, ?, ?)
    ''', [item.barcodeId, item.name, item.description, item.quantity, item.createdAt.toIso8601String(), item.updatedAt.toIso8601String()]);
    
    // 获取最后插入的ID
    final results = db.select('SELECT last_insert_rowid() as id');
    return results.first['id'] as int;
  }

  Future<List<InventoryItemModel>> getInventoryItemsByBarcodeId(String barcodeId) async {
    final db = await database;
    final results = db.select('SELECT * FROM inventory_items WHERE barcodeId = ? ORDER BY createdAt DESC', [barcodeId]);
    
    return results.map((row) => InventoryItemModel(
      id: row['id'] as int,
      barcodeId: row['barcodeId'] as String,
      name: row['name'] as String,
      description: row['description'] as String? ?? '',
      quantity: row['quantity'] as int,
      createdAt: DateTime.parse(row['createdAt'] as String),
      updatedAt: DateTime.parse(row['updatedAt'] as String),
    )).toList();
  }

  Future<int> updateInventoryItem(InventoryItemModel item) async {
    final db = await database;
    db.execute('''
      UPDATE inventory_items 
      SET name = ?, description = ?, quantity = ?, updatedAt = ?
      WHERE id = ?
    ''', [item.name, item.description, item.quantity, item.updatedAt.toIso8601String(), item.id]);
    
    return 1; // 简化返回
  }

  Future<int> deleteInventoryItem(int id) async {
    final db = await database;
    db.execute('DELETE FROM inventory_items WHERE id = ?', [id]);
    return 1; // 简化返回
  }

  // 蓝牙设备相关方法
  Future<int> insertBluetoothDevice(BluetoothDeviceModel device) async {
    final db = await database;
    db.execute('''
      INSERT INTO bluetooth_devices (deviceId, name, address, isConnected, lastConnected, createdAt)
      VALUES (?, ?, ?, ?, ?, ?)
    ''', [device.id, device.name, device.address, device.isConnected ? 1 : 0, device.lastConnected.toIso8601String(), DateTime.now().toIso8601String()]);
    
    // 获取最后插入的ID
    final results = db.select('SELECT last_insert_rowid() as id');
    return results.first['id'] as int;
  }

  Future<List<BluetoothDeviceModel>> getAllBluetoothDevices() async {
    final db = await database;
    final results = db.select('SELECT * FROM bluetooth_devices ORDER BY lastConnected DESC');
    
    return results.map((row) => BluetoothDeviceModel(
      id: row['deviceId'] as String,
      name: row['name'] as String,
      address: row['address'] as String,
      isConnected: (row['isConnected'] as int) == 1,
      lastConnected: row['lastConnected'] != null ? DateTime.parse(row['lastConnected'] as String) : DateTime.now(),
      isRemembered: true, // 默认记住设备
    )).toList();
  }

  Future<List<BluetoothDeviceModel>> getRememberedDevices() async {
    final db = await database;
    final results = db.select('SELECT * FROM bluetooth_devices ORDER BY lastConnected DESC');
    
    return results.map((row) => BluetoothDeviceModel(
      id: row['deviceId'] as String,
      name: row['name'] as String,
      address: row['address'] as String,
      isConnected: (row['isConnected'] as int) == 1,
      lastConnected: row['lastConnected'] != null ? DateTime.parse(row['lastConnected'] as String) : DateTime.now(),
      isRemembered: true, // 默认记住设备
    )).toList();
  }

  Future<void> updateBluetoothDevice(BluetoothDeviceModel device) async {
    final db = await database;
    db.execute('''
      UPDATE bluetooth_devices 
      SET name = ?, address = ?, isConnected = ?, lastConnected = ?
      WHERE deviceId = ?
    ''', [device.name, device.address, device.isConnected ? 1 : 0, device.lastConnected.toIso8601String(), device.id]);
  }

  Future<void> deleteBluetoothDevice(String deviceId) async {
    final db = await database;
    db.execute('DELETE FROM bluetooth_devices WHERE deviceId = ?', [deviceId]);
  }

  // 关闭数据库
  Future<void> close() async {
    if (_database != null) {
      _database!.dispose();
      _database = null;
    }
  }
}
