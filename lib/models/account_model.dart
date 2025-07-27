class Account {
  final String id;
  final String name;
  final double balance;
  final String iconPath; // Path ke icon SVG atau nama icon dari material icons

  Account({
    required this.id,
    required this.name,
    required this.balance,
    required this.iconPath,
  });

  // Untuk konversi dari dan ke JSON jika diperlukan nanti
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'balance': balance,
      'iconPath': iconPath,
    };
  }

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'],
      name: json['name'],
      balance: json['balance'],
      iconPath: json['iconPath'],
    );
  }
}