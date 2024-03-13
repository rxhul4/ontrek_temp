import 'package:flutter/cupertino.dart';
import 'package:ontrek/core/common_widgets/app_scaffold.dart';
import 'package:ontrek/core/utils/App_utils.dart';

class AddLeadScreen extends StatefulWidget {
  const AddLeadScreen({super.key});

  @override
  State<AddLeadScreen> createState() => _AddLeadScreenState();
}

class _AddLeadScreenState extends State<AddLeadScreen> {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppUtils.commonAppBar(context: context,title:  "Add Lead",),
      body: SingleChildScrollView(
        child: Column(
        children: [

        ],
        ),
      ),
    );
  }
}
