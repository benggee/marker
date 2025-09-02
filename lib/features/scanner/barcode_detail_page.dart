import 'package:flutter/material.dart';
import '../../models/barcode_model.dart';
import '../../models/inventory_item_model.dart';
import '../../widgets/barcode_widget.dart';
import '../../services/database_service.dart';

class BarcodeDetailPage extends StatefulWidget {
  final BarcodeModel barcode;

  const BarcodeDetailPage({
    super.key,
    required this.barcode,
  });

  @override
  State<BarcodeDetailPage> createState() => _BarcodeDetailPageState();
}

class _BarcodeDetailPageState extends State<BarcodeDetailPage> {
  final DatabaseService _databaseService = DatabaseService();
  List<InventoryItemModel> _items = [];
  bool _isLoading = true;
  bool _isAddingNewItem = false;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final items = await _databaseService.getInventoryItemsByBarcodeId(widget.barcode.barcodeId);
      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载物品清单失败: $e')),
        );
      }
    }
  }

  Future<void> _addOrEditItem([InventoryItemModel? item]) async {
    final result = await showDialog<InventoryItemModel>(
      context: context,
      builder: (context) => _ItemEditDialog(
        barcodeId: widget.barcode.barcodeId,
        item: item,
      ),
    );
    
    if (result != null) {
      await _loadItems();
    }
  }

  Future<void> _deleteItem(InventoryItemModel item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        elevation: 24,
        title: const Text('确认删除'),
        content: Text('确定要删除物品 "${item.name}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true && item.id != null) {
      try {
        print('删除物品 ID: ${item.id}, 名称: ${item.name}'); // 调试日志
        await _databaseService.deleteInventoryItem(item.id!);
        print('删除完成，重新加载数据'); // 调试日志
        await _loadItems();
        print('数据重新加载完成，当前物品数量: ${_items.length}'); // 调试日志
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('物品删除成功')),
          );
        }
      } catch (e) {
        print('删除失败: $e'); // 调试日志
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('删除失败: $e')),
          );
        }
      }
    } else {
      print('删除取消或item.id为空: confirmed=$confirmed, item.id=${item.id}'); // 调试日志
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('条形码 ${widget.barcode.barcodeId}'),
      ),
      body: Column(
        children: [
          // 条形码显示区域
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Colors.grey.shade50,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: BarcodeDisplayWidget(
                    barcodeId: widget.barcode.barcodeId,
                    width: 250,
                    height: 80,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.barcode.barcodeId,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // 物品清单
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildItemList(), // 总是显示列表，包括添加按钮
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            '暂无物品',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击下方的添加按钮来添加物品',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemList() {
    // 如果没有物品且不在添加状态，显示空状态和添加按钮
    if (_items.isEmpty && !_isAddingNewItem) {
      return Column(
        children: [
          Expanded(child: _buildEmptyState()),
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildAddItemCard(),
          ),
        ],
      );
    }
    
    // 如果没有物品但在添加状态，显示添加表单
    if (_items.isEmpty && _isAddingNewItem) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: _buildAddItemCard(),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _items.length + 1, // +1 for add button
      itemBuilder: (context, index) {
        // 如果是最后一个项目，显示添加按钮或添加表单
        if (index == _items.length) {
          return _buildAddItemCard();
        }
        
        final item = _items[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(
              item.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.description.isNotEmpty)
                  Text(item.description),
                const SizedBox(height: 4),
                Text(
                  '数量: ${item.quantity}',
                  style: TextStyle(
                    color: Colors.blue.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              color: Colors.white,
              elevation: 8,
              itemBuilder: (context) => [
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20, color: Colors.grey),
                      SizedBox(width: 8),
                      Text('编辑'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('删除', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (String value) {
                if (value == 'edit') {
                  _addOrEditItem(item);
                } else if (value == 'delete') {
                  _deleteItem(item);
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddItemCard() {
    if (!_isAddingNewItem) {
      // 显示添加按钮
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: const Icon(Icons.add, color: Colors.blue),
          title: const Text(
            '添加新物品',
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.w500,
            ),
          ),
          onTap: () {
            setState(() {
              _isAddingNewItem = true;
            });
          },
        ),
      );
    } else {
      // 显示内联编辑表单
      return _InlineAddItemCard(
        barcodeId: widget.barcode.barcodeId,
        onSave: (item) async {
          try {
            await _databaseService.insertInventoryItem(item);
            setState(() {
              _isAddingNewItem = false;
            });
            await _loadItems();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('物品添加成功')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('添加失败: $e')),
              );
            }
          }
        },
        onCancel: () {
          setState(() {
            _isAddingNewItem = false;
          });
        },
      );
    }
  }
}

class _InlineAddItemCard extends StatefulWidget {
  final String barcodeId;
  final Function(InventoryItemModel) onSave;
  final VoidCallback onCancel;

  const _InlineAddItemCard({
    required this.barcodeId,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<_InlineAddItemCard> createState() => _InlineAddItemCardState();
}

class _InlineAddItemCardState extends State<_InlineAddItemCard> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      final item = InventoryItemModel(
        barcodeId: widget.barcodeId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        quantity: int.parse(_quantityController.text),
        createdAt: now,
        updatedAt: now,
      );

      await widget.onSave(item);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.add, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    '添加新物品',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '物品名称',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入物品名称';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '描述（可选）',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(
                        labelText: '数量',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '请输入数量';
                        }
                        final quantity = int.tryParse(value);
                        if (quantity == null || quantity < 0) {
                          return '请输入有效的数量';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    children: [
                      TextButton(
                        onPressed: _isLoading ? null : widget.onCancel,
                        child: const Text('取消'),
                      ),
                      const SizedBox(width: 4),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _saveItem,
                        child: _isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('保存'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemEditDialog extends StatefulWidget {
  final String barcodeId;
  final InventoryItemModel? item;

  const _ItemEditDialog({
    required this.barcodeId,
    this.item,
  });

  @override
  State<_ItemEditDialog> createState() => _ItemEditDialogState();
}

class _ItemEditDialogState extends State<_ItemEditDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _nameController.text = widget.item!.name;
      _descriptionController.text = widget.item!.description;
      _quantityController.text = widget.item!.quantity.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      final item = InventoryItemModel(
        id: widget.item?.id,
        barcodeId: widget.barcodeId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        quantity: int.parse(_quantityController.text),
        createdAt: widget.item?.createdAt ?? now,
        updatedAt: now,
      );

      if (widget.item == null) {
        await _databaseService.insertInventoryItem(item);
      } else {
        await _databaseService.updateInventoryItem(item);
      }

      if (mounted) {
        Navigator.pop(context, item);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      elevation: 24,
      title: Text(widget.item == null ? '添加物品' : '编辑物品'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '物品名称',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入物品名称';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '描述（可选）',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: '数量',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入数量';
                }
                final quantity = int.tryParse(value);
                if (quantity == null || quantity < 0) {
                  return '请输入有效的数量';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveItem,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('保存'),
        ),
      ],
    );
  }
}
