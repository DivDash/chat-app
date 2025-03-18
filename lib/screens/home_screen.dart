import 'dart:math';

import 'package:chat/api/api_database.dart';
import 'package:chat/helpers/toast_message.dart';
import 'package:chat/models/chat_user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../widgets/chat_user_card.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> _list = [];
  final List<ChatUser> _searchList = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    ApiDatabase.getSelfInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
        appBar: AppBar(
          
          leading: IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
          title: _isSearching
              ? TextField(
                  decoration: InputDecoration(
                      border: InputBorder.none, hintText: 'Name, Email...'),
                  onChanged: (val) {
                    _searchList.clear();
                    for (var i in _list) {
                      if (i.name.toLowerCase().contains(val.toLowerCase()) ||
                          i.email.toLowerCase().contains(val.toLowerCase())) {
                        _searchList.add(i);
                      }
                      setState(() {
                        _searchList;
                      });
                    }
                  },
                )
              : Text("Div Chat"),
          actions: [
            IconButton(
              icon: Icon(_isSearching
                  ? CupertinoIcons.clear_circled_solid
                  : Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ProfileScreen(user: ApiDatabase.selfUser)));
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            _addChatUserDialog();
          },
          child: Icon(Icons.add_comment),
        ),
        body: StreamBuilder(
            stream: ApiDatabase.getMyUsers(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                //if data is loading
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return Center(child: CircularProgressIndicator());
                //if some or all data is loading then show it
                case ConnectionState.active:
                case ConnectionState.done:
                  return StreamBuilder(
                    stream: ApiDatabase.getAllUsers(
                        snapshot.data?.snapshot.children
                            .map((e) => e.key ?? '')
                            .toList() ?? []),
                            //get only those users whose id are provided
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        //if data is loading
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return Center(child: CircularProgressIndicator());
                        //if some or all data is loading then show it
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.snapshot.children;
                          _list = data
                                  ?.map((e) => ChatUser.fromJson(
                                      Map<String, dynamic>.from(e.value as Map)))
                                  .toList() ??
                              [];

                          if (_list.isNotEmpty) {
                            return ListView.builder(
                              physics: BouncingScrollPhysics(),
                              itemCount: _isSearching
                                  ? _searchList.length
                                  : _list.length,
                              itemBuilder: (context, index) {
                                return ChatUserCard(
                                    user: _isSearching
                                        ? _searchList[index]
                                        : _list[index]);
                                //return Text('name: ${list[index]}');
                              },
                            );
                          } else {
                            return Center(
                                child: Text("No connection found",
                                    style: TextStyle(
                                      fontSize: 20,
                                    )));
                          }
                      }
                    },
                  );
              }
            }));
  }

  //for addng chat user dialog
  void _addChatUserDialog() {
    String email = '';

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: const EdgeInsets.only(
                  left: 20, right: 20, top: 20, bottom: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Icon(
                    Icons.person_add,
                    size: 28,
                  ),
                  Text("Enter Email"),
                ],
              ),
              content: TextFormField(
                maxLines: 1,
                onChanged: (value) => email = value,
                decoration: InputDecoration(
                  hintText: 'Email',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    if (email.isNotEmpty) {
                      Navigator.pop(context);
                      if (email.isNotEmpty) {
                        await ApiDatabase.addChatUser(email, ApiDatabase.user.uid).then((value) {
                          if (!value) {
                            ToastMessage().toastMessage('User does not exist!, $e');
                          }
                        });
                      }
                    }
                  },
                  child: Text('Add'),
                ),
              ],
            ));
  }
}
