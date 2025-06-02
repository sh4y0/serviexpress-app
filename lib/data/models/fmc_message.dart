import 'package:firebase_messaging/firebase_messaging.dart';

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

  factory FCMMessage.fromRemoteMessage(RemoteMessage message) {
    final data = message.data;
    return FCMMessage(
      token: '',
      idServicio: data['idServicio'] ?? '',
      senderId: data['senderId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      title: data['title'],
      body: data['body'],
    );
  }

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
    final data = {
      'idServicio': idServicio,
      'senderId': senderId,
      'receiverId': receiverId,
      if (title != null) 'title': title!,
      if (body != null) 'body': body!,
    };

    final message = {'token': token, 'data': data};

    if (title != null || body != null) {
      message['notification'] = {
        if (title != null) 'title': title!,
        if (body != null) 'body': body!,
      };
      message['android'] = {
        'notification': {'channel_id': 'default_channel'},
      };
    }

    return {'message': message};
  }
}
