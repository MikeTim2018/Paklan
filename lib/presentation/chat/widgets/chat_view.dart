import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paklan/common/helper/messages/read_status.dart';
import 'package:paklan/domain/common/usecases/mark_chat_read.dart';
import 'package:rxdart/rxdart.dart';

// Domain imports
import 'package:paklan/domain/common/usecases/get_messages.dart';
import 'package:paklan/domain/common/usecases/get_chat.dart';

// Service locator
import 'package:paklan/service_locator.dart';

/// Combined data from chat and messages streams
class ChatMessagesData {
  final Map<String, dynamic> lastReadTime;
  final List<String> members;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> messages;

  ChatMessagesData({
    required this.lastReadTime,
    required this.members,
    required this.messages,
  });
}

/// WhatsApp-style chat messages view with read receipts
/// Follows clean architecture with service locator pattern
class ChatMessagesWidgetWithReadReceipts extends StatefulWidget {
  final String chatId;
  final String currentUserId;

  const ChatMessagesWidgetWithReadReceipts({
    Key? key,
    required this.chatId,
    required this.currentUserId,
  }) : super(key: key);

  @override
  State<ChatMessagesWidgetWithReadReceipts> createState() =>
      _ChatMessagesWidgetWithReadReceiptsState();
}

class _ChatMessagesWidgetWithReadReceiptsState
    extends State<ChatMessagesWidgetWithReadReceipts>
    with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();

  // Streams initialized once in initState
  late final Stream<DocumentSnapshot<Map<String, dynamic>>> _chatStream;
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _messagesStream;
  late final Stream<ChatMessagesData> _combinedStream;

  // Track the last message timestamp we marked as read
  DateTime? _lastMarkedReadTime;

  // Debounce timer to prevent excessive writes
  Timer? _markAsReadTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize streams once
    _chatStream = sl<GetChatUseCase>().call(params: widget.chatId);
    _messagesStream = sl<GetMessagesUseCase>().call(params: widget.chatId);

    // Combine both streams into a single stream
    _combinedStream = Rx.combineLatest2<
        DocumentSnapshot<Map<String, dynamic>>,
        QuerySnapshot<Map<String, dynamic>>,
        ChatMessagesData>(
      _chatStream,
      _messagesStream,
      (chatSnapshot, messagesSnapshot) {
        final chatData = chatSnapshot.data();
        return ChatMessagesData(
          lastReadTime: chatData?['lastReadTime'] as Map<String, dynamic>? ?? {},
          members: List<String>.from(chatData?['members'] ?? []),
          messages: messagesSnapshot.docs,
        );
      },
    );

    // Mark as read when opening (after first frame, only once)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _markChatAsReadDebounced();
      }
    });
  }

  @override
  void dispose() {
    _markAsReadTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      _markChatAsReadDebounced();
    }
  }

  /// Debounced mark as read - prevents excessive writes
  void _markChatAsReadDebounced() {
    _markAsReadTimer?.cancel();

    // Schedule new timer (2 seconds debounce)
    _markAsReadTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        _markChatAsRead();
      }
    });
  }

  /// Check if we need to mark as read based on last message time
  bool _shouldMarkAsRead(List<QueryDocumentSnapshot<Map<String, dynamic>>> messages) {
    if (messages.isEmpty) return false;

    // Get the latest message
    final latestMessageData = messages.last.data();
    final latestMessageSenderId = latestMessageData['senderId'] ?? '';

    // ✅ DON'T mark as read if the latest message is from the current user
    // (We don't need to mark our own messages as "read")
    if (latestMessageSenderId == widget.currentUserId) {
      return false;
    }

    // Get the latest message time
    final latestMessageTime = ReadStatusHelper.parseTimestamp(
      latestMessageData['createdTime'],
    );

    if (latestMessageTime == null) return false;

    // Only mark as read if we haven't marked this message time yet
    if (_lastMarkedReadTime == null) {
      return true; // First time opening chat
    }

    // Mark as read if there are new messages since last marked time
    return latestMessageTime.isAfter(_lastMarkedReadTime!);
  }

  Future<void> _markChatAsRead() async {
    if (!mounted) return;

    try {
      await sl<MarkChatAsReadUseCase>().call(
        params: MarkChatAsReadParams(
          chatId: widget.chatId,
          userId: widget.currentUserId,
        ),
      );

      // Update the last marked time to prevent redundant writes
      _lastMarkedReadTime = DateTime.now();
    } catch (e) {
      debugPrint('Error marking chat as read: $e');
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ChatMessagesData>(
      stream: _combinedStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error al cargar mensajes',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data!.messages.isEmpty) {
          return Center(
            child: Text(
              'No hay mensajes aún.\n¡Sé el primero en escribir!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          );
        }

        final data = snapshot.data!;

        // Scroll to bottom and mark as read ONLY when there are new messages
        // Check BEFORE scheduling callback to prevent excessive writes
        final shouldMarkAsRead = _shouldMarkAsRead(data.messages);

        if (shouldMarkAsRead) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _scrollToBottom();
              _markChatAsReadDebounced(); // Uses debounce
            }
          });
        } else {
          // Just scroll, don't mark as read
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _scrollToBottom();
            }
          });
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemCount: data.messages.length,
          itemBuilder: (context, index) {
            final messageData = data.messages[index].data();
            final senderId = messageData['senderId'] ?? '';
            final isMe = senderId == widget.currentUserId;
            final createdTime = messageData['createdTime']; // Keep as dynamic (can be Timestamp or String)

            // Calculate read status using helper (now accepts dynamic)
            final readStatus = ReadStatusHelper.getMessageReadStatus(
              messageCreatedTime: createdTime,
              senderId: senderId,
              currentUserId: widget.currentUserId,
              lastReadTime: data.lastReadTime,
              members: data.members,
            );

            return MessageBubbleWithReadReceipt(
              text: messageData['message'] ?? '',
              isMe: isMe,
              createdTime: createdTime,
              senderName: messageData['senderName'] ?? 'Usuario',
              readStatus: readStatus,
            );
          },
        );
      },
    );
  }
}

class MessageBubbleWithReadReceipt extends StatelessWidget {
  final String text;
  final bool isMe;
  final dynamic createdTime; // Can be String, Timestamp, or null
  final String senderName;
  final MessageReadStatus readStatus;

  const MessageBubbleWithReadReceipt({
    Key? key,
    required this.text,
    required this.isMe,
    this.createdTime,
    this.senderName = '',
    this.readStatus = MessageReadStatus.none,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) const SizedBox(width: 4),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isMe
                    ? const Color(0xFFDCF8C6) // WhatsApp green for sent
                    : Colors.white, // White for received
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isMe
                      ? const Radius.circular(16)
                      : const Radius.circular(4),
                  bottomRight: isMe
                      ? const Radius.circular(4)
                      : const Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMe && senderName.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        senderName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Color(0xFF075E54),
                        ),
                      ),
                    ),
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                  // Time and read status row
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (createdTime != null)
                          Text(
                            ReadStatusHelper.formatTime(createdTime),
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        if (isMe && readStatus != MessageReadStatus.none) ...[
                          const SizedBox(width: 4),
                          _buildReadIndicator(readStatus),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildReadIndicator(MessageReadStatus status) {
    switch (status) {
      case MessageReadStatus.sent:
        return Icon(
          Icons.check,
          size: 16,
          color: Colors.grey[600],
        );

      case MessageReadStatus.delivered:
        return Icon(
          Icons.done_all,
          size: 16,
          color: Colors.grey[600],
        );

      case MessageReadStatus.read:
        return const Icon(
          Icons.done_all,
          size: 16,
          color: Color(0xFF4FC3F7), // Blue for read
        );

      case MessageReadStatus.none:
        return const SizedBox.shrink();
    }
  }
}
