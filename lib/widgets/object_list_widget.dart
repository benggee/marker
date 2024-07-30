
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:marker/model/object_item_model.dart';
import 'package:marker/store/shared_preference.dart';

class ObjectListWidget extends StatefulWidget {
  final String id;
  ObjectListWidget({super.key, required this.id});

  @override
  _ObjectListWidgetState createState() => _ObjectListWidgetState();
}

class _ObjectListWidgetState extends State<ObjectListWidget> {
  SharedPreference db = SharedPreference.instance;
  List<ObjectItemModel> objItems = [];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  _initData() async {
    String? data = await _getContent(widget.id);

    if (data != null) {
      List<String>.from(jsonDecode(data)).forEach((element) {
           objItems.add(ObjectItemModel(text: element, textController: TextEditingController(text: element)));
      });
      setState(() {
      });
      return;
    } else {
      objItems.add(ObjectItemModel(text: '', textController: TextEditingController(text: '')));
      setState(() {
      });
    }
  }

  Future<String?> _getContent(String id) async {
    return await db.getContent(id);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
            children: _buildObjectList(),
          );
  }

  _buildObjectList() {
    List<Widget> list = [];
    objItems.asMap().forEach((index, item) {
      list.add(_buildObjectItem(index, item));
    });
    return list;
  }

  _insertItems() async {
    List<String> obList = [];
    objItems.forEach((item) {
      obList.add(item.text);
    });
    await db.saveContent(widget.id, jsonEncode(obList));
  }

  Widget _buildObjectItem(int index, ObjectItemModel item) {
    return Container(
      height: 45,
      child:Slidable(
        key: ValueKey(index),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          dismissible: DismissiblePane(onDismissed: () {
            setState(() {
              objItems.removeAt(index);
            });
          }),
          children: [
            SlidableAction(
              onPressed: (context) {
                setState(() {
                  objItems.removeAt(index);
                });
              },
              backgroundColor: Color(0xFFFE4A49),
              foregroundColor: Colors.white,
              // icon: Icons.delete,
              label: '删除',
            ),
          ],
        ),
        child: ListTile(
          title: Container(
            height: 20,
            child:TextField(
              style: TextStyle(fontSize: 14,),
              controller: item.textController,
              decoration:  InputDecoration(
                labelText: objItems[index] == "" ? '请输入清单内容' : '',
              ),
              onSubmitted: (text) {
                setState(() {
                  objItems[index] = ObjectItemModel(text: text, textController: objItems[index].textController);
                  _insertItems();
                  if (objItems.length - 1 == index) {
                    objItems.add(ObjectItemModel(text: text, textController: TextEditingController(text: '')));
                  }
                });
              },
            ),
          )
        ),
      )
    );
  }
}