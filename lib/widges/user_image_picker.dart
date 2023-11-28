import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

class USerImagePicker extends StatefulWidget {
  const USerImagePicker({super.key, required this.onPickImage});

  final void Function(File pickedImage) onPickImage;

  @override
  State<USerImagePicker> createState() => _USerImagePickerState();
}

class _USerImagePickerState extends State<USerImagePicker> {
  File? _pickedImageFile;

  void _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(source:
    ImageSource.camera,
      imageQuality: 50,
      maxWidth: 150,
    );

    if(pickedImage == null) {
      return;
    }

    setState(() {
    _pickedImageFile = File(pickedImage.path);
   });

    widget.onPickImage(_pickedImageFile!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          foregroundImage:
          _pickedImageFile != null ? FileImage(_pickedImageFile!) : null,
        ),
        TextButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.image),
            label: Text(
              'Add image',
              style: TextStyle(color: Theme.of(context).colorScheme.primary ),
            ),
        ),
      ],
    );
  }
}
