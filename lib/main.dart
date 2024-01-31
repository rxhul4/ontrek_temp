import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:ontrek/core/storage/preference_helper.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/features/authentication/screens/splash_screen.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  PreferenceHelper.load().then((value) {
    runApp(const MyApp());
  });

}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDeviceInfo();
  }
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  getDeviceInfo() async {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    print('Running on ${androidInfo.model}');
    print('Running on ${androidInfo.product}');
    print('Running on ${androidInfo.version.release}');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project Base',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: AppConstant.btnColor),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
