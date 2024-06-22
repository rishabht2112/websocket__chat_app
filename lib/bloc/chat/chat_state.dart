
import 'package:equatable/equatable.dart';

import '../../models/message.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object> get props => [];
}

class ChatInitial extends ChatState {}

class ChatUpdated extends ChatState {
  final String username;
  final List<ChatMessage> messages;

  const ChatUpdated(this.username, this.messages);

  @override
  List<Object> get props => [username, messages];
}