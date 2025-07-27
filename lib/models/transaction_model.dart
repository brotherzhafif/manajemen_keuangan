class Transaction {
  final String id;
  final String userId;
  final String kategori;
  final double total;
  final DateTime tanggal;
  final String keterangan;
  final String jenis; // 'masuk' atau 'keluar'
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.userId,
    required this.kategori,
    required this.total,
    required this.tanggal,
    required this.keterangan,
    required this.jenis,
    required this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json, String id) {
    DateTime parseTanggal() {
      try {
        if (json['tanggal'] != null) {
          return json['tanggal'].toDate();
        }
      } catch (e) {
        // Jika gagal parsing tanggal, gunakan DateTime.now()
      }
      return DateTime.now();
    }
    
    DateTime parseCreatedAt() {
      try {
        if (json['created_at'] != null) {
          return json['created_at'].toDate();
        }
      } catch (e) {
        // Jika gagal parsing created_at, gunakan DateTime.now()
      }
      return DateTime.now();
    }
    
    return Transaction(
      id: id,
      userId: json['user_id']?.toString() ?? '',
      kategori: json['kategori']?.toString() ?? '',
      total: double.tryParse(json['total']?.toString() ?? '0') ?? 0.0,
      tanggal: parseTanggal(),
      keterangan: json['keterangan']?.toString() ?? '',
      jenis: json['jenis']?.toString() ?? 'masuk',
      createdAt: parseCreatedAt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'kategori': kategori,
      'total': total,
      'tanggal': tanggal,
      'keterangan': keterangan,
      'jenis': jenis,
      'created_at': createdAt,
    };
  }
}