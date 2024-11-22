import 'package:vivafit_personal_app/common_widget/on_boarding_page.dart';
import 'package:vivafit_personal_app/view/login/signup_view.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/color_extension.dart';

class OnBoardingView extends StatefulWidget {
  const OnBoardingView({super.key});

  @override
  State<OnBoardingView> createState() => _OnBoardingViewState();
}

class _OnBoardingViewState extends State<OnBoardingView> {
  int selectPage = 0;
  PageController controller = PageController();

  Future<void> setOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingCompleted', true);
  }

  @override
  void initState() {
    super.initState();

    controller.addListener(() {
        selectPage = controller.page?.round() ?? 0;

      setState(() {
        
      });
    });
  }

  List pageArr = [
    {
      "title": "Acompanhe seu progresso",
      "subtitle":
          "Não se preocupe se tiver problemas para acompanhar seus objetivos. Podemos ajudá-lo a definir e monitorar seus objetivos",
      "image": "assets/img/on_1.png"
    },
    {
      "title": "Queime calorias",
      "subtitle":
          "Vamos queimar calorias, para alcançar seus objetivos, criamos o seu treino de forma personalizada.",
      "image": "assets/img/on_2.png"
    },
    {
      "title": "Coma bem",
      "subtitle":
          "Vamos começar um estilo de vida saudável conosco, podemos determinar sua dieta todos os dias. alimentação saudável é divertido.",
      "image": "assets/img/on_3.png"
    },
    {
      "title": "Melhore a qualidade\ndo seu sono",
      "subtitle":
          "Melhore a qualidade do seu sono conosco, um sono de boa qualidade pode trazer bom humor pela manhã",
      "image": "assets/img/on_4.png"
    },
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: TColor.white,
      body: Stack(
        alignment: Alignment.bottomRight,
        children: [
          PageView.builder(
              controller: controller,
              itemCount: pageArr.length,
              itemBuilder: (context, index) {
                var pObj = pageArr[index] as Map? ?? {};
                return OnBoardingPage(pObj: pObj) ;
              }),

          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [

                SizedBox(
                  width: 70,
                  height: 70,
                  child: CircularProgressIndicator(
                    color: TColor.primaryColor1,
                    value: (selectPage + 1) / 4 ,
                    strokeWidth: 2,
                  ),
                ),

                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(color: TColor.primaryColor1, borderRadius: BorderRadius.circular(35)),
                  child: IconButton(icon: Icon( Icons.navigate_next, color: TColor.white, ), onPressed: (){
          
                      if(selectPage < 3) {
          
                         selectPage = selectPage + 1;

                        controller.animateToPage(selectPage, duration: const Duration(milliseconds: 600), curve: Curves.decelerate);
                        
                        // controller.jumpToPage(selectPage);
                        
                          setState(() {
                            
                          });
          
                      }else{
                        // Open Welcome Screen
                        print("Open Welcome Screen");
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpView() ));
                      }
                      
                  },),
                ),

                
              ],
            ),
          )
        ],
      ),
    );
  }
}
