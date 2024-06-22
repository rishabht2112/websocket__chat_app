import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../models/message.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final WebSocketChannel channel;
  List<ChatMessage> messages = [];
  String currentUser;

  ChatBloc(this.channel, this.currentUser) : super(ChatInitial()) {
    _loadChatHistory(currentUser);

    channel.stream.listen((message) {
      add(ReceiveMessage(message));
    });

    on<SendMessage>(_onSendMessage);
    on<ReceiveMessage>(_onReceiveMessage);
    on<SwitchUser>(_onSwitchUser);
  }

  void _onSendMessage(SendMessage event, Emitter<ChatState> emit) {
    final chatMessage = ChatMessage(event.message, true);
    messages.add(chatMessage);
    _saveChatHistory();
    emit(ChatUpdated(currentUser, List.from(messages)));
    channel.sink.add(event.message);
  }

  void _onReceiveMessage(ReceiveMessage event, Emitter<ChatState> emit) {
    final chatMessage = ChatMessage(event.message, false);
    messages.add(chatMessage);
    _saveChatHistory();
    emit(ChatUpdated(currentUser, List.from(messages)));
  }

  void _onSwitchUser(SwitchUser event, Emitter<ChatState> emit) async {
    currentUser = event.username;
    await _loadChatHistory(currentUser);
    emit(ChatUpdated(currentUser, List.from(messages)));
  }

  Future<void> _saveChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('chat_history_$currentUser', jsonEncode(messages.map((msg) => {
      'message': msg.message,
      'isSentByMe': msg.isSentByMe,
    }).toList()));
  }

  Future<void> _loadChatHistory(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getString('chat_history_$username');
    if (history != null) {
      List<dynamic> decoded = jsonDecode(history);
      messages = decoded.map((item) => ChatMessage(item['message'], item['isSentByMe'])).toList();
    } else {
      messages = [];
    }
  }

  @override
  Future<void> close() {
    channel.sink.close();
    return super.close();
  }
}
