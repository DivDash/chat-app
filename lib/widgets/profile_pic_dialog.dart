import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/main.dart';
import 'package:chat/models/chat_user.dart';
import 'package:chat/provider/app_providers.dart';
import 'package:chat/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePicDialog extends ConsumerStatefulWidget {
  const ProfilePicDialog({super.key});

  @override
  ConsumerState<ProfilePicDialog> createState() => _ProfilePicDialogState();
}

class _ProfilePicDialogState extends ConsumerState<ProfilePicDialog> {
  String? _image;
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    final userAsyncValue = ref.watch(userProvider);
    
    return userAsyncValue.when(
      data: (user) {
        if (user == null) {
          return const SizedBox();
        }
        
        return Stack(
          children: [
            _image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * 0.1),
                    child: Image.file(
                      File(_image!),
                      fit: BoxFit.cover,
                      width: mq.height * 0.2,
                      height: mq.height * 0.2,
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * 0.1),
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      width: mq.height * 0.2,
                      height: mq.height * 0.2,
                      imageUrl: user.image,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) => const CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                    ),
                  ),
            if (_isUploading)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(mq.height * 0.1),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
              ),
            Positioned(
              bottom: 0,
              right: 0,
              child: MaterialButton(
                elevation: 1,
                onPressed: _isUploading ? null : () => _showBottomSheet(context, user),
                color: Colors.white,
                shape: const CircleBorder(),
                child: const Icon(
                  Icons.edit,
                  color: Colors.black,
                  size: 20,
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }

  void _showBottomSheet(BuildContext context, ChatUser user) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (_) {
        return ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(
            top: mq.height * 0.02,
            bottom: mq.height * 0.05,
          ),
          children: [
            const Center(
              child: Text(
                "Pick Profile Picture",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.all(10),
                  ),
                  onPressed: () => _handleImageSelection(ImageSource.camera, context, user),
                  child: const Icon(Icons.camera_alt),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    iconSize: 60,
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.all(10),
                  ),
                  onPressed: () => _handleImageSelection(ImageSource.gallery, context, user),
                  child: const Icon(Icons.photo),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleImageSelection(ImageSource source, BuildContext context, ChatUser user) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);
      
      if (image != null) {
        setState(() {
          _image = image.path;
          _isUploading = true;
        });
        
        Navigator.pop(context);
        
        await StorageService.updateProfilePicture(File(image.path), user);
        
        setState(() {
          _isUploading = false;
          _image = null;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile picture updated successfully')),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile picture: ${e.toString()}')),
        );
      }
    }
  }
}
