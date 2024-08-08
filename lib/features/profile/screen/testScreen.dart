import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ontrek/core/background_service_model/app_off_time_model.dart';
import 'package:ontrek/core/services/background_service.dart';
import 'package:ontrek/core/storage/db_service.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:sqflite/sqlite_api.dart';

class Testscreen extends StatefulWidget {
  const Testscreen({super.key});

  @override
  State<Testscreen> createState() => _TestscreenState();
}

class _TestscreenState extends State<Testscreen> {
  List<AppOffTime> appOfList = [];
  late Database db;
  DatabaseService dbService = DatabaseService();
  bool isLoading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    loadData();
    _timer = Timer.periodic(Duration(minutes: 1), (Timer t) => loadData());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future loadData() async {
    db = await dbService.initializeOnTrekDB();
    appOfList = await dbService.getAllAppOffTime(db);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Off Times'),
      ),
      body: isLoading
          ? AppUtils.loaderWidget()
          : appOfList.isEmpty
          ? AppUtils.commonNoDataFound()
          : RefreshIndicator(
        onRefresh: ()async {
         await loadData();
        },
            child: Column(
                    children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  Text("Start Time"),
                  Text("End Time"),
                  // Text("Active"),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: appOfList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text("${AppUtils.getDate(date: appOfList[index].startTime, format: "dd/MM/yyyy HH:mm")}"),
                        Text("${AppUtils.getDate(date: appOfList[index].stopTime, format: "dd/MM/yyyy HH:mm")}"),
                        // Text("${appOfList[index].isActive}"),
                      ],
                    ),
                  );
                },
              ),
            ),
                    ],
                  ),
          ),
    );
  }
}
