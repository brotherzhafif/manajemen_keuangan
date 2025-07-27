import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
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
  final String _userName = "Taufik Kurniawan";
  final double _totalBalance = 3500000.00; // Total saldo tetap untuk UI
  
  // Data untuk rekening (menggunakan kategori anggaran)
  final List<Account> _accounts = [
    Account(
      id: '1',
      name: 'Kebutuhan',
      balance: 2000000.00,
      iconPath: 'Icons.coffee',
    ),
    Account(
      id: '2',
      name: 'Keinginan',
      balance: 500000.00,
      iconPath: 'Icons.shopping_cart',
    ),
    Account(
      id: '3',
      name: 'Investasi',
      balance: 800000.00,
      iconPath: 'Icons.trending_up',
    ),
    Account(
      id: '4',
      name: 'Tabungan',
      balance: 200000.00,
      iconPath: 'Icons.credit_card',
    ),
  ];
  
  // Format currency
  final NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 2,
  );
  
  @override
  void initState() {
    super.initState();
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
                      icon: const Icon(Icons.add_circle, color: Color(0xFF47663C)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddAccountScreen(),
                          ),
                        );
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
      body: SafeArea(
        child: pages[_currentIndex],
      ),
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
          BottomNavigationBarItem(
            icon: Icon(Icons.wallet),
            label: 'Rekening',
          ),
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