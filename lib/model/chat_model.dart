class ChatRoomModel {
  int? id;
  int? user1Id;
  int? user2Id;
  String? lastMessage;
  String? lastMessageTime;
  int? unreadCountUser1;
  int? unreadCountUser2;
  String? createdAt;

  // Helper fields (not in database)
  String? otherUserName;
  String? otherUserPhoto;
  int? otherUserId;

  ChatRoomModel({
    this.id,
    this.user1Id,
    this.user2Id,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCountUser1 = 0,
    this.unreadCountUser2 = 0,
    this.createdAt,
    this.otherUserName,
    this.otherUserPhoto,
    this.otherUserId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user1_id': user1Id,
      'user2_id': user2Id,
      'last_message': lastMessage,
      'last_message_time': lastMessageTime,
      'unread_count_user1': unreadCountUser1,
      'unread_count_user2': unreadCountUser2,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
    };
  }

  factory ChatRoomModel.fromMap(Map<String, dynamic> map) {
    return ChatRoomModel(
      id: map['id'] as int?,
      user1Id: map['user1_id'] as int?,
      user2Id: map['user2_id'] as int?,
      lastMessage: map['last_message'] as String?,
      lastMessageTime: map['last_message_time'] as String?,
      unreadCountUser1: map['unread_count_user1'] as int? ?? 0,
      unreadCountUser2: map['unread_count_user2'] as int? ?? 0,
      createdAt: map['created_at'] as String?,
    );
  }

  // Get unread count for specific user
  int getUnreadCount(int currentUserId) {
    if (currentUserId == user1Id) {
      return unreadCountUser1 ?? 0;
    } else {
      return unreadCountUser2 ?? 0;
    }
  }

  // Get other user ID
  int? getOtherUserId(int currentUserId) {
    if (currentUserId == user1Id) {
      return user2Id;
    } else {
      return user1Id;
    }
  }
}

class MessageModel {
  int? id;
  int? chatRoomId;
  int? senderId;
  int? receiverId;
  String? message;
  bool? isRead;
  String? createdAt;

  // Helper fields
  String? senderName;
  String? senderPhoto;

  MessageModel({
    this.id,
    this.chatRoomId,
    this.senderId,
    this.receiverId,
    this.message,
    this.isRead = false,
    this.createdAt,
    this.senderName,
    this.senderPhoto,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chat_room_id': chatRoomId,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'message': message,
      'is_read': isRead == true ? 1 : 0,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] as int?,
      chatRoomId: map['chat_room_id'] as int?,
      senderId: map['sender_id'] as int?,
      receiverId: map['receiver_id'] as int?,
      message: map['message'] as String?,
      isRead: map['is_read'] == 1,
      createdAt: map['created_at'] as String?,
    );
  }

  // Helper untuk parse DateTime
  DateTime? get createdAtDateTime {
    if (createdAt == null) return null;
    try {
      return DateTime.parse(createdAt!);
    } catch (e) {
      return null;
    }
  }

  bool isMine(int currentUserId) {
    return senderId == currentUserId;
  }
}