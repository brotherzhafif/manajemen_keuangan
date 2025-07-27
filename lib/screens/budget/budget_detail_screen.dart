import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class BudgetDetailScreen extends StatelessWidget {
  final Map<String, dynamic> category;
  
  const BudgetDetailScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    // Format currency
    final NumberFormat currencyFormatter = NumberFormat.currency(
     locale: 'en_US',
       symbol: 'Rp ',
       decimalDigits: 0,
    );
    
    // Warna yang digunakan
    const Color primaryColor = Color(0xFF47663C);
    const Color lightGreenColor = Color(0xFF8FBC94);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detail ${category['name']}',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card informasi saldo
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: lightGreenColor,
                            child: Icon(
                              category['icon'],
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Saldo ${category['name']}',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                currencyFormatter.format(category['amount']),
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      Text(
                        'Rincian Pengeluaran',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Contoh rincian pengeluaran
                      _buildExpenseItem(
                        'Belanja Bulanan', 
                        '01 Mei 2023', 
                        150000.0, 
                        currencyFormatter
                      ),
                      _buildExpenseItem(
                        'Makan Siang', 
                        '05 Mei 2023', 
                        75000.0, 
                        currencyFormatter
                      ),
                      _buildExpenseItem(
                        'Transportasi', 
                        '10 Mei 2023', 
                        50000.0, 
                        currencyFormatter
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Tombol tambah pengeluaran
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Implementasi tambah pengeluaran
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Tambah Pengeluaran',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Widget untuk item pengeluaran
  Widget _buildExpenseItem(String title, String date, double amount, NumberFormat formatter) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                date,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          Text(
            formatter.format(amount),
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}