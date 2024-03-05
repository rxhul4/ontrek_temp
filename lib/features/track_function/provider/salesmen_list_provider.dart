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
    // var managerId = PreferenceHelper.getInt(PreferenceHelper.USER_UID);
    _isFetching = true;
    notifyListeners();

    Map<String, dynamic> body = {
      "managerId": "919e3ede-00e1-4502-87f2-6b2459554c9c",
      "eventDate": AppUtils.dateFormat(
          date: DateTime.now(), dateFormat: AppConstant.dateFormat),
      "fillter": searchController.text,
      "orgId": "10bce922-213c-46dd-aa94-0c47883b76d3"
    };
    try {
      String endPoint = ApiConstants.getSalesMenList;
      var response = await callPostMethod(endPoint, body);
      getSalesMenListModel =
          GetSalesMenListModel.fromJson(json.decode(response));
      print('response ${getSalesMenListModel?.toJson()}');
      if (getSalesMenListModel?.isError == false &&
          getSalesMenListModel?.isValidationFailed == false) {
      } else {
        AppUtils.dialogWidget(getSalesMenListModel?.message ?? "",navigatorKey.currentState!.context);
      }
    } catch (e) {
      print('catch at GetEmployee_Provider ${e}');
      bool isInternetAvailable = await AppUtils.checkInternetConnectivity();
      if (!isInternetAvailable) {
        getSalesMenListModel = GetSalesMenListModel(
            message: "Internet is not available, please try again!");
      } else {
        getSalesMenListModel =
            GetSalesMenListModel(message: "Something went wrong!");
      }
    }
    _isFetching = false;
    notifyListeners();
    return getSalesMenListModel;
  }
}
