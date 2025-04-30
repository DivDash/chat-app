import 'package:chat/models/chat_user.dart';
import 'package:chat/provider/app_providers.dart';
import 'package:chat/services/database_service.dart';
import 'package:chat/widgets/add_chatuser_dialog.dart';
import 'package:chat/widgets/search_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/chat_user_card.dart';
import '../widgets/home_btn.dart';
import '../widgets/vert_dots.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  List<ChatUser> _list = [];
  final List<ChatUser> _searchList = [];
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: HomeButton(context),
        title: _isSearching
            ? TextField(
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Name, Email...',
                ),
                onChanged: (val) {
                  _searchList.clear();
                  for (var i in _list) {
                    if (i.name.toLowerCase().contains(val.toLowerCase()) ||
                        i.email.toLowerCase().contains(val.toLowerCase())) {
                      _searchList.add(i);
                    }
                    setState(() {});
                  }
                },
              )
            : const Text("Div Chat"),
        actions: [
          SearchBtn(
            onSearchToggle: (isSearching) {
              setState(() {
                _isSearching = isSearching;
              });
            },
          ),
          VerticalDots(),
        ],
      ),
      floatingActionButton: AddChatUserDialog(),
      body: StreamBuilder(
        stream: DatabaseService.getMyUsers(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.none:
              return const Center(child: CircularProgressIndicator());
            case ConnectionState.active:
            case ConnectionState.done:
              return StreamBuilder(
                stream: DatabaseService.getAllUsers(
                  snapshot.data?.snapshot.children
                          .map((e) => e.key ?? '')
                          .toList() ??
                      [],
                ),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return const Center(child: CircularProgressIndicator());
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
                          physics: const BouncingScrollPhysics(),
                          itemCount:
                              _isSearching ? _searchList.length : _list.length,
                          itemBuilder: (context, index) {
                            return ChatUserCard(
                              user: _isSearching
                                  ? _searchList[index]
                                  : _list[index],
                            );
                          },
                        );
                      } else {
                        return const Center(
                          child: Text(
                            "No connection found",
                            style: TextStyle(fontSize: 20),
                          ),
                        );
                      }
                  }
                },
              );
          }
        },
      ),
    );
  }
}
