import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:school_ride_sharing/screens/carpool_list.dart';
import 'package:school_ride_sharing/screens/tabs.dart';
import 'package:school_ride_sharing/utilities/common_methods.dart';
import 'package:school_ride_sharing/utilities/storage_method.dart';
import 'package:school_ride_sharing/widgets/image_input.dart';
import 'package:school_ride_sharing/widgets/loading_dialog.dart';

class UploadEvidence extends StatefulWidget {
  const UploadEvidence({super.key});

  @override
  State<UploadEvidence> createState() => _UploadEvidenceState();
}

class _UploadEvidenceState extends State<UploadEvidence> {
  Uint8List? imageFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: const Text(
          'Evidence Submission',
        ),
        actions: [
          TextButton(
              onPressed: () {
                if (imageFile != null) {
                  uploadImageToFirebase(imageFile!);
                } else {
                  displaySnackbar(
                      'Please upload photo before submitting', context);
                }
              },
              child: const Text(
                'Submit',
                style: TextStyle(
                  fontSize: 18,
                ),
              )),
        ],
      ),
      body: ImageInputContainer(
        onImagePicked: (imgFile) {
          setState(() {
            imageFile = imgFile;
          });
        },
      ),
    );
  }

  void uploadImageToFirebase(Uint8List imageFile) async {
    showDialog(
      context: context,
      barrierDismissible: false, // User must tap button to close dialog
      builder: (BuildContext context) {
        return LoadingDialog(
          messageText: 'Uploading image...',
        );
      },
    );

    try {
      await StorageMethods()
          .uploadImageToStorage('carpool evidences', imageFile);

      if (!context.mounted) return;
      Navigator.of(context).pop();
      displaySnackbar('Image uploaded successfully', context);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const TabsScreen()),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop();
      displaySnackbar('Failed to upload image', context);
    }
  }
}
