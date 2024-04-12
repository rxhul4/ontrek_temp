

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:ontrek/core/services/api_constants.dart';
import 'package:ontrek/core/services/network_repository.dart';
import 'package:ontrek/core/storage/preference_helper.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/features/add_lead/model/create_lead_model.dart';
import 'package:ontrek/features/add_lead/model/get_all_country_model.dart';
import 'package:ontrek/features/add_lead/model/get_all_state_by_id.dart';
import 'package:ontrek/features/add_lead/model/get_city_by_id.dart';
import 'package:ontrek/features/add_lead/model/get_lead_by_id_model.dart';
import 'package:ontrek/main.dart';

class AddLeadProvider extends ChangeNotifier{
  bool _isFetching = false;
  bool _isLoading = false;
  bool _isUploading = false;
  bool _isAdding = false;

  bool get isFetching => _isFetching;

  bool get isLoading => _isLoading;

  bool get isUploading => _isUploading;

  bool get isAdding => _isAdding;

  GetAllCountryModel? getAllCountryModel;
  GetStateByIdModel? getStateByIdModel;
  GetCityByIdModel? getCityByIdModel;
  CreateLeadModel? createLeadModel;
  GetLeadByIdModel? getLeadByIdModel;

  loaderFnc(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  fetchingFnc(bool isLoading) {
    _isFetching = isLoading;
    notifyListeners();
  }

  Future<CreateLeadModel?> apiCallCreateLead({
    String? companyName,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    String? customerAddress,
    String? zipCode,
    String? cityId,
    String? stateId,
    String? countryId,
    String? totLeadSourceId,

}) async {
    loaderFnc(true);
    String? userId = PreferenceHelper.getString(PreferenceHelper.USER_ID);
    Map<String,dynamic> body =
      {
        "userId": userId,
        "companyName": companyName,
        "customerName": customerName,
        "customerPhone": customerPhone,
        "customerEmail": customerEmail,
        "customerAddress": customerAddress,
        "zipCode": zipCode,
        "cityId": cityId,
        "stateId": stateId,
        "countryId": countryId,
        "totLeadSourceId": totLeadSourceId
      };
    try {
      String endPoint = ApiConstants.createLead;
      var response = await callPostMethod(endPoint,body);
      createLeadModel = CreateLeadModel.fromJson(json.decode(response));
      print('response ${createLeadModel?.toJson()}');
    } catch (e) {
      print('catch at Get addLead Provider $e');
      AppUtils.showDialogBoxWithOneButton(context: navigatorKey.currentContext,text: createLeadModel?.message ?? "");
      bool isInternetAvailable = await AppUtils.checkInternetConnectivity();
      if (!isInternetAvailable) {
        createLeadModel = CreateLeadModel(
            message: "Internet is not available, please try again!");
      } else {
        createLeadModel = CreateLeadModel(message: "Something went wrong!");
      }
    }
    loaderFnc(false);
    return createLeadModel;
  }

  Future<CreateLeadModel?> apiCallUpdateLead({
    String? leadId,
    String? companyName,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    String? customerAddress,
    String? zipCode,
    String? cityId,
    String? stateId,
    String? countryId,
    String? totLeadSourceId,

  }) async {
    fetchingFnc(true);
    String? userId = PreferenceHelper.getString(PreferenceHelper.USER_ID);
    Map<String,dynamic> body =
    {
      "leadId" :leadId,
      "userId": userId,
      "companyName": companyName,
      "customerName": customerName,
      "customerPhone": customerPhone,
      "customerEmail": customerEmail,
      "customerAddress": customerAddress,
      "zipCode": zipCode,
      "cityId": cityId,
      "stateId": stateId,
      "countryId": countryId,
      "totLeadSourceId": totLeadSourceId
    };
    try {
      String endPoint = ApiConstants.updateLead;
      var response = await callPostMethod(endPoint,body);
      createLeadModel = CreateLeadModel.fromJson(json.decode(response));
      print('response ${createLeadModel?.toJson()}');
    } catch (e) {
      print('catch at Get updateLead Provider $e');
      AppUtils.showDialogBoxWithOneButton(context: navigatorKey.currentContext,text: createLeadModel?.message ?? "",titleText: "Error");
      bool isInternetAvailable = await AppUtils.checkInternetConnectivity();
      if (!isInternetAvailable) {
        createLeadModel = CreateLeadModel(
            message: "Internet is not available, please try again!");
      } else {
        createLeadModel = CreateLeadModel(message: "Something went wrong!");
      }
    }
    fetchingFnc(false);
    return createLeadModel;
  }


  Future<GetLeadByIdModel?> apiCallGetLeadById({String? leadId}) async {
    fetchingFnc(true);
    Map<String,dynamic> body ={
      "leadId": leadId
    };
    try {
      String endPoint = ApiConstants.getLeadByID;
      var response = await callPostMethod(endPoint,body);
      getLeadByIdModel = GetLeadByIdModel.fromJson(json.decode(response));
      print('response ${getLeadByIdModel?.toJson()}');
    } catch (e) {
      print('catch at getStateByCountryId Provider $e');
      AppUtils.showDialogBoxWithOneButton(context: navigatorKey.currentContext,text: getLeadByIdModel?.message ?? "");
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


  Future<GetAllCountryModel?> apiCallGetAllCountry() async {
    fetchingFnc(true);
    Map<String,dynamic> body = {};
    try {
      String endPoint = ApiConstants.getAllCountry;
      var response = await callPostMethod(endPoint,body);
      getAllCountryModel = GetAllCountryModel.fromJson(json.decode(response));
      print('response ${getAllCountryModel?.toJson()}');
    } catch (e) {
      print('catch at Get addLead Provider $e');
      AppUtils.showDialogBoxWithOneButton(context: navigatorKey.currentContext,text: getAllCountryModel?.message ?? "");
      bool isInternetAvailable = await AppUtils.checkInternetConnectivity();
      if (!isInternetAvailable) {
        getAllCountryModel = GetAllCountryModel(
            message: "Internet is not available, please try again!");
      } else {
        getAllCountryModel = GetAllCountryModel(message: "Something went wrong!");
      }
    }
    fetchingFnc(false);
    return getAllCountryModel;
  }

  Future<GetStateByIdModel?> apiCallGetStateByCountryId({String? countryId}) async {
    fetchingFnc(true);
    Map<String,dynamic> body ={
      "countryId": countryId
    };
    try {
      String endPoint = ApiConstants.getStateByCountryId;
      var response = await callPostMethod(endPoint,body);
      getStateByIdModel = GetStateByIdModel.fromJson(json.decode(response));
      print('response ${getStateByIdModel?.toJson()}');
    } catch (e) {
      print('catch at getStateByCountryId Provider $e');
      AppUtils.showDialogBoxWithOneButton(context: navigatorKey.currentContext,text: getStateByIdModel?.message ?? "");
      bool isInternetAvailable = await AppUtils.checkInternetConnectivity();
      if (!isInternetAvailable) {
        getStateByIdModel = GetStateByIdModel(
            message: "Internet is not available, please try again!");
      } else {
        getStateByIdModel = GetStateByIdModel(message: "Something went wrong!");
      }
    }
    fetchingFnc(false);
    return getStateByIdModel;
  }
  Future<GetCityByIdModel?> apiCallGetCityByStateId({String? stateId}) async {
    fetchingFnc(true);
    Map<String,dynamic> body ={
      "stateId": stateId
    };
    try {
      String endPoint = ApiConstants.getCityByStateId;
      var response = await callPostMethod(endPoint,body);
      getCityByIdModel = GetCityByIdModel.fromJson(json.decode(response));
      print('response ${getCityByIdModel?.toJson()}');
    } catch (e) {
      print('catch at GetCityById Provider $e');
      AppUtils.showDialogBoxWithOneButton(context: navigatorKey.currentContext,text: getCityByIdModel?.message ?? "");
      bool isInternetAvailable = await AppUtils.checkInternetConnectivity();
      if (!isInternetAvailable) {
        getCityByIdModel = GetCityByIdModel(
            message: "Internet is not available, please try again!");
      } else {
        getCityByIdModel = GetCityByIdModel(message: "Something went wrong!");
      }
    }
    fetchingFnc(false);
    return getCityByIdModel;
  }

}