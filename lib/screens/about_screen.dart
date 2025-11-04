import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../l10n/app_localizations.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.about),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance_wallet,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppConstants.appName,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Version ${AppConstants.appVersion}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 40),
            _buildInfoCard(
              context,
              title: 'Nhóm',
              content: 'N05 - Lập trình thiết bị di động',
              icon: Icons.group,
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              context,
              title: 'Thành viên',
              content: 'Vương Quang Quý\nMSSV: 23010039\nEmail: 23010039@st.phenikaa-uni.edu.vn',
              icon: Icons.person,
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              context,
              title: 'Mô tả',
              content:
                  'Ứng dụng quản lý chi tiêu cá nhân giúp theo dõi thu chi, phân loại giao dịch và thống kê tài chính. Tính năng:\n• Theo dõi thu chi hàng ngày\n• Phân loại theo danh mục\n• Thống kê trực quan với biểu đồ\n• Hỗ trợ đa ngôn ngữ',
              icon: Icons.description,
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              context,
              title: 'Công nghệ',
              content: 'Flutter • Dart • SQLite • Material Design',
              icon: Icons.code,
            ),
            const SizedBox(height: 40),
            Text(
              '© 2025 Nhóm N05\nPhenikaa University',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
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
}
