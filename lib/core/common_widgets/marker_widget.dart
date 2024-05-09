import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ontrek/core/utils/app_constant.dart';

class CustomMarkerWidget extends StatelessWidget {
  final String? imageUrl;

  const CustomMarkerWidget({Key? key, this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      width: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Icon(Icons.arrow_drop_down_sharp, color: AppConstant.appPrimaryColor),
          ),
          Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(width: 2, color: AppConstant.appPrimaryColor),
              color: Colors.white,
            ),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: imageUrl ?? "",
                placeholder: (context, url) => Center(child:Icon(Icons.person, size: 24, color: AppConstant.appPrimaryColor)),
                errorWidget: (context, url, error) => Icon(Icons.person, size: 24, color: AppConstant.appPrimaryColor),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
