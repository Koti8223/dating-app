class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final String type; // text, gift
  final DateTime createdAt;
  final bool isRead;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'type': type,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] ?? '',
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      content: map['content'] ?? '',
      type: map['type'] ?? 'text',
      createdAt: DateTime.parse(map['createdAt']),
      isRead: map['isRead'] ?? false,
    );
  }
}
