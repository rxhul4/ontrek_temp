class LoginModel {
  Data? data;
  bool? isSuccessful;
  int? code;
  String? message;

  LoginModel({this.data, this.isSuccessful, this.code, this.message});

  LoginModel.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    isSuccessful = json['isSuccessful'];
    code = json['code'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['isSuccessful'] = this.isSuccessful;
    data['code'] = this.code;
    data['message'] = this.message;
    return data;
  }
}

class Data {
  String? userUid;
  String? companyUid;
  String? fullName;
  String? userEmail;
  String? phoneNo;
  String? profilePic;
  int? roleId;
  String? roleName;
  String? token;

  Data(
      {this.userUid,
        this.companyUid,
        this.fullName,
        this.userEmail,
        this.phoneNo,
        this.profilePic,
        this.roleId,
        this.roleName,
        this.token});

  Data.fromJson(Map<String, dynamic> json) {
    userUid = json['user_uid'];
    companyUid = json['company_uid'];
    fullName = json['full_name'];
    userEmail = json['user_email'];
    phoneNo = json['phone_no'];
    profilePic = json['profile_pic'];
    roleId = json['role_id'];
    roleName = json['role_name'];
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_uid'] = this.userUid;
    data['company_uid'] = this.companyUid;
    data['full_name'] = this.fullName;
    data['user_email'] = this.userEmail;
    data['phone_no'] = this.phoneNo;
    data['profile_pic'] = this.profilePic;
    data['role_id'] = this.roleId;
    data['role_name'] = this.roleName;
    data['token'] = this.token;
    return data;
  }
}
