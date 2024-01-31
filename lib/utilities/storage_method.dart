import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:school_ride_sharing/models/carpool.dart';
import 'package:school_ride_sharing/utilities/global_variables.dart';
import 'package:path/path.dart' as path;

class StorageMethods {
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth userAuth = FirebaseAuth.instance;

  Future<String> uploadImageToStorage(
      String childName, String imagePath) async {
    // retrieve binary data of the image
    final imageByteData = await rootBundle.load(imagePath);

    // provides a Directory object that points to a temporary directory on the device
    // this function just return the path, doesn't create and return a new directory
    final Directory tempDir = await getTemporaryDirectory();

    final String tempFilePath = '${tempDir.path}/${path.basename(imagePath)}';

    // Create a file instance
    final File tempFile = File(tempFilePath);

    // make sure the temporary directory exist
    await tempDir.create(recursive: true);

    // write the data to file
    await tempFile.writeAsBytes(imageByteData.buffer.asUint8List());

    //creates a reference(pointer) to a location( a file or a directory) within Firebase Storage,
    //allowing to access or modify it.
    Reference ref = firebaseStorage
        .ref()
        .child(childName)
        .child('${userAuth.currentUser!.uid}.png');

    // upload image
    await ref.putFile(tempFile);

    await tempFile.delete();

    // get image URL
    String imageURL = await ref.getDownloadURL();
    return imageURL;
  }

  Future<String> addCarpooltoFireStore(
    String destination,
    String pickUp,
    int totalSeat,
    int availableSeat,
    DateTime departureTime,
  ) async {
    String carpoolID = uuid.v4();
    String result = 'Something went wrong';

    Carpool carpool = Carpool(
      id: carpoolID,
      uid: userAuth.currentUser!.uid,
      pickUp: pickUp,
      destination: destination,
      totalSeat: totalSeat,
      availableSeat: availableSeat,
      departureTime: departureTime,
      participants: [],
    );

    try {
      await firebaseFirestore
          .collection('carpools')
          .doc(carpoolID)
          .set(carpool.toJson());
    } catch (error) {
      result = error.toString();
    }

    result = 'Success';
    return result;
  }

/*
  // Future<String> uploadPost(
  //   String description,
  //   Uint8List imageFile,
  //   String uid,
  //   String username,
  //   String profileImage,
  // ) async {
  //   String result = 'Something went wrong';

  //   try {
  //     String photoURL = await uploadImageToStorage('posts', imageFile, true);
  //     String postID = _uuid.v1();
  //     Post post = Post(
  //       description: description,
  //       uid: uid,
  //       username: username,
  //       likes: [],
  //       postId: postID,
  //       datePublished: DateTime.now(),
  //       photoURL: photoURL,
  //       profImage: profileImage,
  //     );

  //     await firebaseFirestore
  //         .collection('posts')
  //         .doc(postID)
  //         .set(post.toJson());
  //   } catch (error) {
  //     result = error.toString();
  //   }

  //   result = 'Success';

  //   return result;
  // }
  */
}
