import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AppImagePicker extends StatefulWidget {
  final void Function(File? image) onImageSelected;
  final File? initialImage;

  const AppImagePicker({
    super.key,
    required this.onImageSelected,
    this.initialImage,
  });

  @override
  State<AppImagePicker> createState() => _AppImagePickerState();
}

class _AppImagePickerState extends State<AppImagePicker> {
  File? _imagem;
  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    _imagem = widget.initialImage;
    super.initState();
  }

  Future<void> _escolherImagem() async {
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
                  final img = await picker.pickImage(
                    source: ImageSource.camera,
                  );
                  if (img != null) {
                    setState(() => _imagem = File(img.path));
                    widget.onImageSelected(_imagem);
                  }
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text("Escolher da galeria"),
                onTap: () async {
                  final img = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (img != null) {
                    setState(() => _imagem = File(img.path));
                    widget.onImageSelected(_imagem);
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _escolherImagem,
      child: Container(
        height: 140,
        width: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: Colors.grey),
        ),
        child:
            _imagem == null
                ? const Center(
                  child: Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                )
                : ClipOval(
                  child: Image.file(
                    _imagem!,
                    fit: BoxFit.cover,
                    width: 140,
                    height: 140,
                  ),
                ),
      ),
    );
  }
}
