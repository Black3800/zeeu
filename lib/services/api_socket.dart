import 'dart:async';
import 'dart:convert';

import 'package:ZeeU/models/app_user.dart';
import 'package:ZeeU/models/appointment.dart';
import 'package:ZeeU/models/chat.dart';
import 'package:ZeeU/models/message.dart';
import 'package:ZeeU/utils/constants.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/io.dart';

class ApiSocket {
  final channel = IOWebSocketChannel.connect(Uri.parse(Constants.apiUri));
  late String idToken;
  late Stream<Map> decoded;
  late ChatCollectionSocket chats;
  late AppointmentCollectionSocket appointments;
  late UserCollectionSocket users;
  late PostInterface post;
  bool subscribed = false;
  bool ensured = false;

  Stream<Map> get ping async* {
    await for (final ping in decoded) {
      if (ping['event'] == 'ping') yield ping;
    }
  }

  ApiSocket({ String? token }) {
    decoded = channel.stream.asBroadcastStream().map((message) => jsonDecode(message));
    chats = ChatCollectionSocket(decoded, emit);
    appointments = AppointmentCollectionSocket(decoded, emit);
    users = UserCollectionSocket(decoded, emit);
    post = PostInterface(decoded, emit);
    if (token != null && token.isNotEmpty) {
      verifyTokenAndSubscribe(token);
    }
  }

  Future<bool> verifyTokenAndSubscribe(String token) async {
    await verifyTokenOnly(token);
    subscribeOnly();
    return true;
  }

  Future<bool> verifyTokenOnly(String token) async {
    print('verifying $token');
    emit('verify', {'token': token});
    idToken = token;
    await for (final message in decoded) {
      if (message['event'] == 'verify-success') break;
    }
    return true;
  }

  subscribeOnly() {
    chats.subscribe();
    appointments.subscribe();
    subscribed = true;
  }

  ensureSubscribed() async {
    if (!subscribed && !ensured) {
      ensured = true;
      await fetchUser();
      subscribeOnly();
    }
  }

  Future<bool> fetchUser() async {
    emit('fetch', null);
    await for (final message in decoded) {
      if (message['event'] == 'fetch-success') break;
    }
    return true;
  }

  logout() {
    emit('logout', null);
    subscribed = false;
    ensured = false;
  }

  emit(String type, Map<String, Object>? params) {
    channel.sink.add(jsonEncode({
      'type': type,
      'params': params
    }));
  }

  dispose() {
    channel.sink.close();
  }
}

abstract class CollectionSocket {
  final Stream<Map> _upstream;
  final Function(String, Map<String, Object>) _emit;

  CollectionSocket(this._upstream, this._emit);
}

class AppointmentCollectionSocket extends CollectionSocket {
  List<Appointment>? _latest;

  AppointmentCollectionSocket(_upstream, _emit) : super(_upstream, _emit);

  Stream<List<Appointment>> get stream async* {
    if (_latest != null) {
      yield _latest!;
    }
    await for (final message in _upstream) {
      if (message['event'] == 'appointments') {
        List<Appointment> appointments = _toAppointmentList(message['data']);
        yield appointments;
        _latest = appointments;
      }
    }
  }

  Future<List<Appointment>> get once async {
    if (_latest != null) return Future.value(_latest);

    _emit('get', {'collection': 'appointments', 'ref': 'appointments'});
    final message = await _upstream.firstWhere((message) =>
        message['event'] == 'get-success' &&
        message['data']['ref'] == 'appointments');
    return _toAppointmentList(message['data']['content']);
  }

  subscribe() {
    _emit('subscribe', {'collection': 'appointments', 'ref': 'appointments'});
  }

  Future<Appointment> withId(id) async {
    final list = await once;
    return list.firstWhere((appointment) => appointment.id == id);
  }

  _toAppointmentList(list) {
    return (list as List)
            .map((a) => Appointment.fromJson(a))
            .toList();
  }
}

class ChatCollectionSocket extends CollectionSocket {
  ChatCollectionSocket(_upstream, _emit) : super(_upstream, _emit);

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

  MessageCollectionSocket withId(id) {
    return MessageCollectionSocket(id, _upstream, _emit);
  }

  Future<String> withDoctor(doctor) async {
    final ref = const Uuid().v4();
    _emit('get', {'collection': 'chatId', 'ref': ref, 'doctor': doctor});
    final message = await _upstream.firstWhere((message) =>
        message['event'] == 'get-success' && message['data']['ref'] == ref);
    return message['data']['content'];
  }

  subscribe() {
    _emit('subscribe', {'collection': 'chats', 'ref': 'chats'});
  }
}

class MessageCollectionSocket extends CollectionSocket {
  final String _id;
  String? _sid;

  MessageCollectionSocket(id, _upstream, _emit) : _id = id, super(_upstream, _emit);

  Stream<List<Message>> get stream async* {
    await for (final message in _upstream) {
      if (message['event'] == 'messages' && message['data']['id'] == _id) {
        List<Message> messages = _toMessageList(message['data']['content']);
        yield messages;
      }
    }
  }

  subscribe() {
    if (_sid == null) {
      _emit('subscribe', {'collection': 'messages', 'ref': 'messages $_id', 'id': _id});
      late StreamSubscription setSidSubscription;
      setSidSubscription = _upstream.listen((message) {
        if (message['event'] == 'subscribe-success' &&
            message['data']['ref'] == 'messages $_id') {
          _sid = message['data']['sid'];
          setSidSubscription.cancel();
        }
      });
    }
  }

  unsubsribe() {
    if (_sid != null) {
      _emit('unsubscribe', {'sid': _sid!});
    }
  }

  _toMessageList(list) {
    return (list as List)
            .map((a) => Message.fromJson(a))
            .toList();
  }
}

class UserDocumentSocket extends CollectionSocket {
  final String _uid;
  String? _sid;

  UserDocumentSocket(uid, _upstream, _emit) : _uid = uid, super(_upstream, _emit);

  Stream<AppUser> get stream async* {
    await for (final message in _upstream) {
      if (message['event'] == 'user' && message['data']['uid'] == _uid) {
        yield AppUser.fromJson(message['data'], uid: message['data']['uid']);
      }
    }
  }
  
  Future<AppUser> get once async {
    final ref = const Uuid().v4();
    _emit('get', {'collection': 'user', 'ref': ref, 'uid': _uid});
    final message = await _upstream.firstWhere((message) =>
        message['event'] == 'get-success' && message['data']['ref'] == ref);
    return AppUser.fromJson(message['data']['content']);
  }

  subscribe() {
    if (_sid == null) {
      _emit('subscribe', {'collection': 'user', 'ref': 'user $_uid', 'uid': _uid});
      late StreamSubscription setSidSubscription;
      setSidSubscription = _upstream.listen((message) {
        if (message['event'] == 'subscribe-success' && message['data']['ref'] == 'user $_uid') {
          _sid = message['data']['sid'];
          setSidSubscription.cancel();
        }
      });
    }
  }

  unsubsribe() {
    if (_sid != null) {
      _emit('unsubscribe', {'sid': _sid!});
    }
  }
}

class DoctorCollectionSocket extends CollectionSocket {
  DoctorCollectionSocket(_upstream, _emit) : super(_upstream, _emit);

  Future<List<AppUser>> withSpecialty(String specialty) async {
    _emit('get', {
      'collection': 'doctors',
      'ref': 'doctors',
      'specialty': specialty
    });
    final message = await _upstream.firstWhere((message) =>
        message['event'] == 'get-success' &&
        message['data']['ref'] == 'doctors');
    return _toAppUserList(message['data']['content']);
  }

  _toAppUserList(list) {
    return (list as List).map((a) => AppUser.fromJson(a, uid: a['uid'])).toList();
  }
}

class UserCollectionSocket extends CollectionSocket {
  late DoctorCollectionSocket doctors;

  UserCollectionSocket(_upstream, _emit)
      : doctors = DoctorCollectionSocket(_upstream, _emit),
        super(_upstream, _emit);

  UserDocumentSocket withUid(uid) {
    return UserDocumentSocket(uid, _upstream, _emit);
  }
}

class PostInterface extends CollectionSocket {
  PostInterface(_upstream, _emit) : super(_upstream, _emit);

  Future<bool> user(uid, user) async {
    _emit('post', {
        'collection': 'user',
        'uid': uid,
        'ref': 'post user $uid',
        'user': user
    });

    await _upstream.firstWhere((message) =>
        message['event'] == 'post-success' &&
        message['data']['ref'] == 'post user $uid');
    return true;
  }

  Future<bool> message(chatId, type, content) async {
    _emit('post', {
      'collection': 'message',
      'chatId': chatId,
      'ref': 'post message $chatId',
      'type': type,
      'content': content
    });

    await _upstream.firstWhere((message) =>
        message['event'] == 'post-success' &&
        message['data']['ref'] == 'post message $chatId');
    return true;
  }

  seenLatestMessage(chatId) {
    _emit('post', {
      'collection': 'seen',
      'chatId': chatId,
      'ref': 'seen $chatId'
    });
  }

  Future<bool> appointment(chatId, DateTime start, DateTime end) async {
    _emit('post', {
      'collection': 'appointment',
      'chatId': chatId,
      'ref': 'post appointment $chatId',
      'start': start.toIso8601String(),
      'end': end.toIso8601String()
    });

    await _upstream.firstWhere((message) =>
        message['event'] == 'post-success' &&
        message['data']['ref'] == 'post appointment $chatId');
    return true;
  }
}