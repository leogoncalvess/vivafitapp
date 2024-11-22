import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dotted_dashed_line/dotted_dashed_line.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:simple_animation_progress_bar/simple_animation_progress_bar.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vivafit_personal_app/services/health_data_service.dart';
import 'package:vivafit_personal_app/util.dart';
import '../../common/color_extension.dart';
import 'notification_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List lastWorkoutArr = [
    {
      "name": "Full Body Workout",
      "image": "assets/img/Workout1.png",
      "kcal": "180",
      "time": "20",
      "progress": 0.3
    },
    {
      "name": "Lower Body Workout",
      "image": "assets/img/Workout2.png",
      "kcal": "200",
      "time": "30",
      "progress": 0.4
    },
    {
      "name": "Ab Workout",
      "image": "assets/img/Workout3.png",
      "kcal": "300",
      "time": "40",
      "progress": 0.7
    },
  ];
  List<int> showingTooltipOnSpots = [29];
  User? user = FirebaseAuth.instance.currentUser;

  List<FlSpot> allSpots = [];
  double selectedSpot = 0.0;

  List waterArr = [
    {"title": "6am - 8am", "subtitle": "600ml"},
    {"title": "9am - 11am", "subtitle": "500ml"},
    {"title": "11am - 2pm", "subtitle": "1000ml"},
    {"title": "2pm - 4pm", "subtitle": "700ml"},
    {"title": "4pm - now", "subtitle": "900ml"},
  ];

 List<HealthDataType> get healthDataTypes => (Platform.isAndroid)
   ? dataTypesAndroid
   : (Platform.isIOS)
       ? dataTypesIOS
       : [];

  List<HealthDataAccess> get permissions => healthDataTypes
      .map((type) =>
          // can only request READ permissions to the following list of types on iOS
          [
            HealthDataType.WALKING_HEART_RATE,
            HealthDataType.ELECTROCARDIOGRAM,
            HealthDataType.HIGH_HEART_RATE_EVENT,
            HealthDataType.LOW_HEART_RATE_EVENT,
            HealthDataType.IRREGULAR_HEART_RATE_EVENT,
            HealthDataType.EXERCISE_TIME,
            HealthDataType.ACTIVE_ENERGY_BURNED
          ].contains(type)
              ? HealthDataAccess.READ
              : HealthDataAccess.READ_WRITE)
      .toList();

 List<RecordingMethod> recordingMethodsToFilter = [];

 HealthDataService healthDataService = HealthDataService();
 List<HealthDataPoint>? healthDataPoint; 
 int? steps = 0;
 double burnedKCalories = 0.0;
 double kCaloriesGoal = 100.0; 
 final ValueNotifier<double> _caloriesPercentageNotifier = ValueNotifier(0.0);
 double waterIngestion = 2.6;

  Timer? _timer;
 

 double calculateCaloriesPercentage() {
   double burnedPercent = (burnedKCalories / kCaloriesGoal) * 100;
   return burnedPercent;
 }


  @override
  void initState() {
    super.initState();
    _initializeHeartRate();
    _startPeriodicUpdate();    
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancelar o timer quando o widget for destruído
    super.dispose();
  }

  void _startPeriodicUpdate() {
    const duration = Duration(seconds: 60); // Defina o intervalo desejado
    _timer = Timer.periodic(duration, (Timer t) => _initializeHeartRate());
  }

  Future<void> _initializeHeartRate() async {
    healthDataPoint = await healthDataService.fetchData(healthDataTypes, recordingMethodsToFilter);
    
    if (healthDataPoint != null) {

      healthDataPoint = healthDataPoint!
          .where((point) => point.type == HealthDataType.HEART_RATE)
          .toList();
          healthDataPoint = healthDataPoint!.take(60).toList();

      List<FlSpot> spots = [];
      
      healthDataPoint!.sort((a, b) => a.dateFrom.compareTo(b.dateFrom));
      for (var point in healthDataPoint!) {
        double x = point.dateFrom.millisecondsSinceEpoch.toDouble();
        double y = (point.value as NumericHealthValue).numericValue.toDouble();
        spots.add(FlSpot(x, y));
        setState(() {
          selectedSpot = y;
        });
      }

      int? steps = await healthDataService.getSteps();
      double? burnedCalories = await healthDataService.getBurnedCalories();
      List<HealthDataPoint> sleepData = await healthDataService.getSleepData();

      if(mounted)
      {
        setState(() {
          allSpots = spots;
          this.steps = steps;
          burnedKCalories = double.parse((burnedCalories! / 100).toStringAsFixed(2));
          _caloriesPercentageNotifier.value = calculateCaloriesPercentage();
        });
      }   
    }    
  }

  void _navigateToProvider(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Escolha o Provedor'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ListTile(
                  title: Text('Samsung Health'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _launchURL('samsunghealth://');
                  },
                ),
                ListTile(
                  title: Text('Google Fit'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _launchURL('googlefit://');
                  },
                ),
                ListTile(
                  title: Text('Apple Health'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _launchURL('applehealth://');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _launchURL(String url) async {
    if (await canLaunchUrl(url as Uri)) {
      await launchUrl(url as Uri);
    } else {
      throw 'Could not launch $url';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    final lineBarsData = [
      LineChartBarData(
        showingIndicators: showingTooltipOnSpots,
        spots: allSpots,        
        isCurved: false,                
        barWidth: 1,        
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(colors: [
            TColor.secundaryHeartbeatColor.withOpacity(0.4),
            TColor.heartbeatColor.withOpacity(0.4),
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        dotData: const FlDotData(show: false),
        gradient: LinearGradient(
          colors: [
            TColor.heartbeatColor.withOpacity(0.8),
            TColor.heartbeatColor.withOpacity(1),
          ],
        ),
      ),
    ];
    
    return Scaffold(
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Bem vindo,",
                          style: TextStyle(color: TColor.gray, fontSize: 14),
                        ),
                        Text(
                          user?.displayName ?? "Visitante",
                          style: TextStyle(
                              color: TColor.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotificationView(),
                            ),
                          );
                        },
                        icon: Image.asset(
                          "assets/img/notification_active.png",
                          width: 25,
                          height: 25,
                          fit: BoxFit.fitHeight,
                        ))
                  ],
                ), 
                // IconButton(
                //   icon: Icon(Icons.update, color: TColor.heartbeatColor),
                //   onPressed: () {
                //     _navigateToProvider(context);
                //   },
                // ),            
                SizedBox(
                  height: media.width * 0.02,
                ),                
                ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Container(
                    height: media.width * 0.4,
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      color: TColor.primaryColor2.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Stack(
                      alignment: Alignment.topLeft,
                      children: [                        
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(Icons.favorite_border, size: 24, color: TColor.heartbeatColor),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Frequência Cardíaca",
                                    style: TextStyle(
                                        color: TColor.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(width: 80),
                                  ShaderMask(
                                    blendMode: BlendMode.srcIn,
                                    shaderCallback: (bounds) {
                                      return LinearGradient(
                                          colors: TColor.heartbeatG,
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight)
                                          .createShader(Rect.fromLTRB(
                                          0, 0, bounds.width, bounds.height));
                                    },
                                    child: Text(
                                      "${selectedSpot.toString()} BPM",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 18),
                                    ),
                                  )                                  
                                ],
                              ),                              
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0), // Adiciona padding ao redor do gráfico
                          child:LineChart(
                          LineChartData(                            
                            lineTouchData: LineTouchData(
                              enabled: true,
                              handleBuiltInTouches: false,                                                            
                              touchCallback: (FlTouchEvent event,
                                  LineTouchResponse? response) {
                                if (response == null ||
                                    response.lineBarSpots == null) {
                                  return;
                                }
                                if (event is FlTapUpEvent) {
                                  final spotIndex =
                                      response.lineBarSpots!.first.spotIndex;
                                  showingTooltipOnSpots.clear();
                                  setState(() {
                                    showingTooltipOnSpots.add(spotIndex);
                                    final FlSpot spot = response.lineBarSpots!.first;
                                    selectedSpot = spot.y;
                                  });
                                }
                              },
                              mouseCursorResolver: (FlTouchEvent event,
                                  LineTouchResponse? response) {
                                if (response == null ||
                                    response.lineBarSpots == null) {
                                  return SystemMouseCursors.basic;
                                }
                                return SystemMouseCursors.click;
                              },
                              getTouchedSpotIndicator:
                                  (LineChartBarData barData,
                                      List<int> spotIndexes) {
                                return spotIndexes.map((index) {
                                  return TouchedSpotIndicatorData(
                                    const FlLine(
                                      color: Colors.red,
                                      strokeWidth: 2,                                      
                                    ),
                                    FlDotData(
                                      show: true,
                                      getDotPainter:
                                          (spot, percent, barData, index) =>
                                              FlDotCirclePainter(
                                        radius: 3,
                                        color: Colors.white,
                                        strokeWidth: 3,
                                        strokeColor: TColor.secondaryColor1,
                                      ),
                                    ),
                                  );
                                }).toList();
                              },
                              touchTooltipData: LineTouchTooltipData(                                
                                tooltipRoundedRadius: 20,
                                getTooltipItems:
                                    (List<LineBarSpot> lineBarsSpot) {
                                  return lineBarsSpot.map((lineBarSpot) {                                    
                                    final DateTime date = DateTime.fromMillisecondsSinceEpoch(lineBarSpot.x.toInt());
                                    final Duration difference = DateTime.now().difference(date);
                                    String timeAgo;
                                    if (difference.inMinutes > 0) {
                                      timeAgo = "${difference.inMinutes} mins atrás";
                                    } else {
                                      timeAgo = "${difference.inSeconds} segs atrás";
                                    }

                                    return LineTooltipItem(
                                      timeAgo,
                                      const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  }).toList();
                                },
                              ),
                            ),
                            lineBarsData: lineBarsData,
                            minY: 0,
                            maxY: 210,
                            titlesData: const FlTitlesData(
                              show: false,
                            ),
                            gridData: const FlGridData(show: false),
                            borderData: FlBorderData(
                              show: true,
                              border: Border.all(
                                color: Colors.transparent,
                              ),
                            ),
                          )),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: media.width * 0.05,
                ),                
                Text(
                  "Status das atividades",
                  style: TextStyle(
                      color: TColor.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w700),
                ),
                SizedBox(
                  height: media.width * 0.05,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: media.width * 0.95,
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 20),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 2)
                            ]),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(Icons.water_drop_outlined, size: 24, color: TColor.primaryColor1),
                                const SizedBox(width: 1),
                                Text(
                                  "Ingestão de água",
                                  style: TextStyle(
                                      color: TColor.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700),
                                    )
                                  ]
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                ShaderMask(
                                  blendMode: BlendMode.srcIn,
                                  shaderCallback: (bounds) {
                                    return LinearGradient(
                                            colors: TColor.primaryG,
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight)
                                            .createShader(Rect.fromLTRB(0, 0, bounds.width, bounds.height));
                                          },
                                          child: Text(
                                            "${waterIngestion.toStringAsFixed(1)} Litros",
                                            style: TextStyle(
                                                color: TColor.white.withOpacity(0.7),
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14),
                                          )
                                    ),
                                    // Flexible(                                  
                                    //   child: IconButton(
                                    //     onPressed: () {

                                    //     },
                                    //     icon: Icon(Icons.add_circle_outline, color: TColor.primaryColor1, size: 30),
                                    //     )
                                    // ), 
                                  ],
                                ),
                                Row(
                                children: [
                                SimpleAnimationProgressBar(
                                  height: media.width * 0.60,
                                  width: media.width * 0.05,
                                  backgroundColor: Colors.grey.shade100,
                                  foregrondColor: Colors.purple,
                                  ratio: 0.5,
                                  direction: Axis.vertical,
                                  curve: Curves.fastLinearToSlowEaseIn,
                                  duration: const Duration(seconds: 3),
                                  borderRadius: BorderRadius.circular(15),
                                  gradientColor: LinearGradient(
                                      colors: TColor.primaryG,
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),                            
                                Expanded(
                                  child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [                                
                                    const SizedBox(
                                      height: 12,
                                    ),
                                    Text(
                                      "Atualizacões",
                                      style: TextStyle(
                                        color: TColor.gray,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 12,
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: waterArr.map((wObj) {
                                        var isLast = wObj == waterArr.last;
                                        return Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  margin:
                                                      const EdgeInsets.symmetric(
                                                          vertical: 4),
                                                  width: 10,
                                                  height: 10,
                                                  decoration: BoxDecoration(
                                                    color: TColor.secondaryColor1
                                                        .withOpacity(0.5),
                                                    borderRadius:
                                                        BorderRadius.circular(5),
                                                  ),
                                                ),
                                                if (!isLast)
                                                  DottedDashedLine(
                                                      height: media.width * 0.078,
                                                      width: 0,
                                                      dashColor: TColor
                                                          .secondaryColor1
                                                          .withOpacity(0.5),
                                                      axis: Axis.vertical)
                                              ],
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  wObj["title"].toString(),
                                                  style: TextStyle(
                                                    color: TColor.gray,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                ShaderMask(
                                                  blendMode: BlendMode.srcIn,
                                                  shaderCallback: (bounds) {
                                                    return LinearGradient(
                                                            colors:
                                                                TColor.secondaryG,
                                                            begin: Alignment
                                                                .centerLeft,
                                                            end: Alignment
                                                                .centerRight)
                                                        .createShader(Rect.fromLTRB(
                                                            0,
                                                            0,
                                                            bounds.width,
                                                            bounds.height));
                                                  },
                                                  child: Text(
                                                    wObj["subtitle"].toString(),
                                                    style: TextStyle(
                                                        color: TColor.white
                                                            .withOpacity(0.7),
                                                        fontSize: 12),
                                                  ),
                                                ),                                            
                                              ],                                          
                                            )
                                          ],
                                        );
                                      }).toList(),                                  
                                    ),                                                                 
                                    ],
                                  )
                                ),
                              ],
                            ), 
                          ],                          
                        ),
                        
                      ),
                    ),
                    SizedBox(
                      width: media.width * 0.05,
                    ),
                    Expanded(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: double.maxFinite,
                          height: media.width * 0.45,
                          padding: const EdgeInsets.symmetric(
                              vertical: 25, horizontal: 20),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, blurRadius: 2)
                              ]),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Sono",
                                  style: TextStyle(
                                      color: TColor.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700),
                                ),
                                ShaderMask(
                                  blendMode: BlendMode.srcIn,
                                  shaderCallback: (bounds) {
                                    return LinearGradient(
                                            colors: TColor.primaryG,
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight)
                                        .createShader(Rect.fromLTRB(
                                            0, 0, bounds.width, bounds.height));
                                  },
                                  child: Text(
                                    "8h 20m",
                                    style: TextStyle(
                                        color: TColor.white.withOpacity(0.7),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14),
                                  ),
                                ),
                                const Spacer(),
                                Image.asset("assets/img/sleep_grap.png",
                                    width: double.maxFinite,
                                    fit: BoxFit.fitWidth)
                              ]),
                        ),
                        SizedBox(
                          height: media.width * 0.05,
                        ),
                        Container(
                          width: double.maxFinite,
                          height: media.width * 0.45,
                          padding: const EdgeInsets.symmetric(
                              vertical: 25, horizontal: 20),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, blurRadius: 2)
                              ]),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Calorias",
                                  style: TextStyle(
                                      color: TColor.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700),
                                ),
                                ShaderMask(
                                  blendMode: BlendMode.srcIn,
                                  shaderCallback: (bounds) {
                                    return LinearGradient(
                                            colors: TColor.primaryG,
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight)
                                        .createShader(Rect.fromLTRB(
                                            0, 0, bounds.width, bounds.height));
                                  },
                                  child: Text(
                                    "${burnedKCalories.toStringAsFixed(1)} kCal",
                                    style: TextStyle(
                                        color: TColor.white.withOpacity(0.7),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14),
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  alignment: Alignment.center,
                                  child: SizedBox(
                                    width: media.width * 0.2,
                                    height: media.width * 0.2,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          width: media.width * 0.15,
                                          height: media.width * 0.15,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                                colors: TColor.primaryG),
                                            borderRadius: BorderRadius.circular(
                                                media.width * 0.075),
                                          ),
                                          child: FittedBox(
                                            child: Text(
                                              "restam\n ${(kCaloriesGoal - burnedKCalories).toStringAsFixed(1)} kCal",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: TColor.white,
                                                  fontSize: 12),
                                            ),
                                          ),
                                        ),
                                        SimpleCircularProgressBar(
                                          progressStrokeWidth: 10,
                                          backStrokeWidth: 10,
                                          progressColors: TColor.primaryG,
                                          backColor: Colors.grey.shade100,
                                          valueNotifier: _caloriesPercentageNotifier,
                                          startAngle: -180,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ]),
                        ),
                      ],
                    ),                                                                                     
                    ),                                      
                  ],  
                ),                                                     
                SizedBox(
                  height: media.width * 0.1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(
      2,
      (i) {
        var color0 = TColor.secondaryColor1;

        switch (i) {
          case 0:
            return PieChartSectionData(
                color: color0,
                value: 33,
                title: '',
                radius: 55,
                titlePositionPercentageOffset: 0.55,
                badgeWidget: const Text(
                  "20,1",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                ));
          case 1:
            return PieChartSectionData(
              color: Colors.white,
              value: 75,
              title: '',
              radius: 45,
              titlePositionPercentageOffset: 0.55,
            );

          default:
            throw Error();
        }
      },
    );
  }

  LineTouchData get lineTouchData1 => LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          //tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
        ),
      );

  List<LineChartBarData> get lineBarsData1 => [
        lineChartBarData1_1,
        lineChartBarData1_2,
      ];

  LineChartBarData get lineChartBarData1_1 => LineChartBarData(
        isCurved: true,
        gradient: LinearGradient(colors: [
          TColor.primaryColor2.withOpacity(0.5),
          TColor.primaryColor1.withOpacity(0.5),
        ]),
        barWidth: 4,
        isStrokeCapRound: true,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        spots: const [
          FlSpot(1, 35),
          FlSpot(2, 70),
          FlSpot(3, 40),
          FlSpot(4, 80),
          FlSpot(5, 25),
          FlSpot(6, 70),
          FlSpot(7, 35),
        ],
      );

  LineChartBarData get lineChartBarData1_2 => LineChartBarData(
        isCurved: true,
        gradient: LinearGradient(colors: [
          TColor.secondaryColor2.withOpacity(0.5),
          TColor.secondaryColor1.withOpacity(0.5),
        ]),
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(
          show: false,
        ),
        spots: const [
          FlSpot(1, 80),
          FlSpot(2, 50),
          FlSpot(3, 90),
          FlSpot(4, 40),
          FlSpot(5, 80),
          FlSpot(6, 35),
          FlSpot(7, 60),
        ],
      );

  SideTitles get rightTitles => SideTitles(
        getTitlesWidget: rightTitleWidgets,
        showTitles: true,
        interval: 20,
        reservedSize: 40,
      );

  Widget rightTitleWidgets(double value, TitleMeta meta) {
    String text;
    switch (value.toInt()) {
      case 0:
        text = '0%';
        break;
      case 20:
        text = '20%';
        break;
      case 40:
        text = '40%';
        break;
      case 60:
        text = '60%';
        break;
      case 80:
        text = '80%';
        break;
      case 100:
        text = '100%';
        break;
      default:
        return Container();
    }

    return Text(text,
        style: TextStyle(
          color: TColor.gray,
          fontSize: 12,
        ),
        textAlign: TextAlign.center);
  }

  SideTitles get bottomTitles => SideTitles(
        showTitles: true,
        reservedSize: 32,
        interval: 1,
        getTitlesWidget: bottomTitleWidgets,
      );

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    var style = TextStyle(
      color: TColor.gray,
      fontSize: 12,
    );
    Widget text;
    switch (value.toInt()) {
      case 1:
        text = Text('Dom', style: style);
        break;
      case 2:
        text = Text('Seg', style: style);
        break;
      case 3:
        text = Text('Ter', style: style);
        break;
      case 4:
        text = Text('Qua', style: style);
        break;
      case 5:
        text = Text('Qui', style: style);
        break;
      case 6:
        text = Text('Sex', style: style);
        break;
      case 7:
        text = Text('Sab', style: style);
        break;
      default:
        text = const Text('');
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 10,
      child: text,
    );
  }
}
