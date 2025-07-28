import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Profil', style: GoogleFonts.poppins())),
        body: Center(child: Text('User belum login')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil', style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFF47663C),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Data user tidak ditemukan'));
          }
          final data = snapshot.data!.data() as Map<String, dynamic>;
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: const Color(0xFF47663C),
                      child: Icon(Icons.person, color: Colors.white, size: 32),
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['firstname'] ?? '-',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          data['email'] ?? '-',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 32),
                Text(
                  'Username',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                Text(data['username'] ?? '-', style: GoogleFonts.poppins()),
                SizedBox(height: 16),
                Text(
                  'Email',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                Text(data['email'] ?? '-', style: GoogleFonts.poppins()),
                SizedBox(height: 16),
                Text(
                  'Nama Lengkap',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                Text(data['firstname'] ?? '-', style: GoogleFonts.poppins()),
                SizedBox(height: 16),
                Text(
                  'User ID',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                Text(data['id_user'] ?? '-', style: GoogleFonts.poppins()),
              ],
            ),
          );
        },
      ),
    );
  }
}
