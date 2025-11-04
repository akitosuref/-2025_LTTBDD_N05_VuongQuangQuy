import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../utils/app_theme.dart';
import '../l10n/app_localizations.dart';
import 'edit_profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;

  const SettingsScreen({super.key, required this.onThemeChanged});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  ThemeMode _currentThemeMode = ThemeMode.system;
  bool _isLoading = true;
  UserProfile? _userProfile;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadThemePreference();
    await _loadUserProfile();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('theme_mode') ?? 0;
    setState(() {
      _currentThemeMode = ThemeMode.values[themeIndex];
    });
  }

  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString('user_profile');
    
    setState(() {
      if (profileJson != null) {
        _userProfile = UserProfile.fromJson(json.decode(profileJson));
      }
      _isLoading = false;
    });
  }

  Future<void> _saveThemePreference(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
    setState(() {
      _currentThemeMode = mode;
    });
    widget.onThemeChanged(mode);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          _buildUserProfile(),
          const Divider(height: 32),
          _buildSection('Giao diện'),
          _buildThemeOption(
            'Sáng',
            Icons.light_mode,
            ThemeMode.light,
          ),
          _buildThemeOption(
            'Tối',
            Icons.dark_mode,
            ThemeMode.dark,
          ),
          _buildThemeOption(
            'Theo hệ thống',
            Icons.brightness_auto,
            ThemeMode.system,
          ),
          const Divider(height: 32),
          _buildSection('Thông tin'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Phiên bản'),
            subtitle: const Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.developer_mode),
            title: const Text('Phát triển bởi'),
            subtitle: const Text('Nhóm N05 - Vương Quang Quý'),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfile() {
    return InkWell(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EditProfileScreen()),
        );
        if (result == true) {
          _loadUserProfile();
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 35,
              backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
              child: Icon(
                Icons.person,
                size: 35,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _userProfile?.name ?? 'Chưa có tên',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _userProfile?.email ?? 'Nhấn để chỉnh sửa thông tin',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildThemeOption(String title, IconData icon, ThemeMode mode) {
    final isSelected = _currentThemeMode == mode;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppTheme.primaryColor : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppTheme.primaryColor : null,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check, color: AppTheme.primaryColor)
          : null,
      onTap: () => _saveThemePreference(mode),
    );
  }
}
