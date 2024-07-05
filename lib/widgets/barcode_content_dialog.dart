import 'dart:core';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:marker/store/barcode_content.dart';

class BarcodeContentDialog extends StatefulWidget {
  final String id;

  BarcodeContentDialog({required this.id});

  @override
  _BarcodeContentDialogState createState() => _BarcodeContentDialogState();
}

class _BarcodeContentDialogState extends State<BarcodeContentDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    String? content = await BarcodeContent.instance.getContent(widget.id);
    if (content != null) {
      _controller.text = content;
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveContent() async {
    final content = _controller.text;
    await BarcodeContent.instance.saveContent(widget.id, content);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      title: Text("ID: ${widget.id}", style: TextStyle(fontSize: 14)),
      content: _isLoading
          ? CircularProgressIndicator()
          : SizedBox(
            width: double.maxFinite,
            child: TextField(
              controller: _controller,
              maxLines: 500,
              decoration: InputDecoration(
                hintText: '请输入内容',
                border: OutlineInputBorder(),
              ),
              style: TextStyle(fontSize: 12),
            ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("关闭"),
        ),
        TextButton(
          onPressed: _saveContent,
          child: Text("保存"),
        ),
      ],
    );
  }
}