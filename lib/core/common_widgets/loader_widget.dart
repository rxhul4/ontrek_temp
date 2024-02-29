import 'package:flutter/material.dart';

class LoaderWidget extends StatefulWidget {
  Color? color;
   LoaderWidget({super.key,required this.color});

  @override
  State<LoaderWidget> createState() => _LoaderWidgetState();
}

class _LoaderWidgetState extends State<LoaderWidget> with SingleTickerProviderStateMixin{

  @override
  Widget build(BuildContext context) {
    // return LoadingAnimationWidget.threeArchedCircle(color: widget.color ?? Colors.red, size: 100);
    return Positioned.fill(
      // scale: isFromLogOutButton ? 4 : 3.6,
      // Adjust the scale factor as needed
      child: CircularProgressIndicator(
        // value: controller?.value,
        strokeCap: StrokeCap.round,
        color: widget.color,
        strokeWidth: 8,
        // valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
      ),
    );
  }
}
