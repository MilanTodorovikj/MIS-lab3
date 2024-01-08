import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lab3mis/widgets/auth_gate.dart';

import '../model/Exam.dart';
import '../widgets/new_exam.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CollectionReference _itemsCollection = FirebaseFirestore.instance
      .collection('exams');
  List<Exam> _exams = [];

  void _addExam() {
    showModalBottomSheet(
        context: context,
        builder: (_) {
          return GestureDetector(
            onTap: () {},
            behavior: HitTestBehavior.opaque,
            child: NewExam(
              addExam: _addNewExamToDatabase,
            ),
          );
        });
  }

  void _addNewExamToDatabase(String subject, DateTime date, TimeOfDay time) {
    addExam(subject, date, time);
  }


  Future<void> addExam(String subject, DateTime date, TimeOfDay time) {
    User? user = FirebaseAuth.instance.currentUser;
    DateTime newDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
        0,
        0,
        0);
    if(user!=null) {
      return FirebaseFirestore.instance.collection('exams').add({
        'subject': subject,
        'date': newDate,
        'userId': user.uid
      });
    }

    return FirebaseFirestore.instance.collection('exams').add({
      'subject': subject,
      'date': newDate,
      'userId': 'invalid'
    });
  }

  Future<void> _signOutAndNavigateToLogin(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => AuthGate()),
            (Route<dynamic> route) => false,
      );
    } catch (e) {
      print('Error during sign out: $e');
      // Handle the error
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Lab3-201083"),
          backgroundColor: Theme
              .of(context)
              .colorScheme
              .inversePrimary,
          actions: [
            ElevatedButton(
              onPressed: () => _addExam(),
              style: const ButtonStyle(
                  backgroundColor:
                  MaterialStatePropertyAll<Color>(Colors.limeAccent)),
              child: const Text(
                "Add exam",
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: () => _signOutAndNavigateToLogin(context),
              style: const ButtonStyle(
                  backgroundColor:
                  MaterialStatePropertyAll<Color>(Colors.limeAccent)),
              child: const Text(
                "Sign out",
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
        stream: _itemsCollection.where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid).snapshots(),
    builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
    return CircularProgressIndicator();
    }

    if (snapshot.hasError) {
    return Text('Error: ${snapshot.error}');
    }

    // If the data is ready, convert it to a list of MyItem
    List<Exam> items = snapshot.data!.docs.map((DocumentSnapshot doc) {
    return Exam.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();

    // Now you have a list of items, you can use it as needed
    return GridView.builder(
    itemCount: items.length,
    itemBuilder: (context, index) {
    return Card(
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Text(items[index].subject, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30),),


    ],
    ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(DateFormat('yyyy-MM-dd HH:mm').format(items[index].date), style: const TextStyle(fontSize: 20, color: Colors.grey),)
        ],
      )
    ],
    ),
    );
    },
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2),
    );
    }));
    }
  }
