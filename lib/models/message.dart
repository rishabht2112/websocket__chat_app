import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  final String message;
  final bool isSentByMe;

  const ChatMessage(this.message, this.isSentByMe);

  @override
  List<Object> get props => [message, isSentByMe];
}