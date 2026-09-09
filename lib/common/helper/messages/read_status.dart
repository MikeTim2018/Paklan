enum MessageReadStatus {
  none,      // Not my message (don't show status)
  sent,      // Just sent
  delivered, // Delivered to other user
  read,      // Other user has read it
}

class ReadStatusHelper {
  /// Calculate the read status for a message
  /// [messageCreatedTime] can be String, Firestore Timestamp, DateTime, or int
  static MessageReadStatus getMessageReadStatus({
    required dynamic messageCreatedTime,
    required String senderId,
    required String currentUserId,
    required Map<String, dynamic> lastReadTime,
    required List<String> members,
  }) {
    // Only show read status for current user's messages
    if (senderId != currentUserId) {
      return MessageReadStatus.none;
    }

    // Parse message created time
    final messageTime = parseTimestamp(messageCreatedTime);
    if (messageTime == null) {
      return MessageReadStatus.sent;
    }

    // Get the other user's last read time (for 1-on-1 chat)
    final otherUserId = members.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );

    if (otherUserId.isEmpty) {
      return MessageReadStatus.sent;
    }

    final otherUserReadTime = lastReadTime[otherUserId];

    if (otherUserReadTime == null) {
      return MessageReadStatus.delivered;
    }

    try {
      // Parse read time
      final readTime = parseTimestamp(otherUserReadTime);
      if (readTime == null) {
        return MessageReadStatus.delivered;
      }

      // Compare timestamps with some tolerance for millisecond differences
      // A message is "read" if the other user opened the chat AFTER the message was sent
      final difference = readTime.difference(messageTime);

      if (difference.inMilliseconds >= 0) {
        // Read time is equal or after message time = READ
        return MessageReadStatus.read;
      } else if (difference.inMilliseconds > -1000) {
        // Within 1 second tolerance (clock skew) = READ
        return MessageReadStatus.read;
      } else {
        // Read time is before message time = DELIVERED (not read yet)
        return MessageReadStatus.delivered;
      }
    } catch (e) {
      print('Error calculating read status: $e');
      return MessageReadStatus.sent;
    }
  }

  /// Parse timestamp - handles both String and Firestore Timestamp
  /// Public method for use in widgets
  static DateTime? parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return null;

    try {
      // If it's already a DateTime
      if (timestamp is DateTime) {
        return timestamp;
      }

      // If it's a Firestore Timestamp
      if (timestamp.runtimeType.toString() == 'Timestamp') {
        // Use reflection-free approach
        final timestampMap = timestamp as dynamic;
        return timestampMap.toDate() as DateTime;
      }

      // If it's a String
      if (timestamp is String) {
        if (timestamp.isEmpty) return null;
        return DateTime.parse(timestamp);
      }

      // If it's an int (milliseconds since epoch)
      if (timestamp is int) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      }

      return null;
    } catch (e) {
      print('Error parsing timestamp: $e');
      return null;
    }
  }

  /// Format timestamp to HH:MM
  static String formatTime(dynamic createdTime) {
    try {
      final dateTime = parseTimestamp(createdTime);
      if (dateTime == null) {
        return createdTime.toString();
      }

      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } catch (e) {
      return createdTime.toString();
    }
  }
}
