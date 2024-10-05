import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pages/widgets/chat_bubble.dart';
import 'constants/colors.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // Mengambil API key dari variabel lingkungan
  final model =
      GenerativeModel(model: 'gemini-pro', apiKey: dotenv.env['API_KEY']!);
  TextEditingController messageController = TextEditingController();
  bool isLoading = false;

  List<ChatBubble> chatBubbles = [
    const ChatBubble(
      direction: Direction.left,
      message: 'Halo, saya ERLANGS AI. Ada yang bisa saya bantu?',
      photoUrl: 'https://i.pravatar.cc/150?img=2',
      type: BubbleType.alone,
    ),
  ];

  // Variabel untuk menyimpan nama dan email
  String? name;
  String? email;

  @override
  void initState() {
    super.initState();
    _getUserData(); // Ambil data pengguna saat inisialisasi
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
        name =
            userDoc.data()?['name'] ?? 'User'; // Mengambil nama dari Firestore
        email = user.email; // Mengambil email dari FirebaseAuth
      });
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  void _refreshChat() {
    setState(() {
      chatBubbles.clear();
      chatBubbles.add(const ChatBubble(
        direction: Direction.left,
        message: 'Halo, saya ERLANGS AI. Ada yang bisa saya bantu?',
        photoUrl: 'https://i.pravatar.cc/150?img=2',
        type: BubbleType.alone,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Erlangs AI', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Bantuan'),
                    content: const Text(
                      'Anda sedang berada di halaman chat Erlangs AI. Berikut beberapa hal yang bisa Anda lakukan:\n\n'
                      '- Ketik pertanyaan di kolom pesan di bawah.\n'
                      '- Klik ikon kirim untuk mengirim pesan.\n'
                      '- Anda bisa bertanya apa saja, mulai dari informasi umum hingga pertanyaan teknis.\n'
                      '- Gunakan tombol refresh di atas untuk memulai sesi chat baru.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Tutup dialog
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );
            },
            icon: Icon(
              Icons.help_outline,
              color: AppColors.white,
            ),
          )
        ],
        leading: Builder(builder: (context) {
          return IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const Icon(
              Icons.account_circle_rounded,
              color: Colors.white,
              size: 35,
            ),
          );
        }),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName:
                  Text(name ?? 'User'), // Nama dari Firestore atau fallback
              accountEmail: Text(email ?? 'Email'), // Email dari FirebaseAuth
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!) // Foto profil
                    : null,
                child: user?.photoURL == null
                    ? Text(
                        name != null && name!.isNotEmpty
                            ? name![0].toUpperCase() // Inisial dari nama
                            : 'U', // Inisial default
                        style: const TextStyle(
                            fontSize: 40.0, color: AppColors.primary),
                      )
                    : null,
              ),
              decoration: const BoxDecoration(color: AppColors.primary),
            ),
            ListTile(
              leading: const Icon(
                Icons.lock_clock_outlined,
                color: AppColors.black,
              ),
              title: const Text('Ubah Password'),
              onTap: () => Navigator.of(context).pushNamed(
                  '/change-password'), // Navigasi ke halaman change_password_page.dart
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(
                Icons.logout,
                color: AppColors.black,
              ),
              title: const Text('Logout'),
              onTap: _logout,
            ),
            const Divider(height: 1),
          ],
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics()),
                  reverse: true,
                  padding: const EdgeInsets.all(10),
                  children: chatBubbles.reversed.toList(),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: messageController,
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(15.0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(15.0)),
                            borderSide: BorderSide(
                                color: AppColors.primary, width: 2.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(15.0)),
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1.0),
                          ),
                        ),
                      ),
                    ),
                    isLoading
                        ? const CircularProgressIndicator.adaptive()
                        : IconButton(
                            icon: const Icon(
                              Icons.send,
                              size: 35,
                            ),
                            onPressed: () async {
                              setState(() {
                                isLoading = true;
                              });
                              final content = [
                                Content.text(messageController.text)
                              ];
                              final GenerateContentResponse responseAI =
                                  await model.generateContent(content);

                              chatBubbles = [
                                ...chatBubbles,
                                ChatBubble(
                                  direction: Direction.right,
                                  message: messageController.text,
                                  photoUrl: null,
                                  type: BubbleType.alone,
                                ),
                                ChatBubble(
                                  direction: Direction.left,
                                  message: responseAI.text ??
                                      'Maaf, saya tidak mengerti',
                                  photoUrl: 'https://i.pravatar.cc/150?img=2',
                                  type: BubbleType.alone,
                                ),
                              ];

                              messageController.clear();
                              setState(() {
                                isLoading = false;
                              });
                            },
                          ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.5),
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.refresh,
                    color: AppColors.primary,
                  ),
                  onPressed: _refreshChat,
                  tooltip: 'Refresh Chat',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
