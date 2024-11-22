import 'package:vivafit_personal_app/common/color_extension.dart';
import 'package:vivafit_personal_app/view/on_boarding/on_boarding_view.dart';
import 'package:flutter/material.dart';

import '../../common_widget/round_button.dart';

class StartedView extends StatefulWidget {
  const StartedView({super.key});

  @override
  State<StartedView> createState() => _StartedViewState();
}

class _StartedViewState extends State<StartedView> {

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: TColor.white,
      body: Container(
          width: media.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                    colors: TColor.primaryG,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight), 
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Image.asset(
                'assets/img/vivafit_logo.png',
                width: 220,
                height: 220,                
              ),
                Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Text(
                  "Seu personal trainer online",
                  style: TextStyle(
                  color: TColor.black,
                  fontSize: 18,                                  
                  ),
                ),
                ),
              const Spacer(),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  child: RoundButton(
                    title: "Iniciar",
                    type: RoundButtonType.textGradient,
                    onPressed: () async {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const OnBoardingView()));
                                return;
                    },
                  ),
                ),
              )
            ],
          )),
    );
  }
}
