import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../account/add_account_screen.dart';
import '../account/account_detail_screen.dart';
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
  List<Account> _accounts = [];
  final NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'en_US',
    symbol: 'Rp ',
    decimalDigits: 0,
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

    // Ambil semua transaksi user untuk kalkulasi saldo real-time
    final transactionsSnapshot = await FirebaseFirestore.instance
        .collection('transactions')
        .where('user_id', isEqualTo: user.uid)
        .get();

    // Hitung saldo per rekening berdasarkan transaksi
    Map<String, double> accountBalances = {};

    for (var transactionDoc in transactionsSnapshot.docs) {
      final transactionData = transactionDoc.data();
      final kategori = transactionData['kategori'] as String;
      final total = (transactionData['total'] ?? 0).toDouble();
      final jenis = transactionData['jenis'] as String;

      if (!accountBalances.containsKey(kategori)) {
        accountBalances[kategori] = 0.0;
      }

      if (jenis == 'masuk') {
        accountBalances[kategori] = accountBalances[kategori]! + total;
      } else {
        accountBalances[kategori] = accountBalances[kategori]! - total;
      }
    }

    List<Account> accounts = rekeningSnapshot.docs.map((doc) {
      final data = doc.data();
      final accountName = data['nama_rekening'] ?? '';
      final calculatedBalance = accountBalances[accountName] ?? 0.0;

      return Account(
        id: doc.id,
        name: accountName,
        balance: calculatedBalance,
        iconPath: data['iconPath'] ?? '',
      );
    }).toList();

    setState(() {
      _accounts = accounts;
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
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      _userName.length > 20
                          ? _userName.substring(0, 20) + '...'
                          : _userName,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                PopupMenuButton<String>(
                  icon: const CircleAvatar(
                    radius: 24,
                    backgroundColor: Color(0xFF47663C),
                    child: Icon(Icons.person, color: Colors.white, size: 28),
                  ),
                  onSelected: (value) async {
                    if (value == 'profile') {
                      Navigator.pushNamed(context, '/profile');
                    } else if (value == 'logout') {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushReplacementNamed(context, '/');
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'profile',
                      child: Text('Profil'),
                    ),
                    const PopupMenuItem(value: 'logout', child: Text('Logout')),
                  ],
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
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('transactions')
                        .where(
                          'user_id',
                          isEqualTo: FirebaseAuth.instance.currentUser?.uid,
                        )
                        .snapshots(),
                    builder: (context, snapshot) {
                      double totalBalance = 0.0;

                      if (snapshot.hasData && _accounts.isNotEmpty) {
                        Map<String, double> accountBalances = {};

                        for (var transactionDoc in snapshot.data!.docs) {
                          final transactionData =
                              transactionDoc.data() as Map<String, dynamic>;
                          final kategori =
                              transactionData['kategori'] as String;
                          final total = (transactionData['total'] ?? 0)
                              .toDouble();
                          final jenis = transactionData['jenis'] as String;

                          if (!accountBalances.containsKey(kategori)) {
                            accountBalances[kategori] = 0.0;
                          }

                          if (jenis == 'masuk') {
                            accountBalances[kategori] =
                                accountBalances[kategori]! + total;
                          } else {
                            accountBalances[kategori] =
                                accountBalances[kategori]! - total;
                          }
                        }

                        for (var account in _accounts) {
                          totalBalance += accountBalances[account.name] ?? 0.0;
                        }
                      }

                      return Text(
                        currencyFormatter.format(totalBalance),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
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
                Text(
                  'Rekening',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: _accounts.length,
                  itemBuilder: (context, index) {
                    final account = _accounts[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AccountDetailScreen(account: account),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(1),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                backgroundColor: lightGreenColor,
                                radius: 25,
                                child: Icon(
                                  _getIconFromPath(account.iconPath),
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                account.name.length > 18
                                    ? account.name.substring(0, 18) + '...'
                                    : account.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('transactions')
                                    .where(
                                      'user_id',
                                      isEqualTo: FirebaseAuth
                                          .instance
                                          .currentUser
                                          ?.uid,
                                    )
                                    .where('kategori', isEqualTo: account.name)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  double accountBalance = 0.0;

                                  if (snapshot.hasData) {
                                    for (var doc in snapshot.data!.docs) {
                                      final data =
                                          doc.data() as Map<String, dynamic>;
                                      final total = (data['total'] ?? 0)
                                          .toDouble();
                                      final jenis = data['jenis'] as String;

                                      if (jenis == 'masuk') {
                                        accountBalance += total;
                                      } else {
                                        accountBalance -= total;
                                      }
                                    }
                                  }

                                  return Text(
                                    currencyFormatter.format(accountBalance),
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  );
                                },
                              ),
                            ],
                          ),
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
    return Stack(children: [const AddTransactionScreen()]);
  }

  // Widget untuk tab laporan
  Widget _buildLaporanTab() {
    return Stack(children: [const ReportScreen()]);
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
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
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
              backgroundColor: primaryColor,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                'Tambah Rekening',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          : null,
    );
  }
}
