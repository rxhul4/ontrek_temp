// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:ontrek/core/utils/app_constant.dart';

class AppTextField extends StatelessWidget {
  String? labelText;
  double? allBorderRadius;
  double? labelFontSize;
  double? hintFontSize;
  double? inputTextFontSize;
  Color? labelTextColor;
  Color? hintTextColor;
  Color? focusedBorderColor;
  Color? enabledBorderColor;
  Color? cursorColor;
  Color? inputTextColor;
  TextInputType? textInputType;
  String? fontFamily;
  String? labelFontFamily;
  String? hintFontFamily;
  TextEditingController? controller;
  Function(String)? onChanged;
  Function(PointerDownEvent)? onTapOutside;
  VoidCallback? onTap;
  VoidCallback? onEditingComplete;
  String? hintText;
  double? letterSpacing;
  Color? fillColor;
  Widget? prefixIcon;
  Widget? suffixIcon;
  Color? suffixColor;

  AppTextField(
      {Key? key,
        this.labelText,
        this.allBorderRadius,
        this.focusedBorderColor,
        this.enabledBorderColor,
        this.inputTextFontSize,
        this.labelFontFamily,
        this.textInputType,
        this.controller,
        this.hintText,
        this.cursorColor,
        this.inputTextColor,
        this.fontFamily,
        this.onEditingComplete,
        this.onChanged,
        this.hintFontFamily,
        this.hintFontSize,
        this.letterSpacing,
        this.hintTextColor,
        this.labelFontSize,
        this.fillColor,
        this.onTap,
        this.onTapOutside,
        this.labelTextColor,
        this.prefixIcon,
        this.suffixIcon,
        this.suffixColor,
      })
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  TextField(
      onChanged: onChanged,
      controller: controller,
      onTap: onTap,

      onEditingComplete: onEditingComplete,
      onTapOutside: onTapOutside,
      style: TextStyle(
        letterSpacing: letterSpacing,
        color: inputTextColor ?? AppConstant.blackColor,
        fontSize: inputTextFontSize ?? 14,
        fontWeight: FontWeight.w500,
        fontFamily:fontFamily,
      ),
      keyboardType: textInputType ?? TextInputType.text,
      cursorColor:  cursorColor ?? AppConstant.primaryColor,
      decoration: InputDecoration(
        prefixIcon: prefixIcon ?? Icon(Icons.search),
        prefixIconColor: Colors.black,
        suffixIcon: suffixIcon,
        suffixIconColor: suffixColor,
        contentPadding: EdgeInsets.only(left: 10,right: 10),
        alignLabelWithHint: true,
        labelText: labelText,
        hintText: hintText ,
        hintStyle: TextStyle(color: hintTextColor ?? AppConstant.greyColor, fontSize: hintFontSize ?? 14,fontFamily: hintFontFamily),
        labelStyle: TextStyle(color: labelTextColor ?? AppConstant.greyColor, fontSize: labelFontSize ?? 14,fontFamily: labelFontFamily),
        filled: true,
        fillColor: fillColor ?? AppConstant.textFieldBgColor,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(allBorderRadius ?? 5)),
          borderSide: BorderSide(width: 1.5, color: focusedBorderColor ?? AppConstant.greyColor.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(allBorderRadius  ?? 5)),
          borderSide: BorderSide(width: 01, color: enabledBorderColor ?? AppConstant.greyColor.withOpacity(0.3)),
        ),
      ),
    );
  }
}