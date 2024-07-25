import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:marker/utils/navigator_util.dart';
import 'package:marker/utils/view_utils.dart';

import 'gen_barcode_page.dart';

class PrintPage extends StatefulWidget {
  const PrintPage({super.key});

  @override
  State<PrintPage> createState() => _PrintPageState();
}

class _PrintPageState extends State<PrintPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
        child:Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _button('生成条码'),
              _button('打印图片'),
            ],
          ),
        ),
      ),
    );
  }

  _button(String title) {
    return GestureDetector(
      onTap: () {
        if (title == '生成条码') {
          NavigatorUtil.push(context, GenBarcodePage());
          print('点击了生成条码按钮');
        } else {
          print('点击了打印图片按钮');
        }
      },
      child: Container(
        height: 50,
        width: 150,
        margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.black12, width: 1),
        ),
        child: Stack(
          children: [
            // Image(image: AssetImage('images/printer.png'), width: 20, height: 20, color: Colors.white,),
            Row(
              children: [
                Icon(
                  title=='生成条码'?Icons.burst_mode_outlined:Icons.picture_in_picture,
                  color: Colors.black54,
                ),
                hiSpace(width: 10),
                Text(
                  title,
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
