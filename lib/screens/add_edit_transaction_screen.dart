import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../services/database_service.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddEditTransactionScreen extends StatefulWidget {
  final Transaction? transaction;

  const AddEditTransactionScreen({super.key, this.transaction});

  @override
  State<AddEditTransactionScreen> createState() => _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends State<AddEditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _db = DatabaseService.instance;
  
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  
  String _selectedType = AppConstants.expense;
  Category? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  List<Category> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.transaction?.title ?? '');
    _amountController = TextEditingController(
      text: widget.transaction?.amount.toString() ?? '',
    );
    _noteController = TextEditingController(text: widget.transaction?.note ?? '');
    
    if (widget.transaction != null) {
      _selectedType = widget.transaction!.type;
      _selectedDate = widget.transaction!.date;
    }
    
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await _db.getAllCategories();
    setState(() {
      _categories = categories;
      if (widget.transaction != null) {
        _selectedCategory = categories.firstWhere(
          (cat) => cat.id == widget.transaction!.categoryId,
          orElse: () => categories.first,
        );
      }
      _isLoading = false;
    });
  }

  List<Category> get _filteredCategories {
    return _categories.where((cat) => cat.type == _selectedType).toList();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    
    if (picked != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );
      
      if (time != null) {
        setState(() {
          _selectedDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.selectCategory),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final transaction = Transaction(
        id: widget.transaction?.id,
        title: _titleController.text,
        amount: double.parse(_amountController.text),
        type: _selectedType,
        categoryId: _selectedCategory!.id!,
        date: _selectedDate,
        note: _noteController.text.isEmpty ? null : _noteController.text,
      );

      if (widget.transaction == null) {
        await _db.insertTransaction(transaction);
      } else {
        await _db.updateTransaction(transaction);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _deleteTransaction() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.confirm),
        content: Text(AppLocalizations.of(context)!.delete),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              AppLocalizations.of(context)!.delete,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.transaction != null) {
      await _db.deleteTransaction(widget.transaction!.id!);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEdit = widget.transaction != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? l10n.editTransaction : l10n.addTransaction),
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteTransaction,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTypeSelector(l10n),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _titleController,
                      label: l10n.title,
                      icon: Icons.title,
                      validator: (value) =>
                          value?.isEmpty ?? true ? l10n.title : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _amountController,
                      label: l10n.amount,
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) return l10n.amount;
                        if (double.tryParse(value!) == null) {
                          return 'Invalid amount';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildCategorySelector(l10n),
                    const SizedBox(height: 16),
                    _buildDateSelector(l10n),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _noteController,
                      label: l10n.note,
                      icon: Icons.note,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saveTransaction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          l10n.save,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTypeSelector(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedType = AppConstants.income;
                  _selectedCategory = null;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedType == AppConstants.income
                      ? AppTheme.incomeColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    l10n.income,
                    style: TextStyle(
                      color: _selectedType == AppConstants.income
                          ? Colors.white
                          : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedType = AppConstants.expense;
                  _selectedCategory = null;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedType == AppConstants.expense
                      ? AppTheme.expenseColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    l10n.expense,
                    style: TextStyle(
                      color: _selectedType == AppConstants.expense
                          ? Colors.white
                          : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
    );
  }

  Widget _buildCategorySelector(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.category,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _filteredCategories.map((category) {
            final isSelected = _selectedCategory?.id == category.id;
            return FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(category.icon, size: 16, color: category.color),
                  const SizedBox(width: 4),
                  Text(category.name),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
              },
              selectedColor: category.color.withOpacity(0.3),
              backgroundColor: Colors.grey[200],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateSelector(AppLocalizations l10n) {
    return InkWell(
      onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: l10n.date,
          prefixIcon: const Icon(Icons.calendar_today),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          DateFormat('dd/MM/yyyy HH:mm').format(_selectedDate),
        ),
      ),
    );
  }
}
