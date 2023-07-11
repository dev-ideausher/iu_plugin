import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:stacked_firebase_auth/stacked_firebase_auth.dart';
import 'storage.dart';
import 'dart:developer';
import 'dialog_helper.dart';


class Auth extends GetxService {
  final auth = FirebaseAuthenticationService();
  final _facebookLogin = FacebookAuth.instance;
  AuthCredential? _pendingCredential;
  final _firebaseAuth = FirebaseAuth.instance;

  google() async {
    //TODO: do the required setup mentioned in https://pub.dev/packages/google_sign_in
    final result = await auth.signInWithGoogle().then((value) async {
      await handleGetContact();
    });

    print('Google : ${await result.user?.getIdToken()}');
  }

  apple() async {
    //TODO: do the required setup mentioned in https://pub.dev/packages/sign_in_with_apple
    final result = await auth
        .signInWithApple(
            //TODO: add your own handler id from firebase console
            appleRedirectUri:
                'https://stacked-firebase-auth-test.firebaseapp.com/__/auth/handler',
            appleClientId: '')
        .then((value) async {
      await handleGetContact();
    });
    print('Apple : ${await result.user?.getIdToken()}');
  }

  loginEmailPass({required String email, required String pass}) async {
    final result = await auth
        .loginWithEmail(email: email, password: pass)
        .then((value) async {
      await handleGetContact();
    });
    print('EmailPass : ${await result.user?.getIdToken()}');
  }

  createEmailPass({required String email, required String pass}) async {
    final result = await auth
        .createAccountWithEmail(email: email, password: pass)
        .then((value) async {
      await handleGetContact();
    });
    print('EmailPass : ${await result.user?.getIdToken()}');
  }

//phone number with country code
  mobileOtp({required String phoneno}) async {
    await auth.requestVerificationCode(
      phoneNumber: phoneno,
      onCodeSent: (verificationId) => print(verificationId),
    );
  }

  verifyMobileOtp({required String otp}) async {
    final result = await auth.authenticateWithOtp(otp).then((value) async {
      await handleGetContact();
    });
    print('Mobile Otp : ${await result.user?.getIdToken()}');
  }

  facebook() async {
    //TODO: do the required setup mentioned in https://pub.dev/packages/flutter_facebook_auth
    final result = await signInWithFacebook().then((value) async {
      await handleGetContact();
    });
    print('Facebook : ${await result.user?.getIdToken()}');
  }

  Future<FirebaseAuthenticationResult> signInWithFacebook() async {
    try {
      LoginResult fbLogin = await _facebookLogin.login();
      // log?.v('Facebook Sign In complete. \naccessToken:${accessToken.token}');

      final OAuthCredential facebookCredentials =
          FacebookAuthProvider.credential(fbLogin.accessToken!.token);

      var result =
          await _firebaseAuth.signInWithCredential(facebookCredentials);

      // Link the pending credential with the existing account
      if (_pendingCredential != null) {
        await result.user?.linkWithCredential(_pendingCredential!);
      }

      return FirebaseAuthenticationResult(user: result.user);
    } catch (e) {
      // log?.e(e);
      return FirebaseAuthenticationResult.error(errorMessage: e.toString());
    }
  }

  Future<void> handleGetContact() async {
    final mytoken = await _firebaseAuth.currentUser!.getIdToken(true);
    final fireUid = _firebaseAuth.currentUser!.uid;

    Get.find<GetStorageService>().encjwToken = mytoken;
    Get.find<GetStorageService>().setFirebaseUid = fireUid;
    log(Get.find<GetStorageService>().getEncjwToken);
    debugPrint('i am user id${Get.find<GetStorageService>().getFirebaseUid}');
  }
  
    Future<void> logOutUser() async {
    DialogHelper.showLoading();
    // erase the user's token and data in GetStorageService
    Get.find<GetStorageService>().logout();
    // firbase logout
    auth.logout();
    // navigate to login page
    // await Get.offAllNamed(Routes.LOGIN);
    await DialogHelper.hideDialog();
  }
}
