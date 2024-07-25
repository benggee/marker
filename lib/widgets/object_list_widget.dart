
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:marker/db/database_helper.dart';
import 'package:marker/model/object_item_model.dart';

class ObjectListWidget extends StatefulWidget {
  final String id;
  final List<ObjectItemModel> objItems;

  ObjectListWidget({super.key, required this.objItems, required this.id});

  @override
  _ObjectListWidgetState createState() => _ObjectListWidgetState();
}

class _ObjectListWidgetState extends State<ObjectListWidget> {
  final TextEditingController _textController = TextEditingController();
  DatabaseHelper db = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        children: _buildObjectList(),
      ),
    );
  }

  _buildObjectList() {
    List<Widget> list = [];
    widget.objItems.asMap().forEach((index, item) {
      list.add(_buildObjectItem(index, item));
    });
    return list;
  }

  Widget _buildObjectItem(int index, ObjectItemModel item) {
    return Slidable(
      key: ValueKey(index),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        dismissible: DismissiblePane(onDismissed: () {
          setState(() {
            widget.objItems.removeAt(index);
          });
        }),
        children: [
          SlidableAction(
            onPressed: (context) {
              setState(() {
                widget.objItems.removeAt(index);
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
        title: TextField(
          controller: item.textController,
          decoration:  InputDecoration(
            labelText: widget.objItems[index] == "" ? '请输入清单内容' : '',
          ),
          onSubmitted: (text) {
            setState(() {
              widget.objItems[index] = ObjectItemModel(text: text, textController: widget.objItems[index].textController);
              if (widget.objItems.length - 1 == index) {
                widget.objItems.add(ObjectItemModel(text: text, textController: TextEditingController(text: text)));
              }
            });
          },
        ),
      ),
    );
  }
}