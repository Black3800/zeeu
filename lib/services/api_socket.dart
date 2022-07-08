import 'dart:convert';

import 'package:ZeeU/models/chat.dart';
import 'package:ZeeU/utils/constants.dart';
import 'package:web_socket_channel/io.dart';

class ApiSocket {
  final channel = IOWebSocketChannel.connect(Uri.parse(Constants.apiUri));
  late String idToken;
  late Stream<Map> decoded;
  late ChatCollectionSocket chats;

  Stream<Map> get ping async* {
    await for (final ping in decoded) {
      if (ping['event'] == 'ping') yield ping;
    }
  }

  ApiSocket({ String? token }) {
    decoded = channel.stream.asBroadcastStream().map((message) => jsonDecode(message));
    chats = ChatCollectionSocket(decoded, emit);
    if (token != null && token.isNotEmpty) {
      verifyToken(token);
      decoded.listen((message) {
        if (message['event'] == 'verify-success') {
          chats.subscribe();
        }
      });
    }
  }

  verifyToken(String token) {
    emit('verify', {'token': token});
    idToken = token;
  }

  emit(String type, Map<String, Object> params) {
    channel.sink.add(jsonEncode({
      'type': type,
      'params': params
    }));
  }

  dispose() {
    channel.sink.close();
  }
}

class ChatCollectionSocket {
  final Stream<Map> _upstream;
  final Function(String, Map<String, Object>) _emit;

  ChatCollectionSocket(this._upstream, this._emit);

  Stream<List<Chat>> get stream async* {
    await for (final message in _upstream) {
      if (message['event'] == 'chats') {
        List<Chat> chats = (message['data'] as List)
            .map((c) => Chat.fromJson(c, id: c['id']))
            .toList();
        yield chats;
      }
    }
  }

  subscribe() {
    _emit('subscribe', {'collection': 'chats'});
  }
}