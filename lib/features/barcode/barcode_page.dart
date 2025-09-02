import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../core/app_theme.dart';
import '../../models/barcode_model.dart';
import '../../widgets/barcode_widget.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/status_indicator.dart';

class BarcodePage extends StatefulWidget {
  const BarcodePage({super.key});

  @override
  State<BarcodePage> createState() => _BarcodePageState();
}

class _BarcodePageState extends State<BarcodePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppProvider>(context, listen: false).loadBarcodes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('条形码'),
        leading: const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: StatusIndicator(),
        ),
        leadingWidth: 160, // 给状态指示器留足够的空间
        actions: [
          IconButton(
            icon: const Icon(Icons.print_outlined),
            onPressed: _generateBarcode,
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const LoadingWidget(message: '加载中...');
          }

          if (provider.barcodes.isEmpty) {
            return _buildEmptyState();
          }

          return _buildBarcodeList(provider);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.view_stream,
            size: 80,
            color: AppColors.textLight,
          ),
          const SizedBox(height: 16),
          Text(
            '还没有条形码',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _generateBarcode,
            icon: const Icon(Icons.add),
            label: const Text('生成条形码'),
          ),
        ],
      ),
    );
  }

  Widget _buildBarcodeList(AppProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.barcodes.length,
      itemBuilder: (context, index) {
        final barcode = provider.barcodes[index];
        return _buildBarcodeCard(barcode, provider);
      },
    );
  }

  Widget _buildBarcodeCard(BarcodeModel barcode, AppProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        height: 230, // 设置足够的高度
        child: Stack(
          children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 10), // 增加条形码上方间距
                BarcodeDisplayWidget(
                  barcodeId: barcode.barcodeId,
                  width: 280,
                  height: 130,
                ),
                const SizedBox(height: 10), // 底部间距
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _printBarcode(barcode, provider),
                        icon: const Icon(Icons.print),
                        label: const Text('打印'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 菜单按钮放在卡片右上角
          Positioned(
            top: 2,
            right: -8,
            child: PopupMenuButton<String>(
              onSelected: (value) => _handleMenuAction(value, barcode, provider),
              color: Colors.white,
              elevation: 4,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'print',
                  child: Row(
                    children: [
                      Icon(Icons.print, size: 20, color: Colors.grey),
                      SizedBox(width: 8),
                      Text('打印'),
                    ],
                  ),
                ),
                const PopupMenuItem(
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
            ),
          ),
        ],
        ),
      ),
    );
  }

  Future<void> _generateBarcode() async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final barcode = await provider.generateBarcode();
    
    if (barcode != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('条形码 ${barcode.barcodeId.padLeft(6, '0')} 生成成功'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _printBarcode(BarcodeModel barcode, AppProvider provider) async {
    // 首先检查蓝牙连接状态
    if (provider.connectedDevice == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('请先连接蓝牙打印机'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: '去连接',
              onPressed: () {
                // 切换到蓝牙页面
                DefaultTabController.of(context).animateTo(2);
              },
            ),
          ),
        );
      }
      return;
    }
    
    // 显示打印进度
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Text('正在打印条形码 ${barcode.barcodeId.padLeft(6, '0')}...'),
            ],
          ),
          backgroundColor: AppColors.primaryBlue,
          duration: const Duration(seconds: 10),
        ),
      );
    }
    
    final success = await provider.printBarcode(barcode);
    
    if (mounted) {
      // 清除之前的进度提示
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('条形码 ${barcode.barcodeId.padLeft(6, '0')} 打印成功！'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('打印失败，请检查打印机状态和连接'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: '重试',
              onPressed: () => _printBarcode(barcode, provider),
            ),
          ),
        );
      }
    }
  }

  Future<void> _handleMenuAction(String action, BarcodeModel barcode, AppProvider provider) async {
    switch (action) {
      case 'print':
        await _printBarcode(barcode, provider);
        break;
      case 'delete':
        await _deleteBarcode(barcode, provider);
        break;
    }
  }

  Future<void> _deleteBarcode(BarcodeModel barcode, AppProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        elevation: 24,
        title: const Text('删除条形码'),
        content: Text('确定要删除条形码 ${barcode.barcodeId.padLeft(6, '0')} 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        print('开始删除条形码 ID: ${barcode.id}, 条形码: ${barcode.barcodeId}'); // 调试日志
        await provider.barcodeService.deleteBarcode(barcode.id!);
        print('条形码删除成功，重新加载数据'); // 调试日志
        await provider.loadBarcodes();
        print('数据重新加载完成'); // 调试日志
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('条形码已删除'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        print('删除失败: $e'); // 调试日志
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('删除失败: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      print('删除操作被取消'); // 调试日志
    }
  }
}
