import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants/colors.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  // Variabel untuk menyimpan nama dan email
  String? name;
  String? email;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  // Fungsi untuk mengambil data pengguna dari Firestore
  Future<void> _getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final DocumentSnapshot<Map<String, dynamic>> userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      setState(() {
        name = userDoc.data()?['name'] ?? 'User'; // Nama dari Firestore
        email = user.email; // Email dari FirebaseAuth
      });
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(name ?? 'User'),
            accountEmail: Text(email ?? 'Email'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage:
                  user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
              child: user?.photoURL == null
                  ? Text(
                      name != null && name!.isNotEmpty
                          ? name![0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                          fontSize: 40.0, color: AppColors.primary),
                    )
                  : null,
            ),
            decoration: const BoxDecoration(color: AppColors.primary),
          ),
          ListTile(
            leading: const Icon(Icons.vpn_key, color: AppColors.black),
            title: const Text('Ubah Password'),
            onTap: () => Navigator.of(context).pushNamed('/change-password'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.black),
            title: const Text('Logout'),
            onTap: _logout,
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }
}
