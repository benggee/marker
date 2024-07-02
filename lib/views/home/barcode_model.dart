
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BarcodeItem {
  final String id;
  final String url;
  final String dimensions;
  final bool printed;

  BarcodeItem({
    required this.id,
    required this.url,
    required this.dimensions,
    required this.printed,
  });
}

class BarcodeModel {
  static Future<List<BarcodeItem>> fetchBarcodeItems() async {
    final directory = await getApplicationDocumentsDirectory();
    final prefs = await SharedPreferences.getInstance();

    final files = directory.listSync().where((file) => file.path.endsWith('.png')).toList();
    List<BarcodeItem> barcodes = [];

    print("files: $files");

    for (var file in files) {
      final id = file.path.split('/').last.split('.').first;
      final printed = prefs.getBool('${id}_printed') ?? false;
      barcodes.add(BarcodeItem(id: id, url: file.path, dimensions: "298x100", printed: printed));
    }

    return barcodes;
  }
}
