import 'package:flutter/material.dart';
import 'package:ontrek/core/common_widgets/app_scaffold.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/core/utils/widget_utils.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(

        surfaceTintColor: AppConstant.transparentColor,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
            child: Icon(Icons.arrow_back_ios_new,color: AppConstant.blackColor.withOpacity(0.7),size: 24,)),
        title: WidgetUtils.commonTextWidget(text: "Access Denied",textColor:AppConstant.blackColor.withOpacity(0.7),fontSize: 18 ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.zero,
          child: WidgetUtils.commonContainer(
            decoration: WidgetUtils.commonBoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppConstant.blackColor.withOpacity(0.4),width: 0.3)
              )
            )
            
          ),
        ),

      ),
        body:Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(child: Image.network("https://cdni.iconscout.com/illustration/premium/thumb/access-denied-7345129-5913495.png",width: 200,height: 150,)),
            WidgetUtils.commonTextWidget(text: "The permission to create task has been\nrestricted, please contact your admin!",textColor: AppConstant.greyColor.withOpacity(0.9),fontSize: 12,textAlign: TextAlign.center,letterSpacing: 0,)
          ],
        )
    );
  }
}
