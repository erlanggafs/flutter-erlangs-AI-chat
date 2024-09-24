import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'pages/widgets/chat_bubble.dart';
import 'constants/colors.dart';

const apiKey = 'AIzaSyACec0La78HL4CVV-IK4d0Cq8FS6W0CvMs';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
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
    return Scaffold(
      appBar: AppBar(
        leading: Icon(
          Icons.model_training,
          color: AppColors.white,
        ),
        title: const Text('Erlangs AI', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
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
                            borderRadius: BorderRadius.all(
                                Radius.circular(15.0)), // Radius untuk border
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(15.0)), // Radius saat fokus
                            borderSide: BorderSide(
                                color: AppColors.primary, width: 2.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(15.0)), // Radius saat enabled
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
                  color:
                      AppColors.white.withOpacity(0.5), // Warna latar belakang
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.5),
                      offset: const Offset(0, 1), // Posisi bayangan
                    ),
                  ], // Radius sudut
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
