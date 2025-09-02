import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import '../../widgets/status_indicator.dart';
import '../../widgets/barcode_widget.dart';
import '../../models/barcode_model.dart';
import '../../models/inventory_item_model.dart';
import '../../services/barcode_service.dart';
import '../../services/database_service.dart';
import 'barcode_detail_page.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final BarcodeService _barcodeService = BarcodeService();
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _searchController = TextEditingController();
  List<BarcodeModel> _barcodes = [];
  List<BarcodeModel> _filteredBarcodes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBarcodes();
    _searchController.addListener(_filterBarcodes);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBarcodes() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final barcodes = await _barcodeService.getAllBarcodes();
      setState(() {
        _barcodes = barcodes;
        _filteredBarcodes = barcodes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载条形码失败: $e')),
        );
      }
    }
  }

  Future<void> _filterBarcodes() async {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      _filteredBarcodes = _barcodes;
    } else {
      // 搜索所有条形码的物品清单
      List<BarcodeModel> matchingBarcodes = [];
      
      for (BarcodeModel barcode in _barcodes) {
        // 获取这个条形码的所有物品
        List<InventoryItemModel> items = await _databaseService.getInventoryItemsByBarcodeId(barcode.barcodeId);
        
        // 检查是否有物品匹配搜索条件
        bool hasMatch = items.any((item) =>
          item.name.toLowerCase().contains(query) ||
          item.description.toLowerCase().contains(query)
        );
        
        // 如果有匹配的物品，或者条形码ID本身匹配，就添加到结果中
        if (hasMatch || barcode.barcodeId.toLowerCase().contains(query)) {
          matchingBarcodes.add(barcode);
        }
      }
      
      _filteredBarcodes = matchingBarcodes;
    }
  }

  Future<void> _scanBarcode() async {
    try {
      final result = await BarcodeScanner.scan();
      
      if (result.type == ResultType.Barcode && result.rawContent.isNotEmpty) {
        final scannedCode = result.rawContent;
        
        // 在数据库中查找这个条形码
        final barcode = _barcodes.firstWhere(
          (b) => b.barcodeId == scannedCode,
          orElse: () => throw Exception('条形码未找到'),
        );
        
        // 找到了，跳转到详情页
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BarcodeDetailPage(barcode: barcode),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().contains('条形码未找到') 
                ? '扫描的条形码不存在于数据库中' 
                : '扫描失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('搜索条形码'),
        leading: const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: StatusIndicator(),
        ),
        leadingWidth: 160,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBarcodes,
          ),
        ],
      ),
      body: Column(
        children: [
          // 搜索框
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) async {
                // 直接在这里触发整个页面的重建和搜索过滤
                await _filterBarcodes();
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: '搜索物品名称或描述...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 扫码图标
                    IconButton(
                      icon: const Icon(Icons.qr_code_scanner),
                      onPressed: _scanBarcode,
                      tooltip: '扫描条形码',
                    ),
                    // 清除图标（仅在有文本时显示）
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () async {
                          _searchController.clear();
                          await _filterBarcodes(); // 触发重建和搜索过滤
                          setState(() {});
                        },
                      ),
                  ],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
          ),
          // 搜索结果
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredBarcodes.isEmpty
                    ? _buildEmptyState()
                    : _buildBarcodeList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final isSearching = _searchController.text.isNotEmpty;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching ? Icons.search_off : Icons.qr_code_2,
            size: 100,
            color: Colors.grey,
          ),
          const SizedBox(height: 20),
          Text(
            isSearching ? '未找到匹配的物品' : '暂无条形码',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            isSearching ? '没有找到包含该物品的条形码' : '请先在打印页面生成条形码',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarcodeList() {
    return RefreshIndicator(
      onRefresh: _loadBarcodes,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filteredBarcodes.length,
        itemBuilder: (context, index) {
          final barcode = _filteredBarcodes[index];
          return _buildBarcodeCard(barcode);
        },
      ),
    );
  }

  Widget _buildBarcodeCard(BarcodeModel barcode) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BarcodeDetailPage(barcode: barcode),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 条形码预览
              Container(
                width: 80,
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: BarcodeDisplayWidget(
                  barcodeId: barcode.barcodeId,
                  width: 80,
                  height: 50,
                ),
              ),
              const SizedBox(width: 16),
              // 条形码信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ID: ${barcode.barcodeId}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '创建时间: ${_formatDate(barcode.createdAt)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              // 箭头图标
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
