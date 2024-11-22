import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vivafit_personal_app/services/user_profile_service.dart';
import 'package:vivafit_personal_app/view/login/welcome_view.dart';
import 'package:flutter/material.dart';

import '../../common/color_extension.dart';
import '../../common_widget/round_button.dart';

class WhatYourGoalView extends StatefulWidget {
  final User? user;
  
  const WhatYourGoalView({Key? key, required this.user}) : super(key: key);

  @override
  State<WhatYourGoalView> createState() => _WhatYourGoalViewState();
}

class _WhatYourGoalViewState extends State<WhatYourGoalView> {
  final CarouselSliderController _carouselController = CarouselSliderController();
  int _currentIndex = 0;

  List goalArr = [
    {
      "image": "assets/img/goal_1.png",
      "title": "Melhorar a forma",
      "subtitle":
          "Tenho pouca gordura corporal\ne preciso / quero construir\nmais músculos."
    },
    {
      "image": "assets/img/goal_2.png",
      "title": "Ganhar massa muscular",
      "subtitle":
          "Eu sou magro, quero ganhar\nmassa muscular."
    },
    {
      "image": "assets/img/goal_3.png",
      "title": "Perder gordura",
      "subtitle":
          "Tenho alguns quilos para perder.\nQuero perder gordura e ganhar\nmassa muscular."
    },
  ];

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: TColor.white,
      body: SafeArea(
          child: Stack(
        children: [
          Center(
            child: CarouselSlider(
              items: goalArr
                  .map(
                    (gObj) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: TColor.primaryG,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: EdgeInsets.symmetric(
                          vertical: media.width * 0.1, horizontal: 25),
                      alignment: Alignment.center,
                      child: FittedBox(
                        child: Column(
                          children: [
                            Image.asset(
                              gObj["image"].toString(),
                              width: media.width * 0.5,
                              fit: BoxFit.fitWidth,
                            ),
                            SizedBox(
                              height: media.width * 0.1,
                            ),
                            Text(
                              gObj["title"].toString(),
                              style: TextStyle(
                                  color: TColor.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700),
                            ),
                            Container(
                              width: media.width * 0.1,
                              height: 1,
                              color: TColor.white,
                            ),
                            SizedBox(
                              height: media.width * 0.02,
                            ),
                            Text(
                              gObj["subtitle"].toString(),
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: TColor.white, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
              carouselController: _carouselController,
              options: CarouselOptions(
                autoPlay: false,
                enlargeCenterPage: true,
                viewportFraction: 0.7,
                aspectRatio: 0.74,
                initialPage: 0,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
            width: media.width,
            child: Column(
              children: [
                SizedBox(
                  height: media.width * 0.02,
                ),
                Text(
                  "Qual é o seu objetivo ?",
                  style: TextStyle(
                      color: TColor.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w700),
                ),
                Text(
                  "Isso nos ajudará a construir o\nmelhor programa de treinos\npara você.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: TColor.gray, fontSize: 12),
                ),
                const Spacer(),
                SizedBox(
                  height: media.width * 0.05,
                ),
                RoundButton(
                    title: "Confirmar",
                    onPressed: () async {
                      try {
                        String goal = goalArr[_currentIndex]["title"].toString();
                        if (goal.isNotEmpty) {
                          UserProfileService userProfileService = UserProfileService();
                          await userProfileService.updateUserProfileGoal(widget.user!.uid, goal);

                          // Navegar para a próxima tela ou mostrar uma mensagem de sucesso
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WelcomeView(user: widget.user),
                            ),
                          );
                        } else {
                          // Mostrar uma mensagem de erro se o campo estiver vazio
                          print("Goal cannot be empty");
                        }
                      } catch (e) {
                        print("Error: $e");
                      }
                    }),
              ],
            ),
          )
        ],
      )),
    );
  }
}