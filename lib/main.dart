import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:ontrek/core/storage/preference_helper.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/features/attendance/provider/attendance_provider.dart';
import 'package:ontrek/features/authentication/providers/auth_provider.dart';
import 'package:ontrek/features/authentication/screens/splash_screen.dart';
import 'package:ontrek/features/salesman_tracker/provider/salesmen_tracking_timeline_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'features/track_function/provider/salesmen_list_provider.dart';

List<SingleChildWidget> providers = [

  ChangeNotifierProvider<AttendanceProvider>(
    create: (_) => AttendanceProvider(),
  ),
  ChangeNotifierProvider<AuthenticationProvider>(
    create: (_) => AuthenticationProvider(),
  ),
  ChangeNotifierProvider<SalesMenListProvider>(
    create: (_) => SalesMenListProvider(),
  ),
  ChangeNotifierProvider<SaleMenTackingTimeLineProvider>(
    create: (_) => SaleMenTackingTimeLineProvider(),
  ),
];

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  PreferenceHelper.load().then((value) {
    runApp(MultiProvider(providers: providers, child: const MyApp()));
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
    print('Running on ${androidInfo.id}');
    print('Running on model ${androidInfo.model}');
    print('Running on product ${androidInfo.product}');
    print('Running on id ${androidInfo.id}');
    print('Running on device ${androidInfo.device}');
    print('Running on brand ${androidInfo.brand}');
    print('Running on manufacturer ${androidInfo.manufacturer}');
    print('Running on serialNumber ${androidInfo.serialNumber}');
    print('Running on baseOS ${androidInfo.version.baseOS}');
    print('Running on codename ${androidInfo.version.codename}');
    print('Running on sdkInt ${androidInfo.version.sdkInt}');
    print('Running on release ${androidInfo.version.release}');
    print('Running on securityPatch ${androidInfo.version.securityPatch}');
    print('Running on previewSdkInt ${androidInfo.version.previewSdkInt}');
    print('Running on incremental ${androidInfo.version.incremental}');
    print('Running on version ${Platform.operatingSystem}');
    print('Running on version ${Platform.operatingSystemVersion}');
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
      home: const SplashScreen(),
    );
  }
}
