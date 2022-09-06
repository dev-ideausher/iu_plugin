import 'dart:async';
import 'package:dio/dio.dart';
import 'package:get/instance_manager.dart';
import '../dialog_helper.dart';
import '../snackbar.dart';
import '../storage.dart';
import 'exceptions.dart';

class AppInterceptors extends Interceptor {
  bool isOverlayLoader;
  bool showSnakbar;

  AppInterceptors({this.isOverlayLoader = true, this.showSnakbar = true});

  @override
  FutureOr<dynamic> onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers = {"token": Get.find<GetStorageService>().encjwToken};
    isOverlayLoader ? DialogHelper.showLoading() : null;
    super.onRequest(options, handler);
  }

  @override
  FutureOr<dynamic> onResponse(Response response, ResponseInterceptorHandler handler) {
    // TODO: implement onResponse
    super.onResponse(response, handler);
    isOverlayLoader ? DialogHelper.hideDialog() : null;
  }

  @override
  Future<dynamic> onError(DioError dioError, ErrorInterceptorHandler handler) async {
    // TODO: implement onError
    super.onError(dioError, handler);

    try {
      final errorMessage = DioExceptions.fromDioError(dioError).toString();
      isOverlayLoader ? DialogHelper.hideDialog() : null;
      showSnakbar == true ? showMySnackbar(msg: errorMessage,title: 'Error') : null;
    } catch (e) {
      print(e);
    }

    /* if ((dioError.response?.statusCode == 401 && dioError.response?.data['message'] == "invalid token")) {
      if (await refreshToken()) {
        return handler.resolve(await retry(dioError.requestOptions));
      }
    }*/
    try {
      if (dioError.response!.data['message'] ==
          "Firebase ID token has expired. Get a fresh ID token from your client app and try again (auth/id-token-expired). See https://firebase.google.com/docs/auth/admin/verify-id-tokens for details on how to retrieve an ID token.") {
            ///TODO:if refreshToken() method is used
        // if (await refreshToken()) {
        //   return handler.resolve(await retry(dioError.requestOptions));
        // }
      }
    } catch (e) {
      print(e);
    }

    return handler.next;
  }

  Future<Response<dynamic>> retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    return Dio().request<dynamic>(requestOptions.path, data: requestOptions.data, queryParameters: requestOptions.queryParameters, options: options);
  }
///TODO:if firebase is needed
  // Future<bool> refreshToken() async {
  //   try {
  //     Get.find<GetStorageService>().token = (await FirebaseAuth.instance.currentUser?.getIdToken(true))!;
  //     print(Get.find<GetStorageService>().token);
  //     return true;
  //   } catch (e) {
  //     Get.find<MorePageController>().userLogout();
  //     return false;
  //   }

  //   /*  final response = await Dio().post('/auth/refresh', data: {'refreshToken': "refreshToken"});
  //   if (response.statusCode == 201) {
  //     var accessToken = response.data;
  //     return true;
  //   } else {
  //     // refresh token is wrong
  //     print("Logout");
  //     return false;
  //   }*/
  // }
}
