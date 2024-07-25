import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:marker/model/object_item_model.dart';
import 'package:marker/utils/barcode_utils.dart';
import 'package:marker/utils/str_utils.dart';
import 'package:marker/widgets/object_list_widget.dart';

class GenBarcodePage extends StatefulWidget {
  const GenBarcodePage({super.key});

  @override
  State<GenBarcodePage> createState() => _GenBarcodePageState();
}

class _GenBarcodePageState extends State<GenBarcodePage> {
  final List<ObjectItemModel> _objectItems = [ObjectItemModel(text: "aa", textController: TextEditingController(text: "aa")), ObjectItemModel(text: "bb", textController: TextEditingController(text: "bb"))];

  @override
  Widget build(BuildContext context) {
    String id = generateRandomId();
    String svgBarcodeImage = genBarcode(id);

    return Scaffold(
      appBar: AppBar(
        title: Text('生成条形码'),
      ),
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: SvgPicture.string(svgBarcodeImage, height: 180),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(6),
              ),
            ),

            ObjectListWidget(objItems: _objectItems, id: id,),
          ],
        )
      )
    );
  }
}
