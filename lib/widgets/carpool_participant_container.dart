import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:school_ride_sharing/models/carpool.dart';
import 'package:school_ride_sharing/models/user.dart' as models;
import 'package:school_ride_sharing/screens/carpool_manage/request.dart';

class CarpoolParticipantContainer extends StatelessWidget {
  const CarpoolParticipantContainer({
    super.key,
    required this.user,
    required this.carpool,
  });

  final models.User user;
  final Carpool carpool;

  @override
  Widget build(BuildContext context) {
    final currentUserID = FirebaseAuth.instance.currentUser!.uid;

    return Container(
      child: Column(
        children: [
          currentUserID == carpool.uid
              ? GestureDetector(
                  onTap: () {
                    showPopup(context);
                  },
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(user.avatar),
                  ),
                )
              : CircleAvatar(
                  backgroundImage: NetworkImage(user.avatar),
                ),
          Text(user.username)
        ],
      ),
    );
  }

  Future<void> showPopup(BuildContext context) async {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset position = renderBox.localToGlobal(Offset.zero);
    final selectedValue = await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
          position.dx, position.dy, position.dx, position.dy),
      items: <PopupMenuEntry>[
        const PopupMenuItem(
          value: 'delete',
          child: Text('Delete'),
        ),
      ],
    );
    // Handle the action based on the selected value
    if (selectedValue == 'delete') {
      await deleteParticipant();
    }
  }

  Future<void> deleteParticipant() async {
    // Assuming 'participants' is a list of user IDs in the carpool document
    final collectionRef = FirebaseFirestore.instance.collection('carpools');
    final docRef = collectionRef.doc(carpool.id);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(docRef);
      if (snapshot.exists) {
        List<dynamic> participants = snapshot['participants'];
        participants.remove(user.uid);

        transaction.update(docRef, {'participants': participants});
      }
    }).catchError((error) {
      // Handle the error
      print(error);
    });

    final carpoolInFireStore = await firestore
        .collection('carpools')
        .where('id', isEqualTo: carpool.id)
        .limit(1)
        .get();

    if (carpoolInFireStore.docs.isNotEmpty) {
      // update available seat
      int availableSeats = carpoolInFireStore.docs[0].get('availableSeat') - 1;

      await carpoolInFireStore.docs[0].reference.update({
        'availableSeat': availableSeats,
      });
    }
  }
}
