class ApiConstants{

   // encrypted url
   static const String baseUrl = "https://api.ontrek.io";

   //testing Url
   // static const String baseUrl = "http://ontrek_v1api.epistic.net";

   //Authentication Api
      static const String login = "$baseUrl/FieldUser/Login";
      static const String verifyOtp = "$baseUrl/FieldUser/VerifyOtp";
      static const String getSalesMenList = "$baseUrl/FieldUser/SalesmanList";
      static const String getSalesMenTimeLine = "$baseUrl/FieldUser/GetTimeline";
      static const String createActivity = "$baseUrl/FieldUser/CreateActivity";
      static const String bulkActivity = "$baseUrl/FieldUser/BulkActivity";
      static const String getLastActivity = "$baseUrl/FieldUser/GetLastActivity";
      static const String createRouteHistory = "$baseUrl/FieldUser/CreateRoutHistory";
      static const String getLeadList = "$baseUrl/FieldUser/LeadList";
      static const String getVisitNote = "$baseUrl/FieldUser/GetVisitNote";
      static const String getAllTaskByUserId = "$baseUrl/FieldUser/TaskList";
      static const String dayEndManualRequest = "$baseUrl/FieldUser/DayEndManualRequest";
      static const String checkPendingEndDate = "$baseUrl/FieldUser/CheckPendingEndDate";

   
      static const String getTotByGroupType = "$baseUrl/Super/Tot/GetTotByGroupType";
      static const String getAllCountry = "$baseUrl/Super/Country/GetAll";
      static const String getStateByCountryId = "$baseUrl/Super/State/GetByCountryId";
      static const String getCityByStateId = "$baseUrl/Super/City/GetCityByStateId";

      static const String createLead = "$baseUrl/Super/Lead/Create";
      static const String updateLead = "$baseUrl/Super/Lead/Update";
      static const String getLeadByID = "$baseUrl/Super/Lead/GetById";


      static const String getTaskById = "$baseUrl/Admin/AppUserTask/GetById";
      static const String updateTaskStatus = "$baseUrl/Admin/AppUserTask/Update";



}