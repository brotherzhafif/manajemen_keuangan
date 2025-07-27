import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddAccountScreen extends StatefulWidget {
  const AddAccountScreen({super.key});

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // UI-only: Tampilkan pesan sukses tanpa menambahkan data
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rekening berhasil ditambahkan (UI Demo)'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tambah Rekening',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF47663C),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'Nama Rekening',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama rekening tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _balanceController,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'Jumlah Saldo',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah saldo tidak boleh kosong';
                  }
                  try {
                    double.parse(value.replaceAll('.', ''));
                  } catch (e) {
                    return 'Format saldo tidak valid';
                  }
                  return null;
                },
                onChanged: (value) {
                  // Format the input as currency
                  if (value.isNotEmpty) {
                    try {
                      final numericValue = value.replaceAll('.', '');
                      final formattedValue = _formatCurrency(numericValue);
                      if (formattedValue != value) {
                        _balanceController.value = TextEditingValue(
                          text: formattedValue,
                          selection: TextSelection.collapsed(
                            offset: formattedValue.length,
                          ),
                        );
                      }
                    } catch (e) {
                      // Ignore formatting errors
                    }
                  }
                },
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF47663C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  'Tambahkan',
                  style: GoogleFonts.poppins(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCurrency(String value) {
    if (value.isEmpty) return '';
    final numericValue = double.parse(value);
    final parts = numericValue.toStringAsFixed(0).split('');
    String result = '';
    for (int i = 0; i < parts.length; i++) {
      if (i > 0 && (parts.length - i) % 3 == 0) {
        result += '.';
      }
      result += parts[i];
    }
    return result;
  }
}