
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserListPage extends StatelessWidget {
  const UserListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text('Registered Users!'),
      ),
      body: FutureBuilder<List<String>>(
        future: _getUserList(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!;

          return users.isEmpty ? Center(child: Container(child: Text('No user found!'),),) : ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              return Card(
                color: Colors.white,
                surfaceTintColor: Colors.white,
                elevation: 4,
                child: ListTile(
                  focusColor: Colors.blue,
                  hoverColor: Colors.blue,
                  selectedColor: Colors.blue,
                  splashColor: Colors.blue,
                  selectedTileColor: Colors.red,
                  leading: Icon(Icons.person),
                  title: Text(users[index]),
                  onTap: () {
                    Navigator.of(context).pop(users[index]);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<List<String>> _getUserList() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('user_list') ?? [];
  }
}