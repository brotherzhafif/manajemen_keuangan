import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  bool isMonthlySelected = true;
  int selectedYear = DateTime.now().year;
  final NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'en_US',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  List<Map<String, dynamic>> transactions = [];
  double totalMasuk = 0;
  double totalKeluar = 0;
  List<FlSpot> pemasukanData = [];
  List<FlSpot> pengeluaranData = [];

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('transactions')
        .where('user_id', isEqualTo: user.uid)
        .get();

    transactions = snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'title': data['keterangan'] ?? '',
        'jenis': data['jenis'] ?? '',
        'amount': (data['total'] ?? 0).toDouble(),
        'date': (data['tanggal'] as Timestamp).toDate(),
      };
    }).toList();

    _processData();
    setState(() {});
  }

  void _processData() {
    totalMasuk = 0;
    totalKeluar = 0;
    pemasukanData = [];
    pengeluaranData = [];
    Map<int, double> monthlyMasuk = {};
    Map<int, double> monthlyKeluar = {};
    Map<int, double> yearlyMasuk = {};
    Map<int, double> yearlyKeluar = {};
    Set<int> tahunSet = {};
    for (var tx in transactions) {
      final jenis = tx['jenis'] ?? '';
      final amount = (tx['amount'] ?? 0).toDouble();
      final date = tx['date'] is DateTime
          ? tx['date'] as DateTime
          : DateTime.now();
      final month = date.month;
      final year = date.year;
      if (isMonthlySelected) {
        if (year == selectedYear) {
          if (jenis == 'masuk') {
            totalMasuk += amount;
            monthlyMasuk[month] = (monthlyMasuk[month] ?? 0) + amount;
          } else if (jenis == 'keluar') {
            totalKeluar += amount;
            monthlyKeluar[month] = (monthlyKeluar[month] ?? 0) + amount;
          }
        }
      } else {
        tahunSet.add(year);
        if (jenis == 'masuk') {
          totalMasuk += amount;
          yearlyMasuk[year] = (yearlyMasuk[year] ?? 0) + amount;
        } else if (jenis == 'keluar') {
          totalKeluar += amount;
          yearlyKeluar[year] = (yearlyKeluar[year] ?? 0) + amount;
        }
      }
    }
    if (isMonthlySelected) {
      for (int i = 1; i <= 12; i++) {
        pemasukanData.add(FlSpot(i.toDouble(), monthlyMasuk[i] ?? 0));
        pengeluaranData.add(FlSpot(i.toDouble(), monthlyKeluar[i] ?? 0));
      }
    } else {
      final tahunList = tahunSet.toList()..sort();
      for (var tahun in tahunList) {
        pemasukanData.add(FlSpot(tahun.toDouble(), yearlyMasuk[tahun] ?? 0));
        pengeluaranData.add(FlSpot(tahun.toDouble(), yearlyKeluar[tahun] ?? 0));
      }
    }
  }

  double _getHorizontalInterval() {
    final maxValue = totalMasuk > totalKeluar ? totalMasuk : totalKeluar;
    if (maxValue == 0) {
      return 1000000; // Default interval when no data
    }
    return (maxValue / 10).ceilToDouble();
  }

  double _getMaxY() {
    final maxValue = totalMasuk > totalKeluar ? totalMasuk : totalKeluar;
    if (maxValue == 0) {
      return 10000000; // Default max value when no data
    }
    // Maximum nominal + (maximum nominal * 90%)
    return maxValue + (maxValue * 0.25);
  }

  List<PieChartSectionData> get pieData {
    final total = totalMasuk + totalKeluar;
    final masukPercent = total == 0 ? 0 : (totalMasuk / total) * 100;
    final keluarPercent = total == 0 ? 0 : (totalKeluar / total) * 100;
    return [
      PieChartSectionData(
        value: masukPercent.toDouble(),
        color: const Color(0xFF2196F3),
        title: '${masukPercent.toStringAsFixed(0)}%',
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        radius: 60,
      ),
      PieChartSectionData(
        value: keluarPercent.toDouble(),
        color: const Color(0xFFF44336),
        title: '${keluarPercent.toStringAsFixed(0)}%',
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        radius: 60,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF47663C);
    final screenSize = MediaQuery.of(context).size;
    final horizontalPadding = screenSize.width * 0.05;

    // Filter controls
    Widget filterControls = Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isMonthlySelected
                  ? primaryColor
                  : Colors.grey[300],
              foregroundColor: isMonthlySelected ? Colors.white : Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              setState(() {
                isMonthlySelected = true;
                _processData();
              });
            },
            child: const Text('Bulanan'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: !isMonthlySelected
                  ? primaryColor
                  : Colors.grey[300],
              foregroundColor: !isMonthlySelected ? Colors.white : Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              setState(() {
                isMonthlySelected = false;
                _processData();
              });
            },
            child: const Text('Tahunan'),
          ),
        ),
        if (isMonthlySelected) ...[
          const SizedBox(width: 8),
          DropdownButton<int>(
            value: selectedYear,
            items: List.generate(5, (i) {
              int year = DateTime.now().year - i;
              return DropdownMenuItem(
                value: year,
                child: Text(
                  year.toString(),
                  style: const TextStyle(color: Colors.black),
                ),
              );
            }),
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  selectedYear = val;
                  _processData();
                });
              }
            },
            dropdownColor: Colors.white,
            style: const TextStyle(color: Colors.black),
          ),
        ],
      ],
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                filterControls,
                const SizedBox(height: 16),
                // Pie Chart Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Pengeluaran vs Pemasukan',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 200,
                        child: PieChart(
                          PieChartData(
                            sections: pieData,
                            centerSpaceRadius: 40,
                            sectionsSpace: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // ...existing code...
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Line Chart Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        isMonthlySelected ? 'Trend Bulanan' : 'Trend Tahunan',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 320,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: isMonthlySelected ? 600 : 400,
                            child: LineChart(
                              LineChartData(
                                lineTouchData: LineTouchData(
                                  enabled: true,
                                  touchTooltipData: LineTouchTooltipData(
                                    getTooltipColor: (touchedSpot) => Colors.white,
                                    tooltipPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    tooltipMargin: 8,
                                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                                       return touchedBarSpots.map((barSpot) {
                                         final flSpot = barSpot;
                                         // Determine color based on bar index: 0 = pemasukan (blue), 1 = pengeluaran (red)
                                         Color textColor = barSpot.barIndex == 0 
                                             ? const Color(0xFF2196F3) // Blue for pemasukan
                                             : const Color(0xFFF44336); // Red for pengeluaran
                                         return LineTooltipItem(
                                           currencyFormatter.format(flSpot.y),
                                           TextStyle(
                                             color: textColor,
                                             fontWeight: FontWeight.w600,
                                             fontSize: 12,
                                           ),
                                         );
                                       }).toList();
                                     },
                                  ),
                                ),
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: true,
                                  horizontalInterval: _getHorizontalInterval(),
                                  verticalInterval: 1,
                                  getDrawingHorizontalLine: (value) {
                                    return FlLine(
                                      color: Colors.grey[300]!,
                                      strokeWidth: 1,
                                    );
                                  },
                                  getDrawingVerticalLine: (value) {
                                    return FlLine(
                                      color: Colors.grey[300]!,
                                      strokeWidth: 1,
                                    );
                                  },
                                ),
                                titlesData: FlTitlesData(
                                  show: true,
                                  rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 30,
                                      interval: 1,
                                      getTitlesWidget:
                                          (double value, TitleMeta meta) {
                                            Widget text;
                                            const labelStyle = TextStyle(
                                              color: Colors.black,
                                              fontSize: 12,
                                            );
                                            if (isMonthlySelected) {
                                              const monthNames = [
                                                '',
                                                'Jan',
                                                'Feb',
                                                'Mar',
                                                'Apr',
                                                'Mei',
                                                'Jun',
                                                'Jul',
                                                'Agu',
                                                'Sep',
                                                'Okt',
                                                'Nov',
                                                'Des',
                                              ];
                                              int monthIdx = value.toInt();
                                              text = Text(
                                                monthIdx >= 1 && monthIdx <= 12
                                                    ? monthNames[monthIdx]
                                                    : '',
                                                style: labelStyle,
                                              );
                                            } else {
                                              text = Text(
                                                value.toInt().toString(),
                                                style: labelStyle,
                                              );
                                            }
                                            return SideTitleWidget(
                                              axisSide: meta.axisSide,
                                              child: text,
                                            );
                                          },
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      interval: _getHorizontalInterval(),
                                      getTitlesWidget: (double value, TitleMeta meta) {
                                        return Text(
                                          isMonthlySelected
                                              ? '${(value / 1000000).toInt()}M'
                                              : '${(value / 1000000).toInt()}M',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black,
                                          ),
                                        );
                                      },
                                      reservedSize: 42,
                                    ),
                                  ),
                                ),
                                borderData: FlBorderData(
                                  show: true,
                                  border: Border.all(
                                    color: Colors.grey[300]!,
                                    width: 1,
                                  ),
                                ),
                                minX: isMonthlySelected
                                    ? 1
                                    : (pemasukanData.isNotEmpty
                                          ? pemasukanData.first.x
                                          : 1),
                                maxX: isMonthlySelected
                                    ? 12
                                    : (pemasukanData.isNotEmpty
                                          ? pemasukanData.last.x
                                          : 12),
                                minY: 0,
                                maxY: _getMaxY(),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: pemasukanData,
                                    isCurved: true,
                                    color: const Color(0xFF2196F3),
                                    barWidth: 3,
                                    isStrokeCapRound: true,
                                    dotData: const FlDotData(show: true),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      color: const Color(
                                        0xFF2196F3,
                                      ).withOpacity(0.1),
                                    ),
                                  ),
                                  LineChartBarData(
                                    spots: pengeluaranData,
                                    isCurved: true,
                                    color: const Color(0xFFF44336),
                                    barWidth: 3,
                                    isStrokeCapRound: true,
                                    dotData: const FlDotData(show: true),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      color: const Color(
                                        0xFFF44336,
                                      ).withOpacity(0.1),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Summary Cards
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Pengeluaran',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currencyFormatter.format(totalKeluar),
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFF44336),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Pemasukan',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currencyFormatter.format(totalMasuk),
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2196F3),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Transaction History Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Riwayat Transaksi',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: transactions.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final transaction = transactions[index];
                          final isKeluar = transaction['jenis'] == 'keluar';
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                transaction['title'] ?? '',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                '${isKeluar ? '-' : '+'}${currencyFormatter.format(transaction['amount'] ?? 0)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isKeluar
                                      ? const Color(0xFFF44336)
                                      : const Color(0xFF2196F3),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
