import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:school_ride_sharing/models/address.dart';
import 'package:school_ride_sharing/screens/carpool_list.dart';
import 'package:school_ride_sharing/utilities/common_methods.dart';
import 'package:school_ride_sharing/utilities/storage_method.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

class AddCarpool extends StatefulWidget {
  final Address pickUpLocation;
  final Address dropOffLocation;

  const AddCarpool({
    super.key,
    required this.pickUpLocation,
    required this.dropOffLocation,
  });

  @override
  State<AddCarpool> createState() => _AddCarpoolState();
}

class _AddCarpoolState extends State<AddCarpool> {
  final _form = GlobalKey<FormState>();

  DateTime date = DateTime.now();
  TimeOfDay time = TimeOfDay.now();
  int seat = 4;
  String formattedDate = '';
  String formattedTime = '';

  void _datePicker() async {
    final dateNow = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: dateNow,
      firstDate: DateTime.now(),
      lastDate: DateTime(dateNow.year, dateNow.month + 2, 0),
    );
    if (pickedDate != null) {
      setState(() {
        formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  void _timePicker() {
    showTimePicker(context: context, initialTime: TimeOfDay.now())
        .then((value) {
      setState(() {
        time = value!;
        formattedTime = value.format(context).toString();
      });
    });
  }

  void submit(BuildContext context) async {
    _form.currentState!.save();

    var currentUser = FirebaseAuth.instance.currentUser;

    DateTime dateTimeCombined =
        DateTime(date.year, date.month, date.day, time.hour, time.minute, 0);

    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .get();

    // final userInfo = usermodel.User(
    //   uid: currentUser.uid,
    //   username: userData['username'],
    //   // avatar: null,
    //   gender: '',
    //   credit: 0,
    // );

    final result = await StorageMethods().addCarpooltoFireStore(
      widget.dropOffLocation,
      widget.pickUpLocation,
      seat,
      seat,
      dateTimeCombined,
    );

    if (!context.mounted) return;

    displaySnackbar('carpool successfully created', context);

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Provide a Carpool'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  initialValue: widget.pickUpLocation.humanReadableAddress,
                  readOnly: true,
                  decoration: const InputDecoration(label: Text('From')),
                  style: const TextStyle(overflow: TextOverflow.ellipsis),
                  // onSaved: (value) {
                  //   from = value!;
                  // },
                ),
                TextFormField(
                  initialValue: widget.dropOffLocation.humanReadableAddress,
                  readOnly: true,
                  decoration: const InputDecoration(label: Text('To')),
                  style: const TextStyle(overflow: TextOverflow.ellipsis),
                  // onSaved: (value) {
                  //   destination = value!;
                  // },
                ),
                // Date
                TextFormField(
                  controller: TextEditingController(
                    text: formattedDate,
                  ),
                  decoration: const InputDecoration(
                    label: Text('Date'),
                  ),
                  onTap: _datePicker,
                  readOnly: true,
                  onSaved: (value) {
                    date = DateTime.parse(value!);
                  },
                ),
                // Time
                TextFormField(
                  controller: TextEditingController(
                    text: formattedTime,
                  ),
                  decoration: const InputDecoration(label: Text('Time')),
                  readOnly: true,
                  onTap: _timePicker,
                  // onSaved: (value){
                  //   time = TimeOfDay.
                  // },
                ),
                TextFormField(
                  decoration:
                      const InputDecoration(label: Text('Seat available')),
                  onSaved: (value) {
                    seat = int.parse(value!);
                  },
                ),
                TextFormField(
                    decoration: const InputDecoration(
                        label: Text('Additional Information'))),
                SizedBox(height: 30),
                ElevatedButton(
                    onPressed: () {
                      submit(context);
                    },
                    child: const Text('Create')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
