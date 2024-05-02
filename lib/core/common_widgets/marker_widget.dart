import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';

class CustomMarkerWidget extends StatefulWidget {
  String? imageUrl;

  CustomMarkerWidget({super.key, this.imageUrl});

  @override
  State<CustomMarkerWidget> createState() => _CustomMarkerWidgetState();
}

class _CustomMarkerWidgetState extends State<CustomMarkerWidget> {
  @override
  Widget build(BuildContext context) {
    return AppUtils.commonSizedBox(
      height: 100,
      width: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Icon(Icons.arrow_drop_down_sharp,color: AppConstant.appPrimaryColor),
          ),
          AppUtils.commonContainer(
            height: 70,
            width: 70,
            // padding: AppUtils.edgeInsetsAll(allPadding: 15),
            margin: EdgeInsets.zero,
            decoration: AppUtils.commonBoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    width: 2, color: AppConstant.appPrimaryColor),
                color: Colors.white),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: widget.imageUrl ?? "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                imageBuilder: (context, imageProvider) => Container(
                  margin: EdgeInsets.zero,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: imageProvider, fit: BoxFit.cover),
                  ),
                ),
                placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(
                  color: AppConstant.appPrimaryColor,
                  strokeWidth: 0.5,
                )),
                errorWidget: (context, url, error) =>
                    Icon(Icons.person, size: 24, color: AppConstant.appPrimaryColor),
              ),
            ),
          ),

        ],
      ),
    );
  }
}
