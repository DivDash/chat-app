
import 'package:chat/models/chat_user.dart';
import 'package:chat/services/database_service.dart';
import 'package:chat/widgets/add_person_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../widgets/chat_user_card.dart';
import '../widgets/home_btn.dart';
import '../widgets/vert_dots.dart';

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
    DatabaseService.getSelfInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: HomeButton(context),
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
            SearchButton(),
            VerticalDots(context),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            _addChatUserDialog();
          },
          child: Icon(Icons.add_comment),
        ),
        body: StreamBuilder(
            stream: DatabaseService.getMyUsers(),
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
                    stream: DatabaseService.getAllUsers(snapshot
                            .data?.snapshot.children
                            .map((e) => e.key ?? '')
                            .toList() ??
                        []),
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
                                      Map<String, dynamic>.from(
                                          e.value as Map)))
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

//for search btn
  IconButton SearchButton() {
    return IconButton(
      icon: Icon(
          _isSearching ? CupertinoIcons.clear_circled_solid : Icons.search),
      onPressed: () {
        setState(() {
          _isSearching = !_isSearching;
        });
      },
    );
  }

  //for addng chat user dialog
  void _addChatUserDialog() {
    String email = '';
    AddNewPersonDialog(context, email);
  }
}
