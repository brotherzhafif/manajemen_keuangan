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
        appBar: AppBar(
          title: Text(
            'Profil',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
        ),
        body: Center(
          child: Text(
            'User belum login',
            style: GoogleFonts.poppins(color: Colors.black),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil', style: GoogleFonts.poppins(color: Colors.white)),
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
            return Center(
              child: Text(
                'Data user tidak ditemukan',
                style: GoogleFonts.poppins(color: Colors.black),
              ),
            );
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
                          (data['firstname'] ?? '-').toString().length > 15
                              ? (data['firstname'] ?? '-').toString().substring(
                                      0,
                                      15,
                                    ) +
                                    '...'
                              : (data['firstname'] ?? '-').toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          (data['email'] ?? '-').toString().length > 20
                              ? (data['email'] ?? '-').toString().substring(
                                      0,
                                      20,
                                    ) +
                                    '...'
                              : (data['email'] ?? '-').toString(),
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
                  'User',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  data['user'] ?? '-',
                  style: GoogleFonts.poppins(color: Colors.black54),
                ),
                SizedBox(height: 16),
                Text(
                  'ID User',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  data['id_user'] ?? '-',
                  style: GoogleFonts.poppins(color: Colors.black54),
                ),
                SizedBox(height: 16),
                Text(
                  'Username',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  data['username'] ?? '-',
                  style: GoogleFonts.poppins(color: Colors.black54),
                ),
                SizedBox(height: 16),
                Text(
                  'Email',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  data['email'] ?? '-',
                  style: GoogleFonts.poppins(color: Colors.black54),
                ),
                SizedBox(height: 16),
                Text(
                  'Password',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  data['password'] ?? '-',
                  style: GoogleFonts.poppins(color: Colors.black54),
                ),
                SizedBox(height: 16),
                Text(
                  'First Name',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  data['firstname'] ?? '-',
                  style: GoogleFonts.poppins(color: Colors.black54),
                ),
                SizedBox(height: 16),
                Text(
                  'Last Name',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  data['lastname'] ?? '-',
                  style: GoogleFonts.poppins(color: Colors.black54),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
