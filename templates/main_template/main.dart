import 'app/modules/home/bindings/home_binding.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
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

  return runApp(GetMaterialApp(
    defaultTransition: Transition.fade,
    smartManagement: SmartManagement.full,
    debugShowCheckedModeBanner: false,
    title: "Ticket Checker",
    initialRoute: AppPages.INITIAL,
    initialBinding: HomeBinding(),
    getPages: AppPages.routes,
  ));
}

Future<void> initGetServices() async {
  await Get.putAsync<GetStorageService>(() => GetStorageService().initState());
}
