import 'package:flutter/material.dart';

class CategoryChips extends StatelessWidget {
  final String type;
  final String selectedCategory;
  final bool enabled;
  final ValueChanged<String> onSelected;

  const CategoryChips({
    super.key,
    required this.type,
    required this.selectedCategory,
    required this.enabled,
    required this.onSelected,
  });

  static const expenseCategories = [
    'Еда',
    'Транспорт',
    'Покупки',
    'Жильё',
    'Развлечения',
    'Здоровье',
    'Учёба',
    'Другое',
  ];

  static const incomeCategories = [
    'Зарплата',
    'Подработка',
    'Подарки',
    'Возврат',
    'Другое',
  ];

  @override
  Widget build(BuildContext context) {
    final categories = type == 'income' ? incomeCategories : expenseCategories;

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: categories.map((category) {
        return ChoiceChip(
          label: Text(category),
          selected: selectedCategory == category,
          onSelected: enabled ? (_) => onSelected(category) : null,
        );
      }).toList(),
    );
  }
}
