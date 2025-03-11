
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../API/api.dart';
import '../main.dart';
import '../models/chat_user.dart';
import '../models/message.dart';
import '../widgets/message_card.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _textController = TextEditingController();
  //for storing all messages
  List<Message> _list = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        shadowColor: Colors.transparent,
        flexibleSpace: _appBar(),
      ),
      
      body: Column(
        children: [ 
          Expanded(
            child: StreamBuilder(
            stream: Api.getAllMessages(widget.user),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                //if data is loading
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return SizedBox();
                //if some or all data is loading then show it
                case ConnectionState.active:
                case ConnectionState.done:
                  final data = snapshot.data?.docs;
                  _list =
                      data?.map((e) => Message.fromJson(e.data())).toList() ??
                          [];
    
            
            
                  if (_list.isNotEmpty) {
                    return ListView.builder(
                      physics: BouncingScrollPhysics(),
                      itemCount: _list.length,
                      itemBuilder: (context, index) {
                        //ChatUserCard(user: _isSearching ? _searchList[index] : _list[index]);
                        return MessageCard(message: _list[index]);
                      },
                    );
                  } else {
                    return Center(
                        child: Text("Say Hii! 👋",
                            style: TextStyle(
                              fontSize: 20,
                            )));
                  }
              }
            },
                    ),
          ),
          _chatInput()],
      ),
    );
  }

  Widget _appBar() {
    return InkWell(
      onTap: () {
        //Navigator.push(context, MaterialPageRoute(builder: (_){})),
      },
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(mq.height * 0.3),
            child: CachedNetworkImage(
              width: mq.height * 0.05,
              height: mq.height * 0.05,
              imageUrl: widget.user.image,
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => CircleAvatar(
                child: Icon(Icons.person),
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.user.name,
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 2,
              ),
              Text(
                'Last seen not Available',
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: mq.height * 0.01, 
          horizontal: mq.width * .03),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  //emoji button
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.emoji_emotions,
                      color: Colors.blueAccent,
                      size: 25,
                    ),
                  ),
                  //text input field
                  Expanded(
                      child: TextField(
                        controller: _textController,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                    decoration: InputDecoration(
                        hintText: 'Type something ... ',
                        hintStyle: TextStyle(color: Colors.blueAccent),
                        border: InputBorder.none),
                  )),
                  //pick image from gallery button
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.image,
                      color: Colors.blueAccent,
                      size: 28,
                    ),
                  ),
                  //take image from camera button
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.blueAccent,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),
          //send message button
          IconButton(
            onPressed: () {
              if (_textController.text.isNotEmpty) {
                if (_list.isEmpty) {
                  Api.sendFirstMessage(widget.user, _textController.text, Type.text);
                } else {
                Api.sendMessage(widget.user, _textController.text);
                }
                _textController.text = '';
              }
            },
            padding: EdgeInsets.all(05),
            color: Colors.green,
            icon: Icon(
              Icons.send,
              color: Colors.blueAccent,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}
