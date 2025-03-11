import 'dart:developer';
import 'package:flutter/material.dart';

import '../API/api.dart';
import '../helper/my_date_utils.dart';
import '../main.dart';
import '../models/message.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});

  final Message message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    return Api.user.uid == widget.message.fromId
        ? _greenMessage()
        : _blueMessage();
  }

  //sender or other user message
  Widget _blueMessage() {

    //update last message
    if (widget.message.read.isEmpty) {
      Api.updateMessageReadStatus(widget.message);
      log('message read updated');
      
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(mq.width * 0.02),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * 0.04, vertical: mq.height * 0.01),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Text(
              widget.message.msg,
              style: TextStyle(fontSize: 17, color: Colors.black87),
            ),
          ),
        ),

        //message time 
        Padding(
          padding: EdgeInsets.only(right: mq.width * 0.04),
          child: Text(
              MyDateUtils.getFormattedDateTime(
                  context: context, time: widget.message.sent),
            style: TextStyle(color: Colors.black54, fontSize: 13),
          ),
        ),
      ],
    );
  }

  //receiver or self message
  Widget _greenMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            //for adding some space
            SizedBox(
              width: mq.width * 0.04,
            ),
            //icon of double tick
            if (widget.message.read.isNotEmpty)
              Icon(
                Icons.done_all_rounded,
                color: Colors.blue,
                size: 20,
              ),
            // for add space bw
            SizedBox(
              width: mq.width * 0.01,
            ),
            //sent time
            Text(
              MyDateUtils.getFormattedDateTime(
                  context: context, time: widget.message.sent),
              style: TextStyle(color: Colors.black54, fontSize: 13),
            ),
          ],
        ),
        Flexible(
          child: Container(
            padding: EdgeInsets.all(mq.width * 0.02),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * 0.04, vertical: mq.height * 0.01),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
            ),
            child: Text(
              widget.message.msg,
              style: TextStyle(fontSize: 17, color: Colors.black87),
            ),
          ),
        ),
      ],
    );
  }
}
