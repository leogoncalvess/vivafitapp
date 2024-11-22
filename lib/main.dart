
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:health/health.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vivafit_personal_app/common/color_extension.dart';
import 'package:vivafit_personal_app/services/health_data_service.dart';
import 'package:vivafit_personal_app/util.dart';
import 'package:vivafit_personal_app/view/on_boarding/started_view.dart';
import 'package:vivafit_personal_app/view/home/home_view.dart';
import 'package:vivafit_personal_app/view/login/login_view.dart';
import 'dart:async';
import 'package:flutter_localizations/flutter_localizations.dart';

enum AppState {
  DATA_NOT_FETCHED,
  FETCHING_DATA,
  DATA_READY,
  NO_DATA,
  AUTHORIZED,
  AUTH_NOT_GRANTED,
  DATA_ADDED,
  DATA_DELETED,
  DATA_NOT_ADDED,
  DATA_NOT_DELETED,
  STEPS_READY,
  HEALTH_CONNECT_STATUS,
  PERMISSIONS_REVOKING,
  PERMISSIONS_REVOKED,
  PERMISSIONS_NOT_REVOKED,
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseAuth.instance.setLanguageCode('pt-BR');
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
    appleProvider: AppleProvider.deviceCheck,
  );
  
  await FirebaseAuth.instance.signOut();

  bool onboardingCompleted = await isOnboardingCompleted();
  
  runApp(VivaFitPersonalApp(onboardingCompleted: onboardingCompleted));
}

class VivaFitPersonalApp extends StatefulWidget {
  final bool onboardingCompleted;

  const VivaFitPersonalApp({Key? key, required this.onboardingCompleted}) : super(key: key);

  @override
  _VivaFitPersonalAppState createState() => _VivaFitPersonalAppState();
}

class _VivaFitPersonalAppState extends State<VivaFitPersonalApp> {
  
  HealthDataService healthDataService = HealthDataService();
  // Todos os tipos disponíveis dependendo da plataforma (iOS ou Android).
  List<HealthDataType> get types => (Platform.isAndroid)
      ? dataTypesAndroid
      : (Platform.isIOS)
          ? dataTypesIOS
          : [];
    // // Ou especifique tipos específicos
  // static final types = [
  //   HealthDataType.WEIGHT,
  //   HealthDataType.STEPS,
  //   HealthDataType.HEIGHT,
  //   HealthDataType.BLOOD_GLUCOSE,
  //   HealthDataType.WORKOUT,
  //   HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
  //   HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
  //   // Descomente esta linha no iOS - disponível apenas no iOS
  //   // HealthDataType.AUDIOGRAM
  // ];

  // Configurar permissões correspondentes
  List<HealthDataAccess> get permissions => types
      .map((type) =>
          // só pode solicitar permissões de LEITURA para a seguinte lista de tipos no iOS
          [
            HealthDataType.WALKING_HEART_RATE,
            HealthDataType.ELECTROCARDIOGRAM,
            HealthDataType.HIGH_HEART_RATE_EVENT,
            HealthDataType.LOW_HEART_RATE_EVENT,
            HealthDataType.IRREGULAR_HEART_RATE_EVENT,
            HealthDataType.EXERCISE_TIME,
          ].contains(type)
              ? HealthDataAccess.READ
              : HealthDataAccess.READ_WRITE)
      .toList();

  @override
  void initState() {
    // configure the health plugin before use and check the Health Connect status
    Health().configure();
    Health().getHealthConnectSdkStatus();    
    healthDataService.authorize(types, permissions);
    super.initState();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {    
    return MaterialApp(
      title: 'VivaFit Personal',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'), // Português do Brasil
      ],
      locale: const Locale('pt', 'BR'),
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primaryColor: TColor.primaryColor1,
        fontFamily: "Poppins"
      ),
      home: AuthCheck(onboardingCompleted: widget.onboardingCompleted),
    );
  }
}

class AuthCheck extends StatelessWidget {
  final bool onboardingCompleted;
  const AuthCheck({Key? key, required this.onboardingCompleted}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasData) {                   
          return const HomeView();
        } else {
          if (!onboardingCompleted) {
            return const StartedView();
          }
          else {
            return const LoginView();
          }
        }
      },
    );
  }
}

Future<bool> isOnboardingCompleted() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('onboardingCompleted') ?? false;
}
