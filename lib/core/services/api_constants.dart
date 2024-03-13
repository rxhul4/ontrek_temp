class ApiConstants{
   static const String baseUrl = "http://ontrek_v1api.epistic.net";

   //Authentication Api
      static const String login = "$baseUrl/FieldUser/Login";
      static const String verifyOtp = "$baseUrl/FieldUser/VerifyOtp";


   static const String getSalesMenList = "$baseUrl/FieldUser/SalesmanList";
   static const String getAllTaskByUserId = "$baseUrl/AppUserTask/GetAllTaskByUserId";
   static const String getSalesMenTimeLine = "$baseUrl/FieldUser/GetTimeline";


  //salesMen
   static const String createActivity = "$baseUrl/FieldUser/CreateActivity";
   static const String createRouteHistory = "$baseUrl/FieldUser/CreateRoutHistory";

   //totapi
   static const String getTotByGroupType = "http://ontrek_v1api.epistic.net/Super/Tot/GetTotByGroupType";
   //lead
   static const String getAllLeads = "$baseUrl/Super/Lead/GetAll";



}