import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:ontrek/core/services/api_constants.dart';
import 'package:ontrek/core/services/network_repository.dart';
import 'package:ontrek/core/storage/preference_helper.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/features/leads/model/lead_model.dart';
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

  Future<GetAllLeadModel?> apiCallGetAllLead({String? orgId}) async {
    var orgId = PreferenceHelper.getString(PreferenceHelper.ORG_ID);
    _isFetching = true;
    notifyListeners();
    Map<String, dynamic> body = {
      "orgId": orgId,
    };
    try {
      String endPoint = ApiConstants.getAllLeads;

      var response = await callPostMethod(endPoint, body);
      getAllLeadModel = GetAllLeadModel.fromJson(json.decode(response));
      print('response ${getAllLeadModel?.toJson()}');
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
}
