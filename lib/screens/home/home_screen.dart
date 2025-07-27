import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../account/add_account_screen.dart';
import '../transaction/add_transaction_screen.dart';
import '../report/report_screen.dart';
import '../../models/account_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String _userName = "";
  double _totalBalance = 0.0;
  List<Account> _accounts = [];
  final NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    _fetchUserAndAccounts();
  }

  Future<void> _fetchUserAndAccounts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    // Ambil nama user
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    setState(() {
      _userName = userDoc.data()?['firstname'] ?? '';
    });
    // Ambil rekening user
    final rekeningSnapshot = await FirebaseFirestore.instance
        .collection('rekening')
        .where('id_user', isEqualTo: user.uid)
        .get();
    double total = 0.0;
    List<Account> accounts = rekeningSnapshot.docs.map((doc) {
      final data = doc.data();
      total += (data['jumlah_saldo'] ?? 0).toDouble();
      return Account(
        id: doc.id,
        name: data['nama_rekening'] ?? '',
        balance: (data['jumlah_saldo'] ?? 0).toDouble(),
        iconPath: data['iconPath'] ?? '',
      );
    }).toList();
    setState(() {
      _accounts = accounts;
      _totalBalance = total;
    });
  }

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

  // Widget untuk setiap tab
  Widget _buildRekeningTab() {
    final screenSize = MediaQuery.of(context).size;
    final horizontalPadding = screenSize.width * 0.05;
    const Color primaryColor = Color(0xFF47663C);
    const Color lightGreenColor = Color(0xFF8FBC94);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header dengan welcome text dan avatar
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome Back',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      _userName,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    // Navigasi ke halaman profil
                    // Navigator.pushNamed(context, '/profile');
                  },
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFF47663C),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Card Total Saldo
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Saldo',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currencyFormatter.format(_totalBalance),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Section Rekening
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rekening',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.add_circle,
                        color: Color(0xFF47663C),
                      ),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddAccountScreen(),
                          ),
                        );
                        // Reload rekening setelah tambah
                        _fetchUserAndAccounts();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: _accounts.length,
                  itemBuilder: (context, index) {
                    final account = _accounts[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundColor: lightGreenColor,
                              child: Icon(
                                _getIconFromPath(account.iconPath),
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              account.name,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              currencyFormatter.format(account.balance),
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Padding bawah untuk memberikan ruang
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // Widget untuk tab transaksi
  Widget _buildTransaksiTab() {
    return const AddTransactionScreen();
  }

  // Widget untuk tab laporan
  Widget _buildLaporanTab() {
    return const ReportScreen();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF47663C);

    // List widget untuk setiap tab
    final List<Widget> pages = [
      _buildRekeningTab(),
      _buildTransaksiTab(),
      _buildLaporanTab(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: pages[_currentIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.wallet), label: 'Rekening'),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            label: 'Transaksi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Laporan',
          ),
        ],
      ),
    );
  }
}
