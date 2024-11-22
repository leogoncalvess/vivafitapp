import 'package:flutter/material.dart';

import '../../common/color_extension.dart';
import '../../common_widget/round_button.dart';

class FinishedWorkoutView extends StatefulWidget {
  const FinishedWorkoutView({super.key});

  @override
  State<FinishedWorkoutView> createState() => _FinishedWorkoutViewState();
}

class _FinishedWorkoutViewState extends State<FinishedWorkoutView> {
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
        
              const SizedBox(height: 20,),
              Image.asset(
                "assets/img/complete_workout.png",
                height: media.width * 0.8,
                fit: BoxFit.fitHeight,
              ),
        
              const SizedBox(
                height: 20,
              ),
        
              Text(
                "Parabéns, você terminou seu treino",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: TColor.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              Text(
                "Sua dedicação está te levando cada vez mais longe. Continue firme, você está arrasando!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: TColor.gray,
                  fontSize: 12,
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              const Spacer(),
               RoundButton(
                  title: "Voltar",
                  onPressed: () async {
                    Navigator.pop(context);
                    return;
                  }),

                 const SizedBox(
                height: 8,
              ),



            ],
          ),
        ),
      ),
    );
  }
}
