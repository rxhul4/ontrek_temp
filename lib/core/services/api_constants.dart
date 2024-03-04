class ApiConstants{
   static const String baseUrl = "http://ontrek_v1api.epistic.net/Admin";

   //Authentication Api
      static const String login = "$baseUrl/FieldUser/Login";
      static const String verifyOtp = "$baseUrl/FieldUser/VerifyOtp";


   static const String getSalesMenList = "$baseUrl/FieldUser/SalesmanList";
   static const String getAllTaskByUserId = "$baseUrl/AppUserTask/GetAllTaskByUserId";
   static const String getSalesMentimeLine = "$baseUrl/Admin/GetTimeLine";


  //salesMen
   static const String addActivity = "$baseUrl/SalesMen/AddActivity";

   //totapi
   static const String getTableOfTableByType = "$baseUrl/TableOfTable/GetTableOfTableByType";


}