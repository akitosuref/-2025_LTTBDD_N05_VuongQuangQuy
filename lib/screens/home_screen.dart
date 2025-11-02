import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../services/database_service.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _db = DatabaseService.instance;
  List<Transaction> _transactions = [];
  List<Category> _categories = [];
  double _totalIncome = 0.0;
  double _totalExpense = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadCategories();
    await _loadTransactions();
    await _loadTotals();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadCategories() async {
    final categories = await _db.getAllCategories();
    if (categories.isEmpty) {
      for (var catData in AppConstants.defaultCategories) {
        await _db.insertCategory(Category(
          name: catData['name'],
          icon: catData['icon'],
          color: catData['color'],
          type: catData['type'],
        ));
      }
      _categories = await _db.getAllCategories();
    } else {
      _categories = categories;
    }
  }

  Future<void> _loadTransactions() async {
    final transactions = await _db.getAllTransactions();
    setState(() {
      _transactions = transactions;
    });
  }

  Future<void> _loadTotals() async {
    final income = await _db.getTotalByType(AppConstants.income);
    final expense = await _db.getTotalByType(AppConstants.expense);
    setState(() {
      _totalIncome = income;
      _totalExpense = expense;
    });
  }

  Category? _getCategoryById(int id) {
    try {
      return _categories.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final balance = _totalIncome - _totalExpense;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initializeData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _initializeData,
              child: Column(
                children: [
                  _buildBalanceCard(context, balance, l10n),
                  Expanded(
                    child: _transactions.isEmpty
                        ? _buildEmptyState(l10n)
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _transactions.length,
                            itemBuilder: (context, index) {
                              final transaction = _transactions[index];
                              final category = _getCategoryById(transaction.categoryId);
                              return _buildTransactionCard(transaction, category, l10n);
                            },
                          ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-transaction').then((_) {
            _initializeData();
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, double balance, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            l10n.balance,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(balance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                l10n.income,
                _totalIncome,
                AppTheme.incomeColor,
                Icons.arrow_downward,
              ),
              _buildSummaryItem(
                l10n.expense,
                _totalExpense,
                AppTheme.expenseColor,
                Icons.arrow_upward,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, double amount, Color color, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(amount),
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.all(32),
      children: [
        const SizedBox(height: 40),
        Icon(
          Icons.receipt_long,
          size: 120,
          color: Colors.grey[300],
        ),
        const SizedBox(height: 24),
        Text(
          l10n.noTransactions,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Bắt đầu theo dõi chi tiêu của bạn bằng cách thêm giao dịch đầu tiên',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 32),
        Center(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/add-transaction').then((_) {
                _initializeData();
              });
            },
            icon: const Icon(Icons.add),
            label: const Text('Thêm giao dịch'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionCard(Transaction transaction, Category? category, AppLocalizations l10n) {
    final isIncome = transaction.type == AppConstants.income;
    final color = isIncome ? AppTheme.incomeColor : AppTheme.expenseColor;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: category?.color.withOpacity(0.2),
          child: Icon(
            category?.icon ?? Icons.help_outline,
            color: category?.color,
          ),
        ),
        title: Text(
          transaction.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          DateFormat('dd/MM/yyyy HH:mm').format(transaction.date),
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        trailing: Text(
          '${isIncome ? '+' : '-'}${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(transaction.amount)}',
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/edit-transaction',
            arguments: transaction,
          ).then((_) {
            _initializeData();
          });
        },
      ),
    );
  }
}
