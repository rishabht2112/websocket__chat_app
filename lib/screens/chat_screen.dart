
import 'package:chat_application_websocket/screens/switch_user_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/chat/chat_bloc.dart';
import '../bloc/chat/chat_event.dart';
import '../bloc/chat/chat_state.dart';
import 'auth_screen.dart';


class ChatPage extends StatelessWidget {
  final String username;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  ChatPage(this.username, {super.key});

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 10,
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            OnlineIndicator(),
            SizedBox(width: 8,),
            Text('WebSocket Echo - $username'),
          ],
        ),
        actions: [
          Tooltip(
            message: 'Log out to switch!',
            child: IconButton(
              icon: Icon(Icons.switch_account),
              onPressed: () async {
                final newUsername = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => UserListPage(),
                  ),
                );
                if (newUsername != null) {
                  BlocProvider.of<ChatBloc>(context).add(SwitchUser(newUsername));
                }
              },
            ),
          ),
          Tooltip(
            message: "Log out",
            child: IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => LoginPage(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: Card(
        elevation: 5,
        surfaceTintColor: Colors.white,
        color: Colors.white,
        child: Row(
          children: [
            // Left decorative panel
            if (MediaQuery.of(context).size.width > 375)
              Expanded(
                flex: 1,
                child: Container(
                  color: Colors.blueGrey[50],
                  child: Center(child: Text('')),
                ),
              ),
            // Chat container
            Container(
              constraints: BoxConstraints(maxWidth: 375),
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: BlocBuilder<ChatBloc, ChatState>(
                      builder: (context, state) {
                        if (state is ChatUpdated) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _scrollToBottom();
                          });
                          return ListView.builder(
                            controller: _scrollController,
                            itemCount: state.messages.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              final message = state.messages[index];
                              final alignment = message.isSentByMe
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start;
                              final backgroundColor = message.isSentByMe
                                  ? Colors.blue[100]
                                  : Colors.green[200];
                              return Container(
                                alignment: message.isSentByMe
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                padding: EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 8),
                                child: Row(
                                  mainAxisAlignment: message.isSentByMe
                                      ? MainAxisAlignment.end
                                      : MainAxisAlignment.start,
                                  children: [
                                    if (!message.isSentByMe)
                                      CircleAvatar(
                                        child: Icon(Icons.android, color: Colors.green),
                                      ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Container(
                                        // constraints: BoxConstraints(
                                        //   maxWidth: MediaQuery.of(context).size.width * 0.5,
                                        // ),
                                        decoration: BoxDecoration(
                                          color: backgroundColor,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        padding: EdgeInsets.all(10),
                                        child: Column(
                                          crossAxisAlignment: alignment,
                                          children: [
                                            Text(
                                              message.isSentByMe ? username : 'Server',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              message.message,
                                              softWrap: true,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    if (message.isSentByMe)
                                      CircleAvatar(
                                       child: Icon(Icons.person), // Replace with user's avatar URL
                                      ),
                                  ],
                                ),
                              );
                            },
                          );
                        }
                        return Center(
                          child: Text('Send a message to the server'),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: InputDecoration(
                              labelText: 'Enter message',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.blue,
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            final message = _controller.text;
                            if (message.isNotEmpty) {
                              BlocProvider.of<ChatBloc>(context).add(SendMessage(message));
                              _controller.clear();
                              _scrollToBottom();
                            }
                          },
                          child: Icon(Icons.send),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Right decorative panel
            if (MediaQuery.of(context).size.width > 400)
              Expanded(
                flex: 1,
                child: Container(
                  color: Colors.blueGrey[50],
                  child: Center(child: Text('')),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class OnlineIndicator extends StatelessWidget {
  final double size;
  final Color color;

  const OnlineIndicator({
    Key? key,
    this.size = 16.0,
    this.color = Colors.green,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(
          color: Colors.white,
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
    );
  }
}