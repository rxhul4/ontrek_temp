import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/core/utils/widget_utils.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  LocalAuthentication _localAuthentication = LocalAuthentication();
  bool isBiometricAvailable = false;
  Color emailFillColor = AppConstant.textFieldBgColor;
  Color passFillColor = AppConstant.textFieldBgColor;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkBiometricAvailable();
  }

  checkBiometricAvailable() async {
    isBiometricAvailable = await _localAuthentication.canCheckBiometrics;
    if (kDebugMode) {
      print("isBiometricAvailable $isBiometricAvailable");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: authBtnWidget()),
    );
  }

  Widget authBtnWidget() {
    return Center(
      child: WidgetUtils.commonElevatedBtn(
          bgColor: AppConstant.greyColor,
          onPressed: () async {
            if (isBiometricAvailable) {
              bool isAuthenticated = await _localAuthentication.authenticate(
                  localizedReason: "Authenticate using Biometrics",
                  options: const AuthenticationOptions(
                      stickyAuth: true, useErrorDialogs: true));
              if (isAuthenticated) {
                if (kDebugMode) {
                  print("isAuthenticated $isAuthenticated");
                }

                openDialogFnc("Authentication Successful");
              } else {
                if (kDebugMode) {
                  print("isAuthenticated $isAuthenticated");
                }
                openDialogFnc("Authentication Fail! Please Try Again");
              }
            } else {
              if (kDebugMode) {
                print("Biometric Auth is not available on this device");
              }
              showDialog(
                context: context,
                builder: (context) => showDialogBox(
                    "Biometric Auth is not available on this device"),
              );
            }
          },
          text: "Biometric Auth"),
    );
  }

  openDialogFnc(String text) {
    showDialog(
      context: context,
      builder: (context) => showDialogBox(text),
    );
  }

  AlertDialog showDialogBox(String text) {
    return AlertDialog(
      insetPadding: const EdgeInsets.all(0),
      titlePadding: const EdgeInsets.all(0),
      contentPadding: const EdgeInsets.only(top: 20, bottom: 10, left: 10, right: 10),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(text, textAlign: TextAlign.center),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Okay")),
          ],
        )
      ]),
    );
  }
}
