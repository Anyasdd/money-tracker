import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/add_transaction_bloc.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();

  final _amountController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _type = 'expense';

  @override
  void dispose() {
    _amountController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Отправка формы
  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final description = _descriptionController.text.trim();

    context.read<AddTransactionBloc>().add(
      AddTransactionSubmitted(
        type: _type,
        amount: _amountController.text.trim().replaceAll(',', '.'),
        category: _categoryController.text.trim(),
        description: description.isEmpty ? null : description,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Новая операция')),

      body: BlocConsumer<AddTransactionBloc, AddTransactionState>(
        listener: (context, state) {
          // Успешное сохранение
          if (state is AddTransactionSuccess) {
            Navigator.of(context).pop(true);
          }

          // Ошибка сохранения
          if (state is AddTransactionFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Не удалось сохранить: ${state.message}')),
            );
          }
        },

        builder: (context, state) {
          final isSubmitting = state is AddTransactionSubmitting;

          return SafeArea(
            child: Form(
              key: _formKey,

              child: ListView(
                padding: const EdgeInsets.all(16),

                children: [
                  // Тип операции
                  DropdownButtonFormField<String>(
                    initialValue: _type,

                    decoration: const InputDecoration(
                      labelText: 'Тип операции',
                      border: OutlineInputBorder(),
                    ),

                    items: const [
                      DropdownMenuItem(value: 'expense', child: Text('Расход')),
                      DropdownMenuItem(value: 'income', child: Text('Доход')),
                    ],

                    onChanged: isSubmitting
                        ? null
                        : (value) {
                            if (value != null) {
                              setState(() {
                                _type = value;
                              });
                            }
                          },
                  ),

                  const SizedBox(height: 16),

                  // Сумма
                  TextFormField(
                    controller: _amountController,
                    enabled: !isSubmitting,

                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),

                    decoration: const InputDecoration(
                      labelText: 'Сумма (сом)',
                      hintText: 'Например, 450.50',
                      prefixIcon: Icon(Icons.payments_outlined),
                      border: OutlineInputBorder(),
                    ),

                    validator: (value) {
                      final amount = (value ?? '').trim().replaceAll(',', '.');

                      final validFormat = RegExp(r'^\d{1,10}(\.\d{1,2})?$')
                          .hasMatch(amount);

                      if (!validFormat) {
                        return 'Введите корректную сумму';
                      }

                      final number = double.tryParse(amount);

                      if (number == null || number <= 0) {
                        return 'Сумма должна быть больше нуля';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Категория
                  TextFormField(
                    controller: _categoryController,
                    enabled: !isSubmitting,
                    maxLength: 50,

                    decoration: const InputDecoration(
                      labelText: 'Категория',
                      hintText: 'Еда, Транспорт, Зарплата...',
                      border: OutlineInputBorder(),
                    ),

                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Укажи категорию';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 12),

                  // Описание
                  TextFormField(
                    controller: _descriptionController,
                    enabled: !isSubmitting,
                    maxLines: 2,

                    decoration: const InputDecoration(
                      labelText: 'Описание (необязательно)',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Кнопка сохранения
                  FilledButton.icon(
                    onPressed: isSubmitting ? null : _submit,

                    icon: isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined),

                    label: Text(isSubmitting ? 'Сохранение...' : 'Сохранить'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
