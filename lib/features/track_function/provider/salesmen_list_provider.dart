import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ontrek/core/services/api_constants.dart';
import 'package:ontrek/core/services/network_repository.dart';
import 'package:ontrek/core/storage/preference_helper.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/features/track_function/model/salemen_list_model.dart';
import 'package:ontrek/main.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class SalesMenListProvider extends ChangeNotifier {
  bool _isFetching = false;
  bool _isLoading = false;
  bool _isUploading = false;
  bool _isAdding = false;

  bool get isFetching => _isFetching;

  bool get isLoading => _isLoading;

  bool get isUploading => _isUploading;

  bool get isAdding => _isAdding;

  loaderFnc(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  fetchingFnc(bool isLoading) {
    _isFetching = isLoading;
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


  GetSalesMenListModel? getSalesMenListModel;
  TabController? tabController;
  bool isSearchVisible = false;
  int? selectedIndex = 0;
  PanelController panelController = PanelController();
  TextEditingController searchController = TextEditingController();
  List<Map<String,dynamic>> showUserInMap = [];
  Map<String,dynamic> data ={};


  tabControllerAddListener() {
    tabController?.addListener(() {
      selectedIndex = tabController?.index ?? 0;
      notifyListeners();
    });
  }
animatePanel(){
  panelController.animatePanelToPosition(1.0,duration: Duration(milliseconds: 500));
  notifyListeners();
}
  showAndHideSearchWidget(bool isSearchVisibleFromView){
    isSearchVisible = isSearchVisibleFromView;
    notifyListeners();
  }
  Future<GetSalesMenListModel?> apiCallGetSalesManList() async {
    var userId = PreferenceHelper.getString(PreferenceHelper.USER_ID);
    var orgId = PreferenceHelper.getString(PreferenceHelper.ORG_ID);
    showUserInMap.clear();
    _isFetching = true;
    notifyListeners();

    Map<String, dynamic> body = {
      "userId": userId,
      "eventDate": AppUtils.dateFormat(
          date: DateTime.now(), dateFormat: AppConstant.dateFormat),
      "fillter": searchController.text,
      "orgId": orgId
    };
    try {
      String endPoint = ApiConstants.getSalesMenList;
      var response = await callPostMethod(endPoint, body);
      getSalesMenListModel = GetSalesMenListModel.fromJson(json.decode(response));
      print('response ${getSalesMenListModel?.toJson()}');
      if (getSalesMenListModel?.isError == false &&
          getSalesMenListModel?.isValidationFailed == false) {

        for(int i = 0; i< (getSalesMenListModel?.data?.length ?? 0);i++){
          var saleMenList = getSalesMenListModel?.data?[i];
          data = {
            "userId": saleMenList?.userId,
            "userName": saleMenList?.userName,
            "userProfilePic": saleMenList?.profilePic,
            "userLastLat": saleMenList?.lastActivityDto?.lastActivityLat,
            "userLastLong": saleMenList?.lastActivityDto?.lastActivityLong,
          };
          print("data_OF_MAP$data");
          if(data["userLastLat"] != null && data["userLastLong"]  != null){
            showUserInMap.add(data);
          }

          if(getSalesMenListModel?.data?[i].userId == userId){
            if(getSalesMenListModel?.data?[i] != null){
              getSalesMenListModel?.data?.removeAt(i);
              getSalesMenListModel?.data?.insert(0, saleMenList!);
            }
          }
        }

        print("show_user_in_map${showUserInMap}");
        print("List${getSalesMenListModel?.data?.first.userName}");
      } else {
        if (getSalesMenListModel?.isValidationFailed == true) {
          AppUtils.showDialogBoxWithOneButton(
              titleText: "Information",
              context: navigatorKey.currentState!.context,
              text: getSalesMenListModel?.message ?? "");
        }
      }
    } catch (e) {
      print('catch at GetEmployee_Provider ${e}');
      bool isInternetAvailable = await AppUtils.checkInternetConnectivity();
      if (isInternetAvailable == false) {
        AppUtils.showDialogBoxWithOneButton(
            titleText: "Internet Off Alert",
            text: "Internet is not available. Please Enable Mobile data or wifi.",
            context: navigatorKey.currentState!.context);
      } else {
        AppUtils.showDialogBoxWithOneButton(
            titleText: "Error",
            text: "Something went wrong!",
            context: navigatorKey.currentState!.context);
      }
    }
    _isFetching = false;
    notifyListeners();
    return getSalesMenListModel;
  }

}
