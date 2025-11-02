import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../services/database_service.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../l10n/app_localizations.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final DatabaseService _db = DatabaseService.instance;
  List<Transaction> _transactions = [];
  List<Category> _categories = [];
  String _selectedPeriod = 'month';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final categories = await _db.getAllCategories();
    final transactions = await _db.getAllTransactions();
    setState(() {
      _categories = categories;
      _transactions = transactions;
      _isLoading = false;
    });
  }

  List<Transaction> get _filteredTransactions {
    final now = DateTime.now();
    DateTime startDate;

    switch (_selectedPeriod) {
      case 'today':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'week':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        break;
      case 'month':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'year':
        startDate = DateTime(now.year, 1, 1);
        break;
      default:
        return _transactions;
    }

    return _transactions
        .where((t) => t.date.isAfter(startDate) || t.date.isAtSameMomentAs(startDate))
        .toList();
  }

  Map<String, double> get _categoryExpenseData {
    final Map<String, double> data = {};
    for (var transaction in _filteredTransactions) {
      if (transaction.type == AppConstants.expense) {
        final category = _categories.firstWhere(
          (cat) => cat.id == transaction.categoryId,
          orElse: () => _categories.first,
        );
        data[category.name] = (data[category.name] ?? 0) + transaction.amount;
      }
    }
    return data;
  }

  double get _totalIncome {
    return _filteredTransactions
        .where((t) => t.type == AppConstants.income)
        .fold(0, (sum, t) => sum + t.amount);
  }

  double get _totalExpense {
    return _filteredTransactions
        .where((t) => t.type == AppConstants.expense)
        .fold(0, (sum, t) => sum + t.amount);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.statistics),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPeriodSelector(l10n),
                  const SizedBox(height: 20),
                  _buildSummaryCards(l10n),
                  const SizedBox(height: 30),
                  _buildPieChart(l10n),
                  const SizedBox(height: 30),
                  _buildCategoryList(l10n),
                ],
              ),
            ),
    );
  }

  Widget _buildPeriodSelector(AppLocalizations l10n) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildPeriodChip(l10n.today, 'today'),
          const SizedBox(width: 8),
          _buildPeriodChip(l10n.week, 'week'),
          const SizedBox(width: 8),
          _buildPeriodChip(l10n.month, 'month'),
          const SizedBox(width: 8),
          _buildPeriodChip(l10n.year, 'year'),
          const SizedBox(width: 8),
          _buildPeriodChip(l10n.all, 'all'),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(String label, String value) {
    final isSelected = _selectedPeriod == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedPeriod = value;
        });
      },
      selectedColor: AppTheme.primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSummaryCards(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            l10n.totalIncome,
            _totalIncome,
            AppTheme.incomeColor,
            Icons.arrow_downward,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            l10n.totalExpense,
            _totalExpense,
            AppTheme.expenseColor,
            Icons.arrow_upward,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, double amount, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(amount),
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(AppLocalizations l10n) {
    final data = _categoryExpenseData;
    if (data.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Text(
              l10n.noTransactions,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
      );
    }

    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.teal,
      Colors.amber,
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l10n.expense} by ${l10n.category}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: data.entries.map((entry) {
                    final index = data.keys.toList().indexOf(entry.key);
                    final percentage = (entry.value / _totalExpense * 100);
                    return PieChartSectionData(
                      value: entry.value,
                      title: '${percentage.toStringAsFixed(1)}%',
                      color: colors[index % colors.length],
                      radius: 80,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    );
                  }).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList(AppLocalizations l10n) {
    final data = _categoryExpenseData;
    if (data.isEmpty) return const SizedBox.shrink();

    final sortedEntries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l10n.category} Details',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...sortedEntries.map((entry) {
              final percentage = (entry.value / _totalExpense * 100);
              final category = _categories.firstWhere(
                (cat) => cat.name == entry.key,
                orElse: () => _categories.first,
              );
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(category.icon, color: category.color, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: percentage / 100,
                            backgroundColor: Colors.grey[200],
                            color: category.color,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          NumberFormat.currency(locale: 'vi_VN', symbol: '₫')
                              .format(entry.value),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
