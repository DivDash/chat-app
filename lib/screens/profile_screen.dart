import 'package:chat/main.dart';
import 'package:chat/models/chat_user.dart';
import 'package:chat/provider/app_providers.dart';
import 'package:chat/services/database_service.dart';
import 'package:chat/widgets/profile_pic_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/sign_out_btn.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late ChatUser _user;
  String? _name;
  String? _about;

  @override
  Widget build(BuildContext context) {
    final userAsyncValue = ref.watch(userProvider);
    
    return userAsyncValue.when(
      data: (user) {
        if (user == null) {
          return const Center(child: Text('No user data available'));
        }
        _user = user;
        
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            appBar: AppBar(
              title: const Text("Profile Screen"),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
            ),
            floatingActionButton: SignOutBtn(context),
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
                      ProfilePicDialog(),
                      SizedBox(
                        width: mq.width,
                        height: mq.height * .03,
                      ),
                      Text(
                        user.email,
                        style: const TextStyle(color: Colors.black54, fontSize: 16),
                      ),
                      SizedBox(
                        width: mq.width,
                        height: mq.height * .05,
                      ),
                      TextFormField(
                        initialValue: user.name,
                        onSaved: (val) => _name = val,
                        validator: (val) =>
                            val != null && val.isNotEmpty ? null : 'Required field',
                        decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.person),
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
                        initialValue: user.about,
                        onSaved: (val) => _about = val,
                        validator: (val) =>
                            val != null && val.isNotEmpty ? null : 'Required field',
                        decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.info_outline),
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
                              if (_name != null) _user.name = _name!;
                              if (_about != null) _user.about = _about!;
                              DatabaseService.updateUserInfo(_user).then((value) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Profile Updated Successfully")
                                  )
                                );
                              });
                            }
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text("UPDATE")),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}
