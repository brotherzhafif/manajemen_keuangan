import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/account_model.dart';
import '../../models/transaction_model.dart' as TransactionModel;
import '../transaction/add_transaction_wrapper.dart';

class AccountDetailScreen extends StatefulWidget {
  final Account account;

  const AccountDetailScreen({super.key, required this.account});

  @override
  State<AccountDetailScreen> createState() => _AccountDetailScreenState();
}

class _AccountDetailScreenState extends State<AccountDetailScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'en_US',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  // Method untuk mengkonversi string iconPath menjadi IconData
  IconData _getIconFromPath(String iconPath) {
    switch (iconPath) {
      case 'Icons.coffee':
        return Icons.coffee;
      case 'Icons.shopping_cart':
        return Icons.shopping_cart;
      case 'Icons.trending_up':
        return Icons.trending_up;
      case 'Icons.credit_card':
        return Icons.credit_card;
      default:
        return Icons.account_balance_wallet;
    }
  }

  // Method untuk memformat tanggal
  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy', 'en_US').format(date);
  }

  // Method untuk memotong deskripsi jika terlalu panjang
  String _truncateDescription(String description, int maxLength) {
    if (description.length <= maxLength) {
      return description;
    }
    return '${description.substring(0, maxLength)}...';
  }

  // Widget untuk item transaksi
  Widget _buildTransactionItem(TransactionModel.Transaction transaction) {
    final bool isIncome = transaction.jenis == 'masuk';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Bagian kiri: Deskripsi dan tanggal
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _truncateDescription(transaction.keterangan, 20),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(transaction.tanggal),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          // Bagian kanan: Total dan jenis transaksi
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isIncome ? '+' : '-'} ${currencyFormatter.format(transaction.total)}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isIncome ? Colors.green[600] : Colors.red[600],
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isIncome ? Colors.green[50] : Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isIncome ? 'Masuk' : 'Keluar',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: isIncome ? Colors.green[700] : Colors.red[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF47663C);
    const Color lightGreenColor = Color(0xFF8FBC94);
    final screenSize = MediaQuery.of(context).size;
    final horizontalPadding = screenSize.width * 0.05;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Detail Rekening',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigasi ke halaman tambah transaksi dengan kategori yang sudah dipilih
          Navigator.push(
             context,
             MaterialPageRoute(
               builder: (context) => AddTransactionWrapper(
                 preSelectedKategori: widget.account.name,
               ),
             ),
           );
        },
        backgroundColor: primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Tambah Transaksi',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Column(
        children: [
          // Header dengan informasi rekening
          Container(
            width: double.infinity,
            margin: EdgeInsets.all(horizontalPadding),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  backgroundColor: lightGreenColor,
                  radius: 35,
                  child: Icon(
                    _getIconFromPath(widget.account.iconPath),
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.account.name,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('transactions')
                      .where('user_id', isEqualTo: _auth.currentUser?.uid)
                      .where('kategori', isEqualTo: widget.account.name)
                      .snapshots(),
                  builder: (context, snapshot) {
                    double calculatedBalance = 0.0;
                    
                    if (snapshot.hasData) {
                      for (var doc in snapshot.data!.docs) {
                        final data = doc.data() as Map<String, dynamic>;
                        final total = (data['total'] ?? 0).toDouble();
                        final jenis = data['jenis'] as String;
                        
                        if (jenis == 'masuk') {
                          calculatedBalance += total;
                        } else {
                          calculatedBalance -= total;
                        }
                      }
                    }
                    
                    return Text(
                      currencyFormatter.format(calculatedBalance),
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    );
                  },
                ),
              ],
            ),
          ),
          
          // Section Riwayat Transaksi
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Row(
              children: [
                Text(
                  'Riwayat Transaksi',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          // Daftar Transaksi
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('transactions')
                    .where('user_id', isEqualTo: _auth.currentUser?.uid)
                    .where('kategori', isEqualTo: widget.account.name)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: primaryColor,
                      ),
                    );
                  }
                  
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Terjadi kesalahan saat memuat data',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }
                  
                  final transactions = snapshot.data?.docs ?? [];
                  
                  // Sort transaksi berdasarkan created_at secara manual
                  transactions.sort((a, b) {
                    try {
                      final aData = a.data() as Map<String, dynamic>;
                      final bData = b.data() as Map<String, dynamic>;
                      final aCreatedAt = aData['created_at']?.toDate() ?? DateTime.now();
                      final bCreatedAt = bData['created_at']?.toDate() ?? DateTime.now();
                      return bCreatedAt.compareTo(aCreatedAt); // Descending order
                    } catch (e) {
                      return 0; // Jika error, tidak mengubah urutan
                    }
                  });
                  
                  if (transactions.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada transaksi',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Transaksi untuk rekening ini akan muncul di sini',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      try {
                        final doc = transactions[index];
                        final data = doc.data() as Map<String, dynamic>;
                        final transaction = TransactionModel.Transaction.fromJson(
                          data,
                          doc.id,
                        );
                        
                        return _buildTransactionItem(transaction);
                      } catch (e) {
                        // Jika ada error parsing data, tampilkan item error
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red[600], size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Error memuat transaksi #${index + 1}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.red[600],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}