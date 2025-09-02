import 'package:flutter/material.dart';
import 'app_theme.dart';

/// 样式指南 - 展示如何使用新的协调配色方案
class StyleGuide {
  /// 获取颜色展示卡片
  static Widget getColorShowcase(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '应用配色方案 - 协调蓝色系',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildColorRow(context, 'Primary Blue', AppColors.primaryBlue, '主要蓝色 - 按钮、链接'),
            _buildColorRow(context, 'Dark Blue', AppColors.darkBlue, '深蓝色 - 主色调、标题栏'),
            _buildColorRow(context, 'Accent Blue', AppColors.accentBlue, '强调蓝 - 高亮元素'),
            _buildColorRow(context, 'Light Blue', AppColors.lightBlue, '浅蓝色 - 主背景'),
            const SizedBox(height: 16),
            Text(
              '中性色系统',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            _buildColorRow(context, 'Text Primary', AppColors.textPrimary, '主要文本色'),
            _buildColorRow(context, 'Text Secondary', AppColors.textSecondary, '次要文本色'),
            _buildColorRow(context, 'Border Color', AppColors.borderColor, '边框和分割线'),
            const SizedBox(height: 16),
            Text(
              '使用说明',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            _buildUsageItem(context, '主色调 (Primary Blue)', '用于按钮、链接、重要元素'),
            _buildUsageItem(context, '深色调 (Dark Blue)', '用于标题栏、重要标题'),
            _buildUsageItem(context, '强调色 (Accent Blue)', '用于高亮、特殊元素'),
            _buildUsageItem(context, '背景色 (Light Blue)', '用于页面背景，营造层次感'),
          ],
        ),
      ),
    );
  }

  /// 构建颜色行
  static Widget _buildColorRow(BuildContext context, String name, Color color, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderColor),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建使用说明项
  static Widget _buildUsageItem(BuildContext context, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6, right: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 获取按钮样式展示
  static Widget getButtonShowcase(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '按钮样式 - 协调的蓝色系',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('主要按钮'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('次要按钮'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('文本按钮'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.favorite),
                    tooltip: '图标按钮',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '按钮特点：',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _buildFeatureItem(context, '统一的圆角设计 (8px)'),
            _buildFeatureItem(context, '协调的蓝色系配色'),
            _buildFeatureItem(context, '清晰的视觉层次'),
            _buildFeatureItem(context, '合适的间距和字体大小'),
          ],
        ),
      ),
    );
  }

  /// 构建特性项
  static Widget _buildFeatureItem(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: AppColors.successColor,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  /// 获取卡片样式展示
  static Widget getCardShowcase(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '卡片样式 - 清晰的层次结构',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '示例卡片',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '这是一个使用新协调配色方案的卡片示例，展示了文本、边框和背景的和谐搭配。',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {},
                          child: const Text('取消'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {},
                          child: const Text('确认'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '卡片特点：',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _buildFeatureItem(context, '白色背景，突出内容'),
            _buildFeatureItem(context, '轻微阴影，营造层次感'),
            _buildFeatureItem(context, '圆角设计，现代美观'),
            _buildFeatureItem(context, '合适的内边距和间距'),
          ],
        ),
      ),
    );
  }

  /// 获取输入框样式展示
  static Widget getInputShowcase(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '输入框样式 - 清晰的交互反馈',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: '用户名',
                hintText: '请输入用户名',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: '密码',
                hintText: '请输入密码',
                prefixIcon: Icon(Icons.lock),
                suffixIcon: Icon(Icons.visibility),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: '邮箱',
                hintText: '请输入邮箱地址',
                prefixIcon: Icon(Icons.email),
                errorText: '请输入有效的邮箱地址',
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '输入框特点：',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _buildFeatureItem(context, '清晰的边框和背景'),
            _buildFeatureItem(context, '聚焦时的蓝色高亮'),
            _buildFeatureItem(context, '错误状态的红色提示'),
            _buildFeatureItem(context, '合适的内边距和图标'),
          ],
        ),
      ),
    );
  }
}
