class CheckOutFormModel {
  List<Data>? data;
  bool? isSuccessful;
  int? code;
  String? message;

  CheckOutFormModel({this.data, this.isSuccessful, this.code, this.message});

  CheckOutFormModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
    isSuccessful = json['isSuccessful'];
    code = json['code'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['isSuccessful'] = this.isSuccessful;
    data['code'] = this.code;
    data['message'] = this.message;
    return data;
  }
}

class Data {
  int? totId;
  String? totType;
  String? totKey;
  String? totValue;
  int? totSeq;
  Null? iconPic;
  String? totTypeCode;

  Data(
      {this.totId,
        this.totType,
        this.totKey,
        this.totValue,
        this.totSeq,
        this.iconPic,
        this.totTypeCode});

  Data.fromJson(Map<String, dynamic> json) {
    totId = json['tot_id'];
    totType = json['tot_type'];
    totKey = json['tot_key'];
    totValue = json['tot_value'];
    totSeq = json['tot_seq'];
    iconPic = json['icon_pic'];
    totTypeCode = json['tot_type_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['tot_id'] = this.totId;
    data['tot_type'] = this.totType;
    data['tot_key'] = this.totKey;
    data['tot_value'] = this.totValue;
    data['tot_seq'] = this.totSeq;
    data['icon_pic'] = this.iconPic;
    data['tot_type_code'] = this.totTypeCode;
    return data;
  }
}
