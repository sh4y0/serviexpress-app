class FCMMessage {
  final String token;
  final String idServicio;
  final String senderId;
  final String receiverId;
  final String? title;
  final String? body;

  FCMMessage({
    required this.token,
    required this.idServicio,
    required this.senderId,
    required this.receiverId,
    this.title,
    this.body,
  });

  FCMMessage copyWith({
    String? token,
    String? idServicio,
    String? senderId,
    String? receiverId,
    String? title,
    String? body,
  }) {
    return FCMMessage(
      token: token ?? this.token,
      idServicio: idServicio ?? this.idServicio,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      title: title ?? this.title,
      body: body ?? this.body,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': {
        'token': token,
        if (title != null || body != null)
          'notification': {
            if (title != null) 'title': title,
            if (body != null) 'body': body,
          },
        'data': {
          'idServicio': idServicio,
          'senderId': senderId,
          'receiverId': receiverId,
        },
      },
    };
  }
}
