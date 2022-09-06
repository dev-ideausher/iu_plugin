import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import 'app/modules/splash/bindings/splash_binding.dart';
import 'app/routes/app_pages.dart';
import 'app/services/storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initGetServices();
  SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
    ],
  );

  return runApp(

        return GetMaterialApp(
          defaultTransition: Transition.fade,
          smartManagement: SmartManagement.full,
          debugShowCheckedModeBanner: false,
          title: "Ticket Checker",
          initialRoute: AppPages.INITIAL,
          initialBinding: SplashBinding(),
          getPages: AppPages.routes,
        );
    
  );
}

Future<void> initGetServices() async {
  await Get.putAsync<GetStorageService>(() => GetStorageService().initState());
}
