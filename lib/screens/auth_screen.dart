import 'package:chat_application_websocket/screens/switch_user_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../bloc/chat/chat_bloc.dart';
import 'chat_screen.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 10,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(_isLogin ? 'Login' : 'Sign Up', style: TextStyle(fontWeight: FontWeight.bold),),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            // Web Layout
            return Row(
              children: [
                Expanded(
                  child: Container(
                    color: Colors.blueAccent,
                    child: Center(
                      child: Image.asset('assets/logo.jpeg', width: 200),
                    ),
                  ),
                ),
                Expanded(
                  child: _buildLoginForm(),
                ),
              ],
            );
          } else {
            // Mobile Layout
            return Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.3,
                    color: Colors.blueAccent,
                    child: Center(
                      child: Image.asset('assets/logo.jpeg', width: 100),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                      _buildLoginForm(),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildLoginForm() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isLogin ? 'Welcome Back!' : 'Create New Account',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 40),
            _buildTextField(_usernameController, 'Enter username'),
            const SizedBox(height: 20),
            _buildTextField(_passwordController, 'Enter password', obscureText: true),
            const SizedBox(height: 40),
            _buildElevatedButton(
              _isLogin ? 'Login' : 'Sign Up',
              _isLogin ? _login : _signUp,
            ),
            const SizedBox(height: 20),
            _buildTextButton(
              _isLogin
                  ? 'Don\'t have an account? Sign Up'
                  : 'Already have an account? Login',
                  () {
                setState(() {
                  _isLogin = !_isLogin;
                });
              },
            ),
            const SizedBox(height: 20),
            _buildElevatedButton(
              'Switch User',
                  () async {
                final newUsername = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>  const UserListPage(),
                  ),
                );
                if (newUsername != null) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => BlocProvider(
                        create: (context) => ChatBloc(
                          WebSocketChannel.connect(Uri.parse('wss://echo.websocket.org')),
                          newUsername,
                        ),
                        child: ChatPage(newUsername),
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: hintText,
        labelStyle: TextStyle(color: Theme.of(context).primaryColor),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.blue[50],
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
    );
  }

  Widget _buildElevatedButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(text, style: const TextStyle(fontSize: 14 )),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white, backgroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildTextButton(String text, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: Colors.blue,
          // color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Future<void> _login() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    final prefs = await SharedPreferences.getInstance();
    final storedPassword = prefs.getString('user_password_$username');

    if (storedPassword == password) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => ChatBloc(
              WebSocketChannel.connect(Uri.parse('wss://echo.websocket.org')),
              username,
            ),
            child: ChatPage(username),
          ),
        ),
      );
    } else {
      _showError('No user registered with given credentials!');
    }
  }

  Future<void> _signUp() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      _showError('Username and password cannot be empty');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final userList = prefs.getStringList('user_list') ?? [];

    if (userList.contains(username)) {
      _showError('Username already exists');
      return;
    }

    userList.add(username);
    await prefs.setStringList('user_list', userList);
    await prefs.setString('user_password_$username', password);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => ChatBloc(
            WebSocketChannel.connect(Uri.parse('wss://echo.websocket.org')),
            username,
          ),
          child: ChatPage(username),
        ),
      ),
    );
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,

        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

