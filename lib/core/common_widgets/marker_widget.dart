import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';

class CustomMarkerWidget extends StatefulWidget {
  String? imageUrl;


  CustomMarkerWidget({super.key, this.imageUrl});

  @override
  State<CustomMarkerWidget> createState() => _CustomMarkerWidgetState();
}

class _CustomMarkerWidgetState extends State<CustomMarkerWidget> {
  String? image;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(!mounted){}
    print("imageUrlllllll${widget.imageUrl}");
    setState(() {
      image = widget.imageUrl;
    });
  }

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
                imageUrl: image ?? "",
                imageBuilder: (context, imageProvider) => Container(
                  margin: EdgeInsets.zero,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: imageProvider, fit: BoxFit.cover),
                  ),
                ),
                placeholder: (context, url) => Icon(Icons.person, size: 24, color: AppConstant.appPrimaryColor),
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
