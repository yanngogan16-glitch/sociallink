import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../models/message_model.dart';
import '../../services/chat_service.dart';
import '../../theme/app_theme.dart';
import 'chat_screen.dart';
import 'users_list_screen.dart';

class ChatsListScreen extends StatelessWidget {
  const ChatsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final myUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final service = ChatService();

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text("MESSAGERIE"),
        backgroundColor: AppTheme.bgDark,
        foregroundColor: AppTheme.gold,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppTheme.gold),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UsersListScreen()),
            ),
            tooltip: "Nouvelle conversation",
          ),
        ],
      ),
      body: StreamBuilder<List<ChatModel>>(
        stream: service.getMyChats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.gold),
            );
          }

          final chats = snapshot.data ?? [];

          if (chats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ShaderMask(
                    shaderCallback: (b) =>
                        AppTheme.goldGradient.createShader(b),
                    child: const Text("", style: TextStyle(fontSize: 56)),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Aucune conversation",
                    style: TextStyle(fontSize: 16, color: AppTheme.textLight),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Contactez une ONG ou une personne\nressource pour commencer",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: AppTheme.textLight),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: chats.length,
            itemBuilder: (_, i) {
              final chat = chats[i];
              final unread = chat.unreadFor(myUid);
              final otherName = chat.otherParticipantName(myUid);
              final otherId = chat.participants.firstWhere(
                (id) => id != myUid,
                orElse: () => '',
              );

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        chatId: chat.id,
                        otherUid: otherId,
                        otherName: otherName,
                      ),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.bgCard,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: unread > 0
                            ? AppTheme.gold.withValues(alpha: 0.5)
                            : AppTheme.gold.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Avatar
                        Stack(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                gradient: AppTheme.goldGradient,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  otherName.isNotEmpty
                                      ? otherName[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.bgDark,
                                  ),
                                ),
                              ),
                            ),
                            // ✅ Point rouge non lus
                            if (unread > 0)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      unread > 9 ? '9+' : '$unread',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    otherName,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: unread > 0
                                          ? FontWeight.bold
                                          : FontWeight.w600,
                                      color: AppTheme.textWhite,
                                    ),
                                  ),
                                  if (chat.lastMessageTime != null)
                                    Text(
                                      DateFormat(
                                        'HH:mm',
                                      ).format(chat.lastMessageTime!),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: unread > 0
                                            ? AppTheme.gold
                                            : AppTheme.textLight,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              _LastMessagePreview(
                                service: service,
                                chat: chat,
                                unread: unread,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _LastMessagePreview extends StatelessWidget {
  final ChatService service;
  final ChatModel chat;
  final int unread;

  const _LastMessagePreview({
    required this.service,
    required this.chat,
    required this.unread,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MessageModel?>(
      stream: service.getLatestMessage(chat.id),
      builder: (context, snapshot) {
        final latest = snapshot.data;
        final text = latest?.content.trim().isNotEmpty == true
            ? latest!.content
            : chat.lastMessage.trim().isNotEmpty
                ? chat.lastMessage
                : "Aucun message pour le moment";

        return Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: unread > 0 ? AppTheme.textWhite : AppTheme.textLight,
            fontWeight: unread > 0 ? FontWeight.w500 : FontWeight.normal,
            fontStyle: text == "Aucun message pour le moment"
                ? FontStyle.italic
                : FontStyle.normal,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }
}
