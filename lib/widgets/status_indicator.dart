import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as dart_math;
import '../providers/app_provider.dart';
import '../core/app_theme.dart';

class StatusIndicator extends StatefulWidget {
  const StatusIndicator({super.key});

  @override
  State<StatusIndicator> createState() => _StatusIndicatorState();
}

class _StatusIndicatorState extends State<StatusIndicator> {
  double _batteryLevel = 0.0;
  double _temperature = 0.0;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _fetchDeviceStatus();
    // 定期更新状态
    _startPeriodicUpdate();
  }

  void _startPeriodicUpdate() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _fetchDeviceStatus();
        _startPeriodicUpdate();
      }
    });
  }

  Future<void> _fetchDeviceStatus() async {
    try {
      final provider = Provider.of<AppProvider>(context, listen: false);
      
      if (provider.connectedDevice != null) {
        setState(() {
          _isConnected = true;
        });
        
        // 获取电池电量和温度
        final deviceData = await _readDeviceData(provider);
        if (deviceData != null) {
          setState(() {
            _batteryLevel = deviceData['battery'] ?? 0.0;
            _temperature = deviceData['temperature'] ?? 0.0;
          });
        }
      } else {
        // 当没有连接设备时，显示模拟数据用于测试界面
        setState(() {
          _isConnected = false;
          _batteryLevel = 75.0; // 模拟75%电量
          _temperature = 28.5;  // 模拟28.5度温度
        });
      }
    } catch (e) {
      // 可以使用Logger.e替代print，但这里简化处理
      debugPrint('获取设备状态失败: $e');
      // 出错时也显示模拟数据
      setState(() {
        _isConnected = false;
        _batteryLevel = 45.0; // 模拟45%电量
        _temperature = 25.0;  // 模拟25度温度
      });
    }
  }

  Future<Map<String, double>?> _readDeviceData(AppProvider provider) async {
    try {
      // 根据您提供的打印机协议，发送ADC读取命令
      // 这里需要根据实际的蓝牙协议实现
      
      // 电池电量读取命令 (根据固件ADC协议自定义)
      List<int> batteryCommand = [0xA5, 0xA5, 0xA5, 0xA5, 0x04]; // 假设04是读取电池命令
      await provider.bluetoothService.writeData(batteryCommand);
      
      await Future.delayed(const Duration(milliseconds: 100));
      
      // 读取电池响应
      List<int>? batteryResponse = await provider.bluetoothService.readData();
      double batteryLevel = _parseBatteryLevel(batteryResponse);
      
      // 温度读取命令
      List<int> temperatureCommand = [0xA5, 0xA5, 0xA5, 0xA5, 0x05]; // 假设05是读取温度命令
      await provider.bluetoothService.writeData(temperatureCommand);
      
      await Future.delayed(const Duration(milliseconds: 100));
      
      // 读取温度响应
      List<int>? temperatureResponse = await provider.bluetoothService.readData();
      double temperature = _parseTemperature(temperatureResponse);
      
      return {
        'battery': batteryLevel,
        'temperature': temperature,
      };
    } catch (e) {
      debugPrint('读取设备数据失败: $e');
      return null;
    }
  }

  double _parseBatteryLevel(List<int>? data) {
    if (data == null || data.length < 4) return 0.0;
    
    // 根据您的固件代码，解析ADC电压值并转换为电池百分比
    // 假设数据格式为: [高位, 低位, 校验位, 结束位]
    int adcValue = (data[0] << 8) | data[1];
    
    // 将ADC值转换为电压 (假设12位ADC，参考电压3.3V)
    double voltage = (adcValue / 4096.0) * 3.3;
    
    // 将电压转换为电池百分比 (根据锂电池特性曲线)
    // 假设锂电池: 3.0V(0%) - 4.2V(100%)
    double percentage = ((voltage - 3.0) / (4.2 - 3.0)) * 100.0;
    
    return percentage.clamp(0.0, 100.0);
  }

  double _parseTemperature(List<int>? data) {
    if (data == null || data.length < 4) return 25.0; // 默认返回25度
    
    try {
      // 根据您的固件代码中的temperature_calculate函数实现
      int adcValue = (data[0] << 8) | data[1];
      
      // 将ADC值转换为电压
      double vol = (adcValue / 4096.0) * 3.3;
      
      // 验证电压值的有效性
      if (vol <= 0 || vol >= 3.3) {
        return 25.0; // 电压值无效时返回默认温度
      }
      
      // 根据固件代码计算电阻值
      // vol / 3.3 = Rt / (10000 + Rt)
      double rt = (vol * 10000) / (3.3 - vol);
      
      // 验证电阻值的有效性
      if (rt <= 0 || rt.isInfinite || rt.isNaN) {
        return 25.0; // 电阻值无效时返回默认温度
      }
      
      // 使用您提供的温度计算公式
      double rp = 30000; // 30K
      double t2 = 273.15 + 25;
      double bx = 3950; // B Value
      double ka = 273.15;
      
      // temperature = 1 / (log(Rt / Rp) / Bx + 1 / T2) - Ka + 0.5
      double logValue = (rt / rp).log();
      if (logValue.isNaN || logValue.isInfinite) {
        return 25.0; // 对数值无效时返回默认温度
      }
      
      double temperature = 1 / ((logValue / bx) + (1 / t2)) - ka + 0.5;
      
      // 验证最终温度值的有效性
      if (temperature.isNaN || temperature.isInfinite) {
        return 25.0; // 温度值无效时返回默认温度
      }
      
      // 限制温度范围在合理范围内
      return temperature.clamp(-40.0, 120.0);
    } catch (e) {
      debugPrint('温度计算错误: $e');
      return 25.0; // 出错时返回默认温度
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 连接状态图标
        Icon(
          _isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
          size: 18,
          color: _isConnected ? AppColors.successColor : AppColors.textLight,
        ),
        const SizedBox(width: 8),
        
        // 温度显示
        Text(
          '${_temperature.toStringAsFixed(1)}°C',
          style: TextStyle(
            fontSize: 12,
            color: _getTemperatureColor(_temperature),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        
        // 横置电池图标（模仿手机电量显示）
        _buildHorizontalBatteryIcon(_batteryLevel),
      ],
    );
  }

  // 构建横置电池图标
  Widget _buildHorizontalBatteryIcon(double level) {
    return CustomPaint(
      size: const Size(30, 16), // 电池图标大小
      painter: HorizontalBatteryPainter(
        level: level,
        color: _getBatteryColor(level),
      ),
    );
  }

  Color _getTemperatureColor(double temperature) {
    if (temperature > 60) return AppColors.errorColor;  // 过热
    if (temperature > 45) return AppColors.warningColor; // 偏热
    if (temperature < 0) return Colors.blue;  // 过冷
    return AppColors.textSecondary; // 正常
  }

  IconData _getBatteryIcon(double level) {
    if (level > 90) return Icons.battery_full;
    if (level > 60) return Icons.battery_5_bar;
    if (level > 40) return Icons.battery_4_bar;
    if (level > 20) return Icons.battery_3_bar;
    if (level > 10) return Icons.battery_2_bar;
    if (level > 5) return Icons.battery_1_bar;
    return Icons.battery_0_bar;
  }

  Color _getBatteryColor(double level) {
    if (level > 50) return AppColors.successColor;
    if (level > 20) return AppColors.warningColor;
    return AppColors.errorColor;
  }
}

extension DoubleExtension on double {
  double log() => dart_math.log(this);
}

// 横置电池图标绘制器
class HorizontalBatteryPainter extends CustomPainter {
  final double level;
  final Color color;

  HorizontalBatteryPainter({
    required this.level,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = color;

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    // 绘制电池外框（横置）
    final batteryBody = RRect.fromRectAndRadius(
      Rect.fromLTWH(2, 2, size.width - 6, size.height - 4),
      const Radius.circular(2),
    );
    canvas.drawRRect(batteryBody, paint);

    // 绘制电池正极头部
    final batteryTip = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width - 2, size.height * 0.3, 2, size.height * 0.4),
      const Radius.circular(1),
    );
    canvas.drawRRect(batteryTip, fillPaint);

    // 计算电池内部填充宽度
    double fillWidth = (size.width - 8) * (level / 100);
    if (fillWidth > 0) {
      final batteryFill = RRect.fromRectAndRadius(
        Rect.fromLTWH(3, 3, fillWidth, size.height - 6),
        const Radius.circular(1),
      );
      canvas.drawRRect(batteryFill, fillPaint);
    }

    // 绘制电量百分比文字
    final textPainter = TextPainter(
      text: TextSpan(
        text: level.toStringAsFixed(0),
        style: TextStyle(
          color: level > 30 ? Colors.white : color,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    
    // 计算文字位置（居中）
    final textOffset = Offset(
      (size.width - textPainter.width) / 2 - 1, // 稍微向左偏移避开正极
      (size.height - textPainter.height) / 2,
    );
    
    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(HorizontalBatteryPainter oldDelegate) {
    return oldDelegate.level != level || oldDelegate.color != color;
  }
}
