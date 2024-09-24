import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Tambahkan ini
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
              onPressed: () {},
              icon: Icon(
                Icons.help_outline,
                color: AppColors.white,
              ))
        ],
        leading: Builder(builder: (context) {
          return IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const Icon(
              Icons.account_circle_rounded, // Changed icon to model_training
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
              accountName: Text(user?.displayName ?? 'User'),
              accountEmail: Text(user?.email ?? 'Email'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : null, // Jika tidak ada foto, tetap menggunakan teks
                child: user?.photoURL == null
                    ? Text(
                        user?.displayName?.substring(0, 1) ?? 'U',
                        style:
                            TextStyle(fontSize: 40.0, color: AppColors.primary),
                      )
                    : null, // Tidak ada teks jika ada gambar
              ),
              decoration: BoxDecoration(color: AppColors.primary),
            ),
            ListTile(
              leading: Icon(
                Icons.logout,
                color: AppColors.black,
              ),
              title: Text('Logout'),
              onTap: _logout,
            ),
            Divider(
              height: 2,
            )
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
