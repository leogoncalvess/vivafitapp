import 'package:vivafit_personal_app/common/color_extension.dart';
import 'package:vivafit_personal_app/common_widget/heart_activity_chart.dart';
import 'package:vivafit_personal_app/common_widget/training_frequency.dart';
import 'package:vivafit_personal_app/view/workout_tracker/workour_detail_view.dart';
import 'package:flutter/material.dart';
import '../../common_widget/what_train_row.dart';

class WorkoutTrackerView extends StatefulWidget {
  const WorkoutTrackerView({super.key});

  @override
  State<WorkoutTrackerView> createState() => _WorkoutTrackerViewState();
}

class _WorkoutTrackerViewState extends State<WorkoutTrackerView> {

  List whatArr = [
    {
      "image": "assets/img/what_1.png",
      "title": "Rotina de Treinos academia do prédio",
      "exercises": "11 Exercicios",
      "time": "32mins"
    },
    {
      "image": "assets/img/what_2.png",
      "title": "Rotina de Treinos academia",
      "exercises": "12 Exercicios",
      "time": "40mins"
    },
    {
      "image": "assets/img/what_3.png",
      "title": "Rotina de Treinos",
      "exercises": "14 Exercicios",
      "time": "20mins"
    }
  ];

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.white,
        centerTitle: true,
        elevation: 0,
        leadingWidth: 0,
        leading: const SizedBox(),
        title: Text(
          "Meus treinos",
          style: TextStyle(
              color: TColor.black, fontSize: 16, fontWeight: FontWeight.w700),
        )
      ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
              color: TColor.white,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25), topRight: Radius.circular(25))),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Frenquência de Treinos",
                        style: TextStyle(
                            color: TColor.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TrainingFrequency(trainingData: generateMonthlyTrainingData()),
                  SizedBox(
                    height: media.width * 0.05,
                  ), 
                  // HeartActivityChart(
                  //   caloriesProgress: 1.0, // Progresso de exemplo
                  //   stepsProgress: 1.0,
                  //   activeTimeProgress: 1.0,
                  // ),                                   
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Rotinas de Treinos",
                        style: TextStyle(
                            color: TColor.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  SizedBox(
                  height: media.width * 0.05,
                  ),
                  ListView.builder(
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: whatArr.length,
                      itemBuilder: (context, index) {
                        var wObj = whatArr[index] as Map? ?? {};
                        return InkWell(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) =>  WorkoutDetailView( dObj: wObj, ) ));
                          },
                          child:  WhatTrainRow(wObj: wObj) );
                      }),
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
}