import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AppImagePicker extends StatefulWidget {
  final void Function(File? image) onImageSelected;
  final File? initialImage;
  final String? initialImageUrl;

  const AppImagePicker({
    super.key,
    required this.onImageSelected,
    this.initialImage,
    this.initialImageUrl,
  });

  @override
  State<AppImagePicker> createState() => _AppImagePickerState();
}

class _AppImagePickerState extends State<AppImagePicker> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _image = widget.initialImage;
  }

  Future<void> _chooseImage() async {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Tirar foto"),
                onTap: () async {
                  final img = await _picker.pickImage(
                    source: ImageSource.camera,
                  );
                  if (img != null) {
                    setState(() => _image = File(img.path));
                    widget.onImageSelected(_image);
                  }
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text("Escolher da galeria"),
                onTap: () async {
                  final img = await _picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (img != null) {
                    setState(() => _image = File(img.path));
                    widget.onImageSelected(_image);
                  }
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImage() {
    if (_image != null) {
      return Image.file(
        _image!,
        fit: BoxFit.cover,
        width: 140,
        height: 140,
      );
    }

    if (widget.initialImageUrl != null) {
      return Image.network(
        widget.initialImageUrl!,
        fit: BoxFit.cover,
        width: 140,
        height: 140,
        errorBuilder: (_, __, ___) {
          return const Icon(Icons.person, size: 40, color: Colors.grey);
        },
      );
    }

    return const Icon(Icons.add_a_photo, size: 40, color: Colors.grey);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _chooseImage,
      child: Container(
        height: 140,
        width: 140,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey),
        ),
        clipBehavior: Clip.antiAlias,
        child: _buildImage(),
      ),
    );
  }
}
