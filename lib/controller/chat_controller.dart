import '../model/chat_model.dart';
import '../model/userModel.dart';
import '../services/database_helper.dart';
import '../controller/user_controller.dart';

class ChatController {
  final dbHelper = DatabaseHelper.instance;
  final userController = UserController();

  // Get or create chat room between two users
  Future<ChatRoomModel?> getOrCreateChatRoom(int user1Id, int user2Id) async {
    try {
      final db = await dbHelper.database;

      // Ensure user1Id is always smaller for consistency
      final smallerId = user1Id < user2Id ? user1Id : user2Id;
      final biggerId = user1Id < user2Id ? user2Id : user1Id;

      // Check if chat room exists
      final List<Map<String, dynamic>> existing = await db.query(
        'chat_rooms',
        where: '(user1_id = ? AND user2_id = ?) OR (user1_id = ? AND user2_id = ?)',
        whereArgs: [smallerId, biggerId, biggerId, smallerId],
        limit: 1,
      );

      if (existing.isNotEmpty) {
        return ChatRoomModel.fromMap(existing.first);
      }

      // Create new chat room
      final chatRoom = ChatRoomModel(
        user1Id: smallerId,
        user2Id: biggerId,
        createdAt: DateTime.now().toIso8601String(),
      );

      final id = await db.insert('chat_rooms', chatRoom.toMap());
      chatRoom.id = id;

      return chatRoom;
    } catch (e) {
      print('Error getOrCreateChatRoom: $e');
      return null;
    }
  }

  // Send message
  Future<bool> sendMessage({
    required int chatRoomId,
    required int senderId,
    required int receiverId,
    required String message,
  }) async {
    try {
      final db = await dbHelper.database;

      // Insert message
      final messageModel = MessageModel(
        chatRoomId: chatRoomId,
        senderId: senderId,
        receiverId: receiverId,
        message: message,
        isRead: false,
        createdAt: DateTime.now().toIso8601String(),
      );

      await db.insert('messages', messageModel.toMap());

      // Update chat room
      await _updateChatRoom(chatRoomId, message, senderId, receiverId);

      return true;
    } catch (e) {
      print('Error sendMessage: $e');
      return false;
    }
  }

  // Update chat room after new message
  Future<void> _updateChatRoom(
    int chatRoomId,
    String lastMessage,
    int senderId,
    int receiverId,
  ) async {
    try {
      final db = await dbHelper.database;

      // Get chat room to determine which user
      final chatRooms = await db.query(
        'chat_rooms',
        where: 'id = ?',
        whereArgs: [chatRoomId],
        limit: 1,
      );

      if (chatRooms.isEmpty) return;

      final chatRoom = ChatRoomModel.fromMap(chatRooms.first);

      // Increment unread count for receiver
      Map<String, dynamic> updateData = {
        'last_message': lastMessage,
        'last_message_time': DateTime.now().toIso8601String(),
      };

      if (receiverId == chatRoom.user1Id) {
        updateData['unread_count_user1'] = (chatRoom.unreadCountUser1 ?? 0) + 1;
      } else {
        updateData['unread_count_user2'] = (chatRoom.unreadCountUser2 ?? 0) + 1;
      }

      await db.update(
        'chat_rooms',
        updateData,
        where: 'id = ?',
        whereArgs: [chatRoomId],
      );
    } catch (e) {
      print('Error _updateChatRoom: $e');
    }
  }

  // Get all chat rooms for a user
  Future<List<ChatRoomModel>> getUserChatRooms(int userId) async {
    try {
      final db = await dbHelper.database;

      final List<Map<String, dynamic>> maps = await db.query(
        'chat_rooms',
        where: 'user1_id = ? OR user2_id = ?',
        whereArgs: [userId, userId],
        orderBy: 'last_message_time DESC',
      );

      List<ChatRoomModel> chatRooms = [];

      for (var map in maps) {
        ChatRoomModel chatRoom = ChatRoomModel.fromMap(map);

        // Get other user info
        final otherUserId = chatRoom.getOtherUserId(userId);
        if (otherUserId != null) {
          final otherUser = await userController.getUserById(otherUserId);
          chatRoom.otherUserName = otherUser?.uName;
          chatRoom.otherUserPhoto = otherUser?.uFotoProfil;
          chatRoom.otherUserId = otherUserId;
        }

        chatRooms.add(chatRoom);
      }

      return chatRooms;
    } catch (e) {
      print('Error getUserChatRooms: $e');
      return [];
    }
  }

  // Get messages in a chat room
  Future<List<MessageModel>> getChatMessages(int chatRoomId) async {
    try {
      final db = await dbHelper.database;

      final List<Map<String, dynamic>> maps = await db.query(
        'messages',
        where: 'chat_room_id = ?',
        whereArgs: [chatRoomId],
        orderBy: 'created_at ASC',
      );

      List<MessageModel> messages = [];

      for (var map in maps) {
        MessageModel message = MessageModel.fromMap(map);

        // Get sender info
        final sender = await userController.getUserById(message.senderId!);
        message.senderName = sender?.uName;
        message.senderPhoto = sender?.uFotoProfil;

        messages.add(message);
      }

      return messages;
    } catch (e) {
      print('Error getChatMessages: $e');
      return [];
    }
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(int chatRoomId, int userId) async {
    try {
      final db = await dbHelper.database;

      // Mark messages as read
      await db.update(
        'messages',
        {'is_read': 1},
        where: 'chat_room_id = ? AND receiver_id = ? AND is_read = 0',
        whereArgs: [chatRoomId, userId],
      );

      // Reset unread count in chat room
      final chatRooms = await db.query(
        'chat_rooms',
        where: 'id = ?',
        whereArgs: [chatRoomId],
        limit: 1,
      );

      if (chatRooms.isEmpty) return;

      final chatRoom = ChatRoomModel.fromMap(chatRooms.first);

      if (userId == chatRoom.user1Id) {
        await db.update(
          'chat_rooms',
          {'unread_count_user1': 0},
          where: 'id = ?',
          whereArgs: [chatRoomId],
        );
      } else {
        await db.update(
          'chat_rooms',
          {'unread_count_user2': 0},
          where: 'id = ?',
          whereArgs: [chatRoomId],
        );
      }
    } catch (e) {
      print('Error markMessagesAsRead: $e');
    }
  }

  // Get total unread count for user
  Future<int> getTotalUnreadCount(int userId) async {
    try {
      final db = await dbHelper.database;

      final result = await db.rawQuery(
        '''
        SELECT 
          SUM(CASE WHEN user1_id = ? THEN unread_count_user1 ELSE 0 END) +
          SUM(CASE WHEN user2_id = ? THEN unread_count_user2 ELSE 0 END) as total
        FROM chat_rooms
        WHERE user1_id = ? OR user2_id = ?
        ''',
        [userId, userId, userId, userId],
      );

      return (result.first['total'] as int?) ?? 0;
    } catch (e) {
      print('Error getTotalUnreadCount: $e');
      return 0;
    }
  }

  // Delete chat room
  Future<bool> deleteChatRoom(int chatRoomId) async {
    try {
      final db = await dbHelper.database;

      // Messages will be deleted automatically due to ON DELETE CASCADE
      await db.delete(
        'chat_rooms',
        where: 'id = ?',
        whereArgs: [chatRoomId],
      );

      return true;
    } catch (e) {
      print('Error deleteChatRoom: $e');
      return false;
    }
  }
}