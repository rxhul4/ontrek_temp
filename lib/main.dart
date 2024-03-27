import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:ontrek/core/background_service_model/create_route_history_model.dart';
import 'package:ontrek/core/services/api_constants.dart';
import 'package:ontrek/core/services/background_service.dart';
import 'package:ontrek/core/storage/preference_helper.dart';
import 'package:ontrek/core/storage/sql_db_service.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/features/attendance/model/add_activity_model.dart';
import 'package:ontrek/features/attendance/provider/attendance_provider.dart';
import 'package:ontrek/features/authentication/providers/auth_provider.dart';
import 'package:ontrek/features/authentication/screens/splash_screen.dart';
import 'package:ontrek/features/check_out/provider/check_out_form_provider.dart';
import 'package:ontrek/features/dashboard/provider/dashboard_provider.dart';
import 'package:ontrek/features/leads/provider/lead_provider.dart';
import 'package:ontrek/features/salesman_tracker/provider/salesmen_tracking_timeline_provider.dart';
import 'package:ontrek/features/task_list/provider/task_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:path/path.dart' as newPath;
import 'package:sqflite/sqflite.dart';
import 'features/track_function/provider/salesmen_list_provider.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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
  ChangeNotifierProvider<SalemenTimeLineProvider>(
    create: (_) => SalemenTimeLineProvider(),
  ),
  ChangeNotifierProvider<CheckOutProvider>(
    create: (_) => CheckOutProvider(),
  ),
  ChangeNotifierProvider<TaskProvider>(
    create: (_) => TaskProvider(),
  ),
  ChangeNotifierProvider<DashBoardProvider>(
    create: (_) => DashBoardProvider(),
  ),
  ChangeNotifierProvider<LeadProvider>(
    create: (_) => LeadProvider(),
  ),
];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  PreferenceHelper.load().then((value) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    runApp(MultiProvider(providers: providers, child: const MyApp()));
  });
  BackgroundService backgroundService = BackgroundService();
  await backgroundService.initializeService();
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
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
