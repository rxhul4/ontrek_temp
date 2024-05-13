import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:ontrek/core/services/api_constants.dart';
import 'package:ontrek/core/services/network_repository.dart';
import 'package:ontrek/core/storage/preference_helper.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/features/leads/model/lead_model.dart';
import 'package:ontrek/features/leads/view_lead/model/lead_by_id_model.dart';
import 'package:ontrek/main.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class LeadProvider extends ChangeNotifier {
  bool _isFetching = false;
  bool _isLoading = false;
  bool _isUploading = false;
  bool _isAdding = false;

  bool get isFetching => _isFetching;

  bool get isLoading => _isLoading;

  bool get isUploading => _isUploading;

  bool get isAdding => _isAdding;

  GetAllLeadModel? getAllLeadModel;
  GetLeadByIdModel? getLeadByIdModel;

  //variables
  bool? isSearchVisible = false;
  PanelController panelController = PanelController();
  TextEditingController searchController = TextEditingController();

  loaderFnc(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  fetchingFnc(bool isLoading) {
    _isFetching = isLoading;
    notifyListeners();
  }

  refreshFnc(bool isRefresh) {
    _isLoading = isRefresh;
    notifyListeners();
  }

  void navigatePushReplacementFnc(Widget screen) {
    navigatorKey.currentState!.pushReplacement(CupertinoPageRoute(
      builder: (context) => screen,
    ));
  }

  void navigatePushFnc(Widget screen) {
    navigatorKey.currentState!.push(CupertinoPageRoute(
      builder: (context) => screen,
    ));
  }

  refresh() async {
    String? orgId = PreferenceHelper.getString(PreferenceHelper.ORG_ID);
   await  apiCallGetAllLead(orgId: orgId);
  }

  showAndHideSearchWidget(bool isSearchVisibleFromView) {
    isSearchVisible = isSearchVisibleFromView;
    notifyListeners();
  }

  Future<GetAllLeadModel?> apiCallGetAllLead({String? orgId,String? filter}) async {
    var orgId = PreferenceHelper.getString(PreferenceHelper.ORG_ID);
    var userId = PreferenceHelper.getString(PreferenceHelper.USER_ID);
    _isFetching = true;
    notifyListeners();
    Map<String, dynamic> body = {
      "userId": userId,
      "leadDate": AppUtils.getDate(date: DateTime.now().toString(), format: AppConstant.dateFormat),
      "fillter": searchController.text,
      "orgId": orgId
    };
    try {
      String endPoint = ApiConstants.getLeadList;
      var response = await callPostMethod(endPoint, body);
      getAllLeadModel = GetAllLeadModel.fromJson(json.decode(response));
      print('response ${getAllLeadModel?.toJson()}');
      if(getAllLeadModel?.isError == false && getLeadByIdModel?.isValidationFailed == false){

      }else{
        if(getAllLeadModel?.isError == true){
          AppUtils.showDialogBoxWithOneButton(
              context: navigatorKey.currentState!.context,
              text: "Something went wrong, Please try again later!");
        }
        if( getAllLeadModel?.isValidationFailed == true){
          AppUtils.showDialogBoxWithOneButton(
              titleText: "Validation Error",
              context: navigatorKey.currentState!.context,
              text: getAllLeadModel?.message ?? "");
        }
      }
    } catch (e) {
      print('catch at Get Task Provider ${e}');
      bool isInternetAvailable = await AppUtils.checkInternetConnectivity();
      if (!isInternetAvailable) {
        getAllLeadModel = GetAllLeadModel(
            message: "Internet is not available, please try again!");
      } else {
        getAllLeadModel = GetAllLeadModel(message: "Something went wrong!");
      }
    }
    _isFetching = false;
    notifyListeners();
    return getAllLeadModel;
  }

  Future<GetLeadByIdModel?> apiCallGetLeadById({String? leadId}) async {

   fetchingFnc(true);
    Map<String, dynamic> body = {
      "leadId": leadId
    };
    try {
      String endPoint = ApiConstants.getLeadByID;
      var response = await callPostMethod(endPoint, body);
      getLeadByIdModel = GetLeadByIdModel.fromJson(json.decode(response));
      print('response ${getLeadByIdModel?.toJson()}');
    } catch (e) {
      print('catch at Get Task Provider ${e}');
      AppUtils.showDialogBoxWithOneButton(titleText: "Error",text: getLeadByIdModel?.message,context: navigatorKey.currentState!.context);
      bool isInternetAvailable = await AppUtils.checkInternetConnectivity();
      if (!isInternetAvailable) {
        getLeadByIdModel = GetLeadByIdModel(
            message: "Internet is not available, please try again!");
      } else {
        getLeadByIdModel = GetLeadByIdModel(message: "Something went wrong!");
      }
    }
   fetchingFnc(false);
    return getLeadByIdModel;
  }
}
