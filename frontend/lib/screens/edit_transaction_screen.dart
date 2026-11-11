import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/edit_transaction_bloc.dart';
import '../models/transaction.dart';

class EditTransactionScreen extends StatefulWidget {
  final Transaction transaction;

  const EditTransactionScreen({super.key, required this.transaction});

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _amountController;
  late final TextEditingController _categoryController;
  late final TextEditingController _descriptionController;

  late String _type;

  @override
  void initState() {
    super.initState();

    // Заполняем поля существующими данными
    _type = widget.transaction.type;

    _amountController = TextEditingController(text: widget.transaction.amount);

    _categoryController = TextEditingController(
      text: widget.transaction.category,
    );

    _descriptionController = TextEditingController(
      text: widget.transaction.description ?? '',
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Сохранение изменений
  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final description = _descriptionController.text.trim();

    context.read<EditTransactionBloc>().add(
      EditTransactionSubmitted(
        id: widget.transaction.id,
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
      appBar: AppBar(title: const Text('Редактировать операцию')),

      body: BlocConsumer<EditTransactionBloc, EditTransactionState>(
        listener: (context, state) {
          if (state is EditTransactionSuccess) {
            Navigator.of(context).pop(true);
          }

          if (state is EditTransactionFailure) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },

        builder: (context, state) {
          final isSaving = state is EditTransactionSaving;

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

                    onChanged: isSaving
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
                    enabled: !isSaving,

                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),

                    decoration: const InputDecoration(
                      labelText: 'Сумма (сом)',
                      border: OutlineInputBorder(),
                    ),

                    validator: (value) {
                      final amount = (value ?? '').trim().replaceAll(',', '.');

                      if (!RegExp(r'^\d{1,10}(\.\d{1,2})?$').hasMatch(amount)) {
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
                    enabled: !isSaving,
                    maxLength: 50,

                    decoration: const InputDecoration(
                      labelText: 'Категория',
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
                    enabled: !isSaving,
                    maxLines: 2,

                    decoration: const InputDecoration(
                      labelText: 'Описание',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  FilledButton.icon(
                    onPressed: isSaving ? null : _submit,

                    icon: isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),

                    label: Text(
                      isSaving ? 'Сохранение...' : 'Сохранить изменения',
                    ),
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
