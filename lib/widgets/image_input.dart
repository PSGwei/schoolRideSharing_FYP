import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageInputContainer extends StatefulWidget {
  const ImageInputContainer({
    super.key,
    required this.onImagePicked,
  });

  final Function(Uint8List image) onImagePicked;

  @override
  State<ImageInputContainer> createState() => _ImageInputContainerState();
}

class _ImageInputContainerState extends State<ImageInputContainer> {
  File? selectedImage;
  void uploadPhoto() async {
    final iamgePicker = ImagePicker();
    final XFile? pickedImage =
        await iamgePicker.pickImage(source: ImageSource.camera, maxWidth: 600);

    if (pickedImage == null) return;

    setState(() {
      selectedImage = File(pickedImage.path);
    });

    final Uint8List imageInBytes = await pickedImage.readAsBytes();

    widget.onImagePicked(imageInBytes);
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    Widget containerContent = TextButton.icon(
      onPressed: uploadPhoto,
      icon: const Icon(Icons.upload),
      label: const Text('Take Photo'),
    );

    if (selectedImage != null) {
      containerContent = GestureDetector(
        onTap: uploadPhoto,
        child: Image.file(
          selectedImage!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          SizedBox(height: screenHeight * 0.25),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                width: 1,
              ),
            ),
            height: 250,
            alignment: Alignment.center,
            child: containerContent,
          ),
        ],
      ),
    );
  }
}
