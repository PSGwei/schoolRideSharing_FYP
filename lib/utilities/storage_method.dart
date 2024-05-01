import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:school_ride_sharing/models/address.dart';
import 'package:school_ride_sharing/models/carpool.dart';
import 'package:school_ride_sharing/utilities/global_variables.dart';

class StorageMethods {
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth userAuth = FirebaseAuth.instance;

  Future<String> uploadImageToStorage(String childName, Uint8List imageFile,
      {Carpool? carpool}) async {
    Reference ref;

    if (carpool != null) {
      ref = firebaseStorage.ref().child(childName).child('${carpool.uid}.png');
    } else {
      ref = firebaseStorage
          .ref()
          .child(childName)
          .child('${userAuth.currentUser!.uid}.png');
    }

    // upload image
    await ref.putData(imageFile);

    // get image URL
    String imageURL = await ref.getDownloadURL();
    return imageURL;
  }

  Future<String> addCarpooltoFireStore(
    Address destination,
    Address pickUp,
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
      status: false,
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
