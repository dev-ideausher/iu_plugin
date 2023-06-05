import 'dart:async';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/instance_manager.dart';
import '../../routes/app_pages.dart';
import '../dialog_helper.dart';
import '../snackbar.dart';
import '../storage.dart';
import 'exceptions.dart';
import 'jwt_decoder.dart';

class AppInterceptors extends Interceptor {
  bool isOverlayLoader;
  bool showSnakbar;

  AppInterceptors({this.isOverlayLoader = true, this.showSnakbar = true});

  @override
  FutureOr<dynamic> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    isOverlayLoader ? DialogHelper.showLoading() : null;
    await Helpers.validateToken(
      onSuccess: () {
        options.headers = {
          "token": Get.find<GetStorageService>().getEncjwToken
        };
        super.onRequest(options, handler);
      },
    );
  }

  @override
  FutureOr<dynamic> onResponse(
      Response response, ResponseInterceptorHandler handler) {
    super.onResponse(response, handler);
    isOverlayLoader ? DialogHelper.hideDialog() : null;
  }

  @override
  Future<dynamic> onError(DioError err, ErrorInterceptorHandler handler) async {
    super.onError(err, handler);

    try {
      final errorMessage = DioExceptions.fromDioError(err).toString();
      isOverlayLoader ? DialogHelper.hideDialog() : null;
      showSnakbar == true
          ? showMySnackbar(msg: errorMessage, title: 'Error')
          : null;
    } catch (e) {
      debugPrint(e.toString());
    }

    // try {
    //   print('${err.response?.statusCode}\n${err.response!.data['message']}');
    //   if (err.response?.statusCode == 500 &&
    //       err.response!.data['message'] ==
    //           'Firebase ID token has expired. Get a fresh ID token from your client app and try again (auth/id-token-expired). See https://firebase.google.com/docs/auth/admin/verify-id-tokens for details on how to retrieve an ID token.') {
    //     if (await refreshToken()) {
    //       return handler.resolve(await retry(err.requestOptions));
    //     }
    //   }
    // } catch (e) {
    //   debugPrint(e.toString());
    // }

    return handler.next;
  }

  Future<Response<dynamic>> retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    return Dio().request<dynamic>(requestOptions.path,
        data: requestOptions.data,
        queryParameters: requestOptions.queryParameters,
        options: options);
  }

  // Future<bool> refreshToken() async {
  //   try {
  //     Get.find<GetStorageService>().setEncjwToken =
  //         (await FirebaseAuth.instance.currentUser?.getIdToken(true))!;
  //     print('hello from app_interceptor : ${true}');
  //     return true;
  //   } catch (e) {
  //     print('hello from app_interceptor : ${false}');

  //     return false;
  //   }
  // }
}

class Helpers {
  static bool _tokenIsValid() {
    return Get.find<GetStorageService>().getEncjwToken.isNotEmpty
        ? JwtDecoder.isValid(Get.find<GetStorageService>().getEncjwToken)
        : false;
  }

  static Future<bool> validateToken({required Function() onSuccess}) async {
    if (_tokenIsValid()) {
      onSuccess();
      return true;
    } else {
      try {
        Get.find<GetStorageService>().setEncjwToken =
            (await FirebaseAuth.instance.currentUser?.getIdToken(true))!;
        onSuccess();
        return true;
      } catch (e) {
        showMySnackbar(
            msg: "Session Expired. Please Login Again", title: 'Error');
        Get.find<GetStorageService>().logout();
        Get.offAllNamed(Routes.SPLASH);
        return false;
      }
    }
  }
}
