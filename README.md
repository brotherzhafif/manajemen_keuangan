# fin_tracker

Aplikasi manajemen keuangan berbasis Flutter untuk mencatat pemasukan, pengeluaran, dan memantau saldo rekening secara real-time.

## Fitur Utama

- Manajemen rekening (tambah, detail, saldo otomatis)
- Pencatatan transaksi (pemasukan & pengeluaran)
- Laporan keuangan (grafik pie & line, riwayat transaksi)
- Autentikasi pengguna (Firebase Auth)
- Penyimpanan data di Cloud Firestore
- Profil pengguna

## Instalasi & Setup

1. **Install dependencies**

   ```bash
   flutter pub get
   ```

2. **Setup Firebase**

   - Buat project di [Firebase Console](https://console.firebase.google.com/)
   - Tambahkan aplikasi Android/iOS ke project Firebase
   - Download file `google-services.json` (Android) dan/atau `GoogleService-Info.plist` (iOS) ke folder yang sesuai (`android/app` dan `ios/Runner`)
   - Aktifkan Authentication dan Firestore di Firebase Console

3. **Jalankan aplikasi**
   ```bash
   flutter run
   ```

## Library yang Digunakan

- [firebase_core](https://pub.dev/packages/firebase_core) - Integrasi Firebase
- [cloud_firestore](https://pub.dev/packages/cloud_firestore) - Database Cloud Firestore
- [firebase_auth](https://pub.dev/packages/firebase_auth) - Autentikasi pengguna
- [google_fonts](https://pub.dev/packages/google_fonts) - Font custom Google
- [intl](https://pub.dev/packages/intl) - Format currency & tanggal
- [cupertino_icons](https://pub.dev/packages/cupertino_icons) - Icon iOS
- [fl_chart](https://pub.dev/packages/fl_chart) - Grafik pie & line

## Struktur Folder

- `lib/screens/` - Halaman utama aplikasi (home, transaksi, laporan, profil, dll)
- `lib/models/` - Model data (contoh: Account)
- `ios/` dan `android/` - Konfigurasi platform
- `pubspec.yaml` - Daftar dependencies
  restore sesuai kebutuhan aplikasi.
