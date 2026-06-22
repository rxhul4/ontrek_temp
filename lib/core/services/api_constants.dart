class ApiConstants{

   // encrypted url
   static const String baseUrl = "https://api.ontrek.in";

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
        static const String sendLastStatus = "$baseUrl/FieldUser/SendLastStatus";
        static const String getMyLeaveList = "$baseUrl/FieldUser/Leave/MyList";
        static const String getMyEmployeeLeaveList = "$baseUrl/FieldUser/Leave/SubOrdinateList";
        static const String applyAndUpdateLeave = "$baseUrl/FieldUser/Leave/AddUpdate";
        static const String approveRejectLeave = "$baseUrl/FieldUser/Leave/ApproveReject";


       static const String getMyExpenseList = "$baseUrl/FieldUser/Expense/MyExpenseList";
       static const String getMyEmployeeExpenseList = "$baseUrl/FieldUser/Expense/SubOrdinateList";
       static const String applyAndUpdateExpense = "$baseUrl/FieldUser/Expense/AddUpdate";
       static const String approveRejectExpense = "$baseUrl/FieldUser/Expense/ApproveReject";


       static const String dayEndMyRequestList = "$baseUrl/FieldUser/DayEnd/MyRequestList";
       static const String dayEndMyEmployeeRequest = "$baseUrl/FieldUser/DayEnd/MySubOrdinateRequestList";







      static const String getTotByGroupType = "$baseUrl/Super/Tot/GetTotByGroupType";
      static const String getAllCountry = "$baseUrl/Super/Country/GetAll";
      static const String getStateByCountryId = "$baseUrl/Super/State/GetByCountryId";
      static const String getCityByStateId = "$baseUrl/Super/City/GetCityByStateId";

      static const String createLead = "$baseUrl/Super/Lead/Create";
      static const String updateLead = "$baseUrl/Super/Lead/Update";
      static const String getLeadByID = "$baseUrl/Super/Lead/GetById";


      static const String getTaskById = "$baseUrl/Admin/AppUserTask/GetById";
      static const String updateTaskStatus = "$baseUrl/Admin/AppUserTask/Update";


      static const String getAttendanceReport = "$baseUrl/Admin/Report/AttendenceReport";
      static const String approveRequest = "$baseUrl/Admin/DayEnd/ApproveRequest";
      static const String getHolidayList = "$baseUrl/Admin/Holiday/ListAll";
      static const String getExpenseCategory = "$baseUrl/Admin/Master/GetExpenseCategoryList";
      static const String getExpenseSubCategory = "$baseUrl/Admin/Master/GetSubExpenseCategoryList";




}