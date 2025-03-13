
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../API/api.dart';
import '../main.dart';
import '../models/chat_user.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Profile Screen"),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.redAccent,
          onPressed: () async {
            await Api.auth.signOut().then((value) async {
              await GoogleSignIn().signOut().then((value) {
                //for hiding the current screen
                Navigator.pop(context);

                //for navigating to the home screen
                Navigator.pop(context);

                //replacing the current screen with the login screen
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => LoginScreen()));
              });
            });
          },
          icon: Icon(Icons.logout),
          label: Text("Logout"),
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    width: mq.width,
                    height: mq.height * .03,
                  ),
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(mq.height * 0.1),
                        child: CachedNetworkImage(
                          fit: BoxFit.fill,
                          width: mq.height * 0.2,
                          height: mq.height * 0.2,
                          imageUrl: widget.user.image,
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) => CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2)),
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: mq.width,
                    height: mq.height * .03,
                  ),
                  Text(
                    widget.user.email,
                    style: TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                  SizedBox(
                    width: mq.width,
                    height: mq.height * .05,
                  ),
                  TextFormField(
                    initialValue: widget.user.name,
                    onSaved: (val) => Api.selfUser.name = val ?? '',
                    validator: (val) => val != null && val.isNotEmpty ? null : 'Required field',
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person),
                        labelText: "Name",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        hintText: 'eg. Happy Singh'),
                  ),
                  SizedBox(
                    width: mq.width,
                    height: mq.height * .02,
                  ),
                  TextFormField(
                    initialValue: widget.user.about,
                    onSaved: (val) => Api.selfUser.about = val ?? '',
                    validator: (val) => val != null && val.isNotEmpty ? null : 'Required field',
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.info_outline),
                        labelText: "About",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        hintText: 'Feeling Happy'),
                  ),
                  SizedBox(
                    width: mq.width,
                    height: mq.height * .05,
                  ),
                  ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          Api.updateUserInfo().then((value){
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text("Profile Updated Successfully")));

                          });
                

                          
                          
                        }
                      },
                      icon: Icon(Icons.edit),
                      label: Text("UPDATE")),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
