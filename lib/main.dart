import 'dart:io';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ontrek/core/services/background_service.dart';
import 'package:ontrek/core/services/background_service_ios.dart';
import 'package:ontrek/core/services/local_notification.dart';
import 'package:ontrek/core/storage/preference_helper.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/features/add_lead/provider/add_lead_provider.dart';
import 'package:ontrek/features/attendance/provider/attendance_provider.dart';
import 'package:ontrek/features/authentication/providers/auth_provider.dart';
import 'package:ontrek/features/authentication/screens/otp_verification%20screen.dart';
import 'package:ontrek/features/authentication/screens/splash_screen.dart';
import 'package:ontrek/features/check_out/provider/check_out_form_provider.dart';
import 'package:ontrek/features/dashboard/provider/dashboard_provider.dart';
import 'package:ontrek/features/home/day_end_request_approval/provider/day_end_request_provider.dart';
import 'package:ontrek/features/home/expanse/provider/expense_provider.dart';
import 'package:ontrek/features/home/holidays/provider/holiday_provider.dart';
import 'package:ontrek/features/home/leave/provider/leave_provider.dart';
import 'package:ontrek/features/home/reports/provider/report_provider.dart';
import 'package:ontrek/features/leads/provider/lead_provider.dart';
import 'package:ontrek/features/permissions/permission_request_screen.dart';
import 'package:ontrek/features/salesman_tracker/provider/salesmen_tracking_timeline_provider.dart';
import 'package:ontrek/features/task_list/provider/task_provider.dart';

import 'package:ontrek/features/view_task/provider/view_task_provider.dart';
import 'package:ontrek/firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
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
  ChangeNotifierProvider<ViewTaskProvider>(
    create: (_) => ViewTaskProvider(),
  ),
  ChangeNotifierProvider<AddLeadProvider>(
    create: (_) => AddLeadProvider(),
  ),
  ChangeNotifierProvider<ReportProvider>(
    create: (_) => ReportProvider(),
  ),
  ChangeNotifierProvider<DayEndRequestProvider>(
    create: (_) => DayEndRequestProvider(),
  ),
  ChangeNotifierProvider<HolidayProvider>(
    create: (_) => HolidayProvider(),
  ),
  ChangeNotifierProvider<LeaveProvider>(
    create: (_) => LeaveProvider(),
  ),
  ChangeNotifierProvider<ExpenseProvider>(
    create: (_) => ExpenseProvider(),
  ),
];
GlobalKey globalKey = GlobalKey();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (Platform.isAndroid) {
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  PreferenceHelper.load().then((value) async {
    String? userId = PreferenceHelper.getString(PreferenceHelper.USER_ID);
    String? userName = PreferenceHelper.getString(PreferenceHelper.USER_NAME);
    if ((userId != null || userId != "") &&
        (userName != null || userName != "")) {
      await setCrashlyticsUserAndDeviceInfo(userId ?? "", userName ?? "");
    }

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    runApp(MultiProvider(providers: providers, child: const MyApp()));
  });
  BackgroundService backgroundService = BackgroundService();

  NotificationService notificationService = NotificationService();
  await notificationService.initNotification();

  if (Platform.isAndroid) {
    await backgroundService.initializeService();
  } else {
    // BackgroundServiceIos backgroundServiceIos = BackgroundServiceIos();
    // await backgroundServiceIos.initialize();
  }
}

Future<void> setCrashlyticsUserAndDeviceInfo(
    String userId, String userName) async {
  var deviceInfo = DeviceInfoPlugin();

  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    FirebaseCrashlytics.instance.setCustomKey("user_id", userId);
    FirebaseCrashlytics.instance.setCustomKey("user_name", userName);
    FirebaseCrashlytics.instance.setCustomKey("platform", 'Android');
    FirebaseCrashlytics.instance
        .setCustomKey("android_version", androidInfo.version.release);
    FirebaseCrashlytics.instance.setCustomKey("model", androidInfo.model);
    FirebaseCrashlytics.instance.setCustomKey("deviceId", androidInfo.id);
  } else {
    IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
    FirebaseCrashlytics.instance.setCustomKey("user_id", userId);
    FirebaseCrashlytics.instance.setCustomKey("user_name", userName);
    FirebaseCrashlytics.instance.setCustomKey("platform", 'Ios');
    FirebaseCrashlytics.instance
        .setCustomKey("android_version", iosDeviceInfo.systemVersion);
    FirebaseCrashlytics.instance.setCustomKey("model", iosDeviceInfo.model);
    FirebaseCrashlytics.instance
        .setCustomKey("deviceId", iosDeviceInfo.identifierForVendor.toString());
  }
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
      title: 'On Trek',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppConstant.btnColor),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
