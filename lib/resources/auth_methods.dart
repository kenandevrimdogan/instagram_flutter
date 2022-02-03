import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import "package:firebase_auth/firebase_auth.dart";
import 'package:instagram_flutter/resources/storage_methods.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // sign up user
  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    required String bio,
    required Uint8List file,
  }) async{
      String res = "Some error occurred";

      try{
        if(email.isNotEmpty || password.isNotEmpty || username.isNotEmpty || bio.isNotEmpty || file != null){
          // register user
         UserCredential cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);

        String photoUrl = await StorageMethods().uploadImageToStorage('profilePics', file, false);

         _firestore.collection('users').doc(cred.user!.uid).set({
           'userName': username,
           'uid': cred.user!.uid,
           'email': email,
           'bio': bio,
           'followers': [],
           'following': [],
           'photoUrl' : photoUrl
         });

        // 
        // await _firestore.collection('users').add({
        //    'userName': username,
        //    'uid': cred.user!.uid,
        //    'email': email,
        //    'bio': bio,
        //    'followers': [],
        //    'following': []
        // });

         res = "success";
        }
      } catch(err){
        res = err.toString();
      } on FirebaseAuthException catch(err) {
        if(err.code == 'invalid-email'){
          res = 'The email is badly formatted.';
        } else if(err.code == 'weak-password'){
          res = 'Password should be at least 6 charcters.';
        }
      }

      return res;
  }

  // Logging in User
  Future<String> LoginUser({
    required String email,
    required String password
  }) async{
    String res = "Some error occurred";

    try{
      if(email.isNotEmpty || password.isNotEmpty){
         await _auth.signInWithEmailAndPassword(email: email, password: password);
         res = "success";
      }else {
        res = "Please enter all the fields";
      }
    } 
    catch(err) {
      res = err.toString();
    }

    return res;
  }
}