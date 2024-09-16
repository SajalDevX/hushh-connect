class Message {
  final String id;
  final String content;
  final List<String>? imageUrls;
  final bool markAsRead;
  final String userTo;
  final String userFrom;
  final String chatId;
  final DateTime createAt;
  final bool isMine;

  Message(
      {required this.id,
      required this.content,
      this.imageUrls,
      required this.markAsRead,
      required this.userFrom,
      required this.userTo,
      required this.createAt,
      required this.chatId,
      required this.isMine});

  Message.create(
      {required this.content,
      this.imageUrls,
      required this.userFrom,
      required this.userTo,
      required this.chatId})
      : id = '',
        markAsRead = false,
        isMine = true,
        createAt = DateTime.now();

  Message.fromJson(Map<String, dynamic> json, String userId)
      : id = json['id'],
        content = json['content'],
        imageUrls = (json['image_urls'] != null)
            ? List<String>.from(json['image_urls'])
            : null,
        markAsRead = json['mark_as_read'],
        userFrom = json['user_from'],
        chatId = json['chat_id'],
        userTo = json['user_to'],
        createAt = DateTime.parse(json['created_at']),
        isMine = json['user_from'] == userId;

  Map toMap() {
    return {
      'content': content,
      'image_urls': imageUrls,
      'user_from': userFrom,
      'user_to': userTo,
      'chat_id': chatId,
      'mark_as_read': markAsRead,
    };
  }
}
