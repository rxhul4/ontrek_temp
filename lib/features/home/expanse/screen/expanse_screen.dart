import 'package:flutter/material.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';

class ExpanseScreen extends StatefulWidget {
  const ExpanseScreen({super.key});

  @override
  State<ExpanseScreen> createState() => _ExpanseScreenState();
}

class _ExpanseScreenState extends State<ExpanseScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstant.whiteColor,
      appBar: AppUtils.commonAppBar(context: context,isBack: true,isBorder: true,title: "Expanses",isCenter: true),
    );
  }
}
