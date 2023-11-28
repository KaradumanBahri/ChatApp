import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NewMassage extends StatefulWidget {
  const NewMassage({super.key});

  @override
  State<NewMassage> createState() => _NewMassageState();
}

class _NewMassageState extends State<NewMassage> {
  final _massageController = TextEditingController();

  @override
  void dispose() {
    _massageController.dispose();
    super.dispose();
  }

  void _submitMassage() async {
    final enteredMassage = _massageController.text;

    if(enteredMassage.trim().isEmpty){
      return;
    }
    FocusScope.of(context).unfocus(); // odağı giriş alanından kaldırarak açık klavyeyi kapatacak
    _massageController.clear();

    final user = FirebaseAuth.instance.currentUser!;
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    FirebaseFirestore.instance.collection('chat').add({
      'text': enteredMassage,
      'createdAt': Timestamp.now(),
      'userId': user.uid,
      'username': userData.data()!['username'],
      'userImage': userData.data()!['image_url'],
    });
   }

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.only(left: 15,right: 1,bottom: 14),
      child: Row(
        children: [
           Expanded(
              child: TextField(
                controller: _massageController,
                textCapitalization: TextCapitalization.sentences,
                autocorrect: true,
                enableSuggestions: true,
                decoration: const InputDecoration(labelText: 'Send a massage..'),
              ),
          ),
          IconButton(
            color: Theme.of(context).colorScheme.primary,
            icon: const Icon(Icons.send),
            onPressed: _submitMassage,
          )
        ],
      ),
    );
  }
}
