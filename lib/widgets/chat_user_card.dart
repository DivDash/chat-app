
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/models/chat_user.dart';
import 'package:chat/screens/chat_screen.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;

  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      child: InkWell(onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (_)=> ChatScreen(user: widget.user)));
      },
    child: ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(mq.height * 0.3),
        child: CachedNetworkImage(
          width: mq.height * 0.055,
          height: mq.height * 0.055,
          imageUrl: widget.user.image,
          placeholder: (context, url) => CircularProgressIndicator(),
          errorWidget: (context, url, error) => 
          CircleAvatar( child: Icon(Icons.person),
        ),),
      ),
      title: Text(widget.user.name),
      subtitle: Text(widget.user.about, maxLines: 1  ,),
      trailing: Text('12:00 PM', style: TextStyle(color: Colors.black54),),
      
    ),),);
  }
}