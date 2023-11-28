import 'dart:io';
import 'package:chat_app/widges/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();

  var _isLogin = true;
  var _enteredEmail = '';
  var _enteredPassword = '';
  var _enteredUsername = '';
  File? _selectedImage;
  var _isAuthenticating = false;

  void _submit() async{
    final isValid = _form.currentState!.validate();

    if(!isValid || ! _isLogin && _selectedImage == null ){
      // show error massage...
      return;
    }

      _form.currentState!.save();
     try{
       setState(() {
         _isAuthenticating = true;
       });
      if(_isLogin){
      final userCrendentials = await _firebase.signInWithEmailAndPassword(
          email: _enteredEmail, password: _enteredPassword);

     } else{
      final userCredentials = await _firebase.createUserWithEmailAndPassword(
          email: _enteredEmail, password: _enteredPassword);

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('user_images')
          .child('${userCredentials.user!.uid}.jpg');

      await storageRef.putFile(_selectedImage!);
      final imageUrl = await storageRef.getDownloadURL();


      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredentials.user!.uid).set({
        'username': _enteredUsername,
        'email': _enteredEmail,
        'image_url': imageUrl,
      });


     }
      } on FirebaseAuthException catch (error){
       if(error.code == 'email-already-in-use' ){
         //... Burada hata kodunda özel işlemi yapmadık.
       }
       ScaffoldMessenger.of(context).clearSnackBars();
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
         content: Text(error.message ?? 'Authentication failed.'),
         ),
       );
       setState(() {
         _isAuthenticating = false;
       });
     }
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: 125,
                  bottom: 20,
                  right: 20,
                  left: 20,
                ),
                width: 200,
                child: Image.asset('lib/assets/images/chat.png'),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _form,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if(!_isLogin) USerImagePicker(
                            onPickImage:(pickedImage){
                              _selectedImage = pickedImage;
                            },
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                                labelText: 'Email Address'
                            ),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,                    // Otomatik düzeltmeyi kapattık, kullanıcılar sorun yaşamaması için,
                            textCapitalization: TextCapitalization.none, // Email adresinin ilk karakteri büyük harfle yazılmaması için kapattık,
                            validator: (value) {
                              if(value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@')){
                                return 'Please enter a volid email address.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enteredEmail = value!;
                            },
                          ),
                          if(!_isLogin)
                          TextFormField(
                            decoration: InputDecoration(labelText: 'UserName'),
                            enableSuggestions: false,
                            validator: (value){
                              if( value == null ||value.isEmpty || value.trim().length < 4) {
                                return 'Please enter a volid username (at least 4 characters).';
                              }
                              return null;
                            },
                            onSaved: (value){
                              _enteredUsername = value!;

                            },
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                                labelText: 'Password'),
                            obscureText: true,
                            validator: (value) {
                              if(value == null ||
                                  value.trim().length < 6 ){
                                return 'Password must be at  least 6 characters long';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enteredPassword = value!;
                            },
                          ),
                          const SizedBox(height: 12),
                          if(_isAuthenticating)
                            const CircularProgressIndicator(),
                          if(!_isAuthenticating)
                          ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                            ),
                            child:  Text(_isLogin ? 'Login' : 'Singup'),
                          ),
                          if(!_isAuthenticating)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLogin = !_isLogin;  // Ünlem işareti temel olarak tersini kontrol eder
                              });
                            },
                            child:  Text( _isLogin ? 'Create an account' : 'I already have an account.'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
}
