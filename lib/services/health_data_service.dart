import 'package:health/health.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart'; 

class HealthDataService {

  /// Install Google Health Connect on this phone.
  Future<void> installHealthConnect() async =>
      await Health().installHealthConnect();

  Future<bool> authorize(List<HealthDataType> types, List<HealthDataAccess> permissions) async {
    await Permission.activityRecognition.request();
    await Permission.location.request();

    bool? hasPermissions = await Health().hasPermissions(types, permissions: permissions);
    hasPermissions = false;

    bool authorized = false;
    if (!hasPermissions) {
      try {
        authorized = await Health().requestAuthorization(types, permissions: permissions);
      } catch (error) {
        debugPrint("Exception in authorize: $error");
      }
    }

    return authorized;
  }

  Future<HealthConnectSdkStatus?> getHealthConnectSdkStatus() async {
    assert(Platform.isAndroid, "This is only available on Android");
    final status = await Health().getHealthConnectSdkStatus();
    return status;
  }

  Future<List<HealthDataPoint>> fetchData(List<HealthDataType> types, List<RecordingMethod> recordingMethodsToFilter) async {
    final now = DateTime.now();
    final last72Hours = now.subtract(const Duration(hours: 72));   
    
    List<HealthDataPoint> healthDataList = [];

    try {
      List<HealthDataPoint> healthData = await Health().getHealthDataFromTypes(
        types: types,
        startTime: last72Hours,
        endTime: now,
        recordingMethodsToFilter: recordingMethodsToFilter,
      );
      
      List<HealthDataPoint> heartRateData = healthData.where((dataPoint) {
        DateTime dataPointDate = DateTime(dataPoint.dateTo.year, dataPoint.dateTo.month, dataPoint.dateTo.day);
        DateTime todayDate = DateTime(now.year, now.month, now.day);
        return dataPointDate == todayDate && dataPoint.type == HealthDataType.HEART_RATE;
      }).toList();

      List<HealthDataPoint> filteredHealthData = healthData.where((dataPoint) {
        DateTime dataPointDate = DateTime(dataPoint.dateTo.year, dataPoint.dateTo.month, dataPoint.dateTo.day);
        DateTime todayDate = DateTime(now.year, now.month, now.day);
        return dataPointDate == todayDate && dataPoint.type != HealthDataType.HEART_RATE;
      }).toList();

      heartRateData.sort((a, b) => b.dateTo.compareTo(a.dateTo));
      healthDataList.addAll(heartRateData);
    } catch (error) {
      debugPrint("Exception in getHealthDataFromTypes: $error");
    }

    healthDataList = Health().removeDuplicates(healthDataList);
    return healthDataList;
  }

  Future<bool> addData() async {
    final now = DateTime.now();
    final earlier = now.subtract(const Duration(minutes: 20));

    bool success = true;

    success &= await Health().writeHealthData(
        value: 1.925,
        type: HealthDataType.HEIGHT,
        startTime: earlier,
        endTime: now,
        recordingMethod: RecordingMethod.manual);
    success &= await Health().writeHealthData(
        value: 90,
        type: HealthDataType.WEIGHT,
        startTime: now,
        recordingMethod: RecordingMethod.manual);
    success &= await Health().writeHealthData(
        value: 90,
        type: HealthDataType.HEART_RATE,
        startTime: earlier,
        endTime: now,
        recordingMethod: RecordingMethod.manual);
    success &= await Health().writeHealthData(
        value: 90,
        type: HealthDataType.STEPS,
        startTime: earlier,
        endTime: now,
        recordingMethod: RecordingMethod.manual);
    success &= await Health().writeHealthData(
      value: 200,
      type: HealthDataType.ACTIVE_ENERGY_BURNED,
      startTime: earlier,
      endTime: now,
    );
    success &= await Health().writeHealthData(
        value: 70,
        type: HealthDataType.HEART_RATE,
        startTime: earlier,
        endTime: now);
    if (Platform.isIOS) {
      success &= await Health().writeHealthData(
          value: 30,
          type: HealthDataType.HEART_RATE_VARIABILITY_SDNN,
          startTime: earlier,
          endTime: now);
    } else {
      success &= await Health().writeHealthData(
          value: 30,
          type: HealthDataType.HEART_RATE_VARIABILITY_RMSSD,
          startTime: earlier,
          endTime: now);
    }
    success &= await Health().writeHealthData(
        value: 37,
        type: HealthDataType.BODY_TEMPERATURE,
        startTime: earlier,
        endTime: now);
    success &= await Health().writeHealthData(
        value: 105,
        type: HealthDataType.BLOOD_GLUCOSE,
        startTime: earlier,
        endTime: now);
    success &= await Health().writeHealthData(
        value: 1.8,
        type: HealthDataType.WATER,
        startTime: earlier,
        endTime: now);

    success &= await Health().writeHealthData(
        value: 0.0,
        type: HealthDataType.SLEEP_REM,
        startTime: earlier,
        endTime: now);
    success &= await Health().writeHealthData(
        value: 0.0,
        type: HealthDataType.SLEEP_ASLEEP,
        startTime: earlier,
        endTime: now);
    success &= await Health().writeHealthData(
        value: 0.0,
        type: HealthDataType.SLEEP_AWAKE,
        startTime: earlier,
        endTime: now);
    success &= await Health().writeHealthData(
        value: 0.0,
        type: HealthDataType.SLEEP_DEEP,
        startTime: earlier,
        endTime: now);

    success &= await Health().writeBloodOxygen(
      saturation: 98,
      startTime: earlier,
      endTime: now,
    );
    success &= await Health().writeWorkoutData(
      activityType: HealthWorkoutActivityType.AMERICAN_FOOTBALL,
      title: "Random workout name that shows up in Health Connect",
      start: now.subtract(const Duration(minutes: 15)),
      end: now,
      totalDistance: 2430,
      totalEnergyBurned: 400,
    );
    success &= await Health().writeBloodPressure(
      systolic: 90,
      diastolic: 80,
      startTime: now,
    );
    success &= await Health().writeMeal(
        mealType: MealType.SNACK,
        startTime: earlier,
        endTime: now,
        caloriesConsumed: 1000,
        carbohydrates: 50,
        protein: 25,
        fatTotal: 50,
        name: "Banana",
        caffeine: 0.002,
        vitaminA: 0.001,
        vitaminC: 0.002,
        vitaminD: 0.003,
        vitaminE: 0.004,
        vitaminK: 0.005,
        b1Thiamin: 0.006,
        b2Riboflavin: 0.007,
        b3Niacin: 0.008,
        b5PantothenicAcid: 0.009,
        b6Pyridoxine: 0.010,
        b7Biotin: 0.011,
        b9Folate: 0.012,
        b12Cobalamin: 0.013,
        calcium: 0.015,
        copper: 0.016,
        iodine: 0.017,
        iron: 0.018,
        magnesium: 0.019,
        manganese: 0.020,
        phosphorus: 0.021,
        potassium: 0.022,
        selenium: 0.023,
        sodium: 0.024,
        zinc: 0.025,
        water: 0.026,
        molybdenum: 0.027,
        chloride: 0.028,
        chromium: 0.029,
        cholesterol: 0.030,
        fiber: 0.031,
        fatMonounsaturated: 0.032,
        fatPolyunsaturated: 0.033,
        fatUnsaturated: 0.065,
        fatTransMonoenoic: 0.65,
        fatSaturated: 066,
        sugar: 0.067,
        recordingMethod: RecordingMethod.manual);

    success &= await Health().writeMenstruationFlow(
      flow: MenstrualFlow.medium,
      isStartOfCycle: true,
      startTime: earlier,
      endTime: now,
    );

    return success;
  }

  Future<bool> deleteData(List<HealthDataType> types) async {
    final now = DateTime.now();
    final earlier = now.subtract(const Duration(hours: 24));

    bool success = true;
    for (HealthDataType type in types) {
      success &= await Health().delete(
        type: type,
        startTime: earlier,
        endTime: now,
      );
    }

    return success;
  }

  Future<int?> fetchStepData(List<RecordingMethod> recordingMethodsToFilter) async {
    int? steps;

    final now = DateTime.now();
    //final midnight = DateTime(now.year, now.month, now.day);
    final midnight = now.subtract(Duration(hours: 24));

    bool stepsPermission = await Health().hasPermissions([HealthDataType.STEPS]) ?? false;
    if (!stepsPermission) {
      stepsPermission = await Health().requestAuthorization([HealthDataType.STEPS]);
    }

    if (stepsPermission) {
      try {
        steps = await Health().getTotalStepsInInterval(midnight, now,
            includeManualEntry: !recordingMethodsToFilter.contains(RecordingMethod.manual));
      } catch (error) {
        debugPrint("Exception in getTotalStepsInInterval: $error");
      }
    } else {
      debugPrint("Authorization not granted - error in authorization");
    }

    return steps;
  }

  Future<bool> revokeAccess() async {
    bool success = false;

    try {
      await Health().revokePermissions();
      success = true;
    } catch (error) {
      debugPrint("Exception in revokeAccess: $error");
    }

    return success;
  }

  Future<int?> getSteps() async {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);

    int? steps = await Health().getTotalStepsInInterval(midnight, now);
    return steps;
  }

  Future<List<HealthDataPoint>> getHealthAggregateDataFromTypes(List<HealthDataType> types) async {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);

    List<HealthDataPoint> healthData = await Health().getHealthAggregateDataFromTypes(types: types, startDate: midnight, endDate: now);    
    return healthData;
  }

  Future<double?> getBurnedCalories() async {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);
    HealthDataPoint? healthDataPoint;

    try {
      List<HealthDataPoint> healthData = await Health().getHealthDataFromTypes(
        types: [HealthDataType.ACTIVE_ENERGY_BURNED],
        startTime: midnight,
        endTime: now
      );

      List<HealthDataPoint> filteredHealthData = healthData.where((dataPoint) {
        DateTime dataPointDate = DateTime(dataPoint.dateTo.year, dataPoint.dateTo.month, dataPoint.dateTo.day);
        DateTime todayDate = DateTime(now.year, now.month, now.day);
        return dataPointDate == todayDate;
      }).toList();
      
      filteredHealthData.sort((a, b) => b.dateTo.compareTo(a.dateTo));            
      healthDataPoint = filteredHealthData[0];

    } catch (error) {
      debugPrint("Exception in fetchCaloriesData: $error");
    }

    return healthDataPoint == null ? 0.0 :(healthDataPoint.value as NumericHealthValue).numericValue.toDouble();    
  }

  Future<List<HealthDataPoint>> getSleepData() async {
    final now = DateTime.now();    
    final last24Hours = now.subtract(const Duration(hours: 72));
    List<HealthDataPoint> healthData = [];

    try {
      List<HealthDataPoint> healthData = await Health().getHealthDataFromTypes(
        types: [HealthDataType.SLEEP_SESSION],
        startTime: last24Hours,
        endTime: now
      );
      
      healthData.sort((a, b) => b.dateTo.compareTo(a.dateTo));                  
    } catch (error) {
      debugPrint("Exception in fetchCaloriesData: $error");
    }

    return healthData;  
  }

}