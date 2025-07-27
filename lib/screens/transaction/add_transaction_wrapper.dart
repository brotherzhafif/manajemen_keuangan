import 'package:flutter/material.dart';
import 'add_transaction_screen.dart';
import '../report/report_screen.dart';

class AddTransactionWrapper extends StatefulWidget {
  final String? preSelectedKategori;
  
  const AddTransactionWrapper({super.key, this.preSelectedKategori});

  @override
  State<AddTransactionWrapper> createState() => _AddTransactionWrapperState();
}

class _AddTransactionWrapperState extends State<AddTransactionWrapper> {
  int _currentIndex = 1; // Start with transaction tab

  Widget _buildRekeningTab() {
    return const Center(
      child: Text(
        'Rekening Tab',
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF47663C);

    // List widget untuk setiap tab
    final List<Widget> pages = [
      _buildRekeningTab(),
      AddTransactionScreen(preSelectedKategori: widget.preSelectedKategori),
      const ReportScreen(),
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
          if (index == 0) {
            // Navigate back to home
            Navigator.pop(context);
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
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