import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _totalController = TextEditingController();
  final TextEditingController _keteranganController = TextEditingController();
  
  String? _selectedKategori;
  DateTime? _selectedDate;
  String _jenisTransaksi = 'masuk';
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;  @override
  void dispose() {
    _totalController.dispose();
    _keteranganController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedKategori == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Pilih kategori terlebih dahulu',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Pilih tanggal terlebih dahulu',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      try {
        await _firestore.collection('transactions').add({
          'user_id': _auth.currentUser!.uid,
          'kategori': _selectedKategori,
          'total': double.parse(_totalController.text.replaceAll(',', '')),
          'tanggal': Timestamp.fromDate(_selectedDate!),
          'keterangan': _keteranganController.text,
          'jenis': _jenisTransaksi,
          'created_at': Timestamp.now(),
        });
        
        // Reset form
        _totalController.clear();
        _keteranganController.clear();
        setState(() {
          _selectedKategori = null;
          _selectedDate = null;
          _jenisTransaksi = 'masuk';
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Transaksi berhasil ditambahkan',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: const Color(0xFF47663C),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal menambahkan transaksi: $e',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final horizontalPadding = screenSize.width * 0.05; // 5% dari lebar layar
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tambah Transaksi',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    CircleAvatar(
                      backgroundColor: const Color(0xFF47663C),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Kategori Dropdown Field
                      StreamBuilder<QuerySnapshot>(
                        stream: _firestore
                            .collection('rekening')
                            .where('id_user', isEqualTo: _auth.currentUser?.uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Container(
                              height: 56,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF47663C),
                                ),
                              ),
                            );
                          }
                          
                          if (snapshot.hasError) {
                            return Container(
                              height: 56,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.red),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Center(
                                child: Text(
                                  'Error loading accounts',
                                  style: GoogleFonts.poppins(color: Colors.red),
                                ),
                              ),
                            );
                          }
                          
                          final accounts = snapshot.data?.docs ?? [];
                          
                          if (accounts.isEmpty) {
                            return Container(
                              height: 56,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Center(
                                child: Text(
                                  'Tidak ada rekening tersedia',
                                  style: GoogleFonts.poppins(color: Colors.grey[600]),
                                ),
                              ),
                            );
                          }
                          
                          return DropdownButtonFormField<String>(
                            value: _selectedKategori,
                            decoration: InputDecoration(
                              labelText: 'Kategori',
                              labelStyle: GoogleFonts.poppins(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                              hintText: 'Pilih kategori',
                              hintStyle: GoogleFonts.poppins(
                                color: Colors.grey[400],
                                fontSize: 16,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: const BorderSide(color: Color(0xFF47663C)),
                              ),
                            ),
                            items: accounts.map((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              final namaRekening = data['nama_rekening'] as String;
                              return DropdownMenuItem<String>(
                                value: namaRekening,
                                child: Text(
                                  namaRekening,
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedKategori = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Pilih kategori';
                              }
                              return null;
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 16.0),
                      
                      // Total Field
                      TextFormField(
                        controller: _totalController,
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Total',
                          labelStyle: GoogleFonts.poppins(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                          hintText: 'Masukkan jumlah',
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                          prefixText: 'Rp ',
                          prefixStyle: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(color: Color(0xFF47663C)),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Masukkan total';
                          }
                          if (double.tryParse(value.replaceAll(',', '')) == null) {
                            return 'Masukkan angka yang valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      
                      // Tanggal Field
                      TextFormField(
                        readOnly: true,
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Tanggal',
                          labelStyle: GoogleFonts.poppins(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                          hintText: _selectedDate == null 
                              ? 'Pilih tanggal' 
                              : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                          hintStyle: GoogleFonts.poppins(
                            color: _selectedDate == null ? Colors.grey[400] : Colors.black,
                            fontSize: 16,
                          ),
                          suffixIcon: const Icon(
                            Icons.calendar_today,
                            color: Color(0xFF47663C),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(color: Color(0xFF47663C)),
                          ),
                        ),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: Color(0xFF47663C),
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (date != null) {
                            setState(() {
                              _selectedDate = date;
                            });
                          }
                        },
                        controller: TextEditingController(
                          text: _selectedDate == null 
                              ? '' 
                              : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                        ),
                        validator: (value) {
                          if (_selectedDate == null) {
                            return 'Pilih tanggal';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      
                      // Keterangan Field
                      TextFormField(
                        controller: _keteranganController,
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Keterangan',
                          labelStyle: GoogleFonts.poppins(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                          hintText: 'Masukkan keterangan (opsional)',
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(color: Color(0xFF47663C)),
                          ),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16.0),
                      
                      // Jenis Transaksi Radio Buttons
                      Text(
                        'Jenis Transaksi',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: Text(
                                'Masuk',
                                style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                              value: 'masuk',
                              groupValue: _jenisTransaksi,
                              activeColor: const Color(0xFF47663C),
                              onChanged: (value) {
                                setState(() {
                                  _jenisTransaksi = value!;
                                });
                              },
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: Text(
                                'Keluar',
                                style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                              value: 'keluar',
                              groupValue: _jenisTransaksi,
                              activeColor: const Color(0xFF47663C),
                              onChanged: (value) {
                                setState(() {
                                  _jenisTransaksi = value!;
                                });
                              },
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF47663C),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Submit',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}