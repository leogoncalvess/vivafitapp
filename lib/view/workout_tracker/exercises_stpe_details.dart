import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';
import 'package:vivafit_personal_app/models/exercise.dart';
import 'package:vivafit_personal_app/services/exercise_service.dart';
import '../../common/color_extension.dart';
import '../../common_widget/round_button.dart';
import '../../common_widget/step_detail_row.dart';

class ExercisesStepDetails extends StatefulWidget {
  final Exercise exercise;
  const ExercisesStepDetails({super.key, required this.exercise});

  @override
  State<ExercisesStepDetails> createState() => _ExercisesStepDetailsState();
}

class _ExercisesStepDetailsState extends State<ExercisesStepDetails> {
  final ExerciseService _exerciseService = ExerciseService();

Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
  return await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirmar Exclusão'),
        content: Text('Você tem certeza que deseja excluir este exercício?'),
        actions: [
          TextButton(
            child: Text('Cancelar'),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          TextButton(
            child: Text('Excluir'),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      );
    },
  ) ?? false;
}

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.white,
        centerTitle: true,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            height: 40,
            width: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: TColor.lightGray,
                borderRadius: BorderRadius.circular(10)),
            child: Image.asset(
              "assets/img/closed_btn.png",
              width: 15,
              height: 15,
              fit: BoxFit.contain,
            ),
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String result) async {
              bool confirmDelete = await _showDeleteConfirmationDialog(context);
              if (confirmDelete) {
                await _exerciseService.deleteExercise(widget.exercise.id);
                Navigator.pop(context); // Close the screen after deletion
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'delete',
                child: Text('Excluir'),
              ),
            ],
            child: Container(
              margin: const EdgeInsets.all(8),
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: TColor.lightGray,
                  borderRadius: BorderRadius.circular(10)),
              child: Image.asset(
                "assets/img/more_btn.png",
                width: 15,
                height: 15,
                fit: BoxFit.contain,
              ),
            ),
          )
        ],
      ),
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: media.width,
                    height: media.width * 0.43,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: TColor.primaryG),
                        borderRadius: BorderRadius.circular(20)),
                    child: Image.asset(
                      "assets/img/video_temp.png",
                      width: media.width,
                      height: media.width * 0.43,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Container(
                    width: media.width,
                    height: media.width * 0.43,
                    decoration: BoxDecoration(
                        color: TColor.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Image.asset(
                      "assets/img/Play.png",
                      width: 30,
                      height: 30,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                widget.exercise.title,
                style: TextStyle(
                    color: TColor.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                "${widget.exercise.difficultyLevel} | ${widget.exercise.calorieBurn} Calories Burn",
                style: TextStyle(
                  color: TColor.gray,
                  fontSize: 12,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                "Descrição",
                style: TextStyle(
                    color: TColor.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(
                height: 4,
              ),
              ReadMoreText(
                widget.exercise.description,
                trimLines: 4,
                colorClickableText: TColor.black,
                trimMode: TrimMode.Line,
                trimCollapsedText: ' Ler mais ...',
                trimExpandedText: ' Ler menos',
                style: TextStyle(
                  color: TColor.gray,
                  fontSize: 12,
                ),
                moreStyle:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Instruções",
                    style: TextStyle(
                        color: TColor.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      "${widget.exercise.executionInstructions.length} Etapas",
                      style: TextStyle(color: TColor.gray, fontSize: 12),
                    ),
                  )
                ],
              ),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: widget.exercise.executionInstructions.length,
                itemBuilder: ((context, index) {
                  var sObj = widget.exercise.executionInstructions[index];

                  return StepDetailRow(
                    sObj: {
                      "no": (index + 1).toString().padLeft(2, '0'),
                      "title": sObj.step,
                      "detail": sObj.description,
                    },
                    isLast: widget.exercise.executionInstructions.last == sObj,
                  );
                }),
              ),
              SizedBox(
                height: 50,
              ),    
              // Text(
              //   "Custom Repetitions",
              //   style: TextStyle(
              //       color: TColor.black,
              //       fontSize: 16,
              //       fontWeight: FontWeight.w700),
              // ),
              // SizedBox(
              //   height: 150,
              //   child: CupertinoPicker.builder(
              //     itemExtent: 40,
              //     selectionOverlay: Container(
              //       width: double.maxFinite,
              //       height: 40,
              //       decoration: BoxDecoration(
              //         border: Border(
              //           top: BorderSide(color: TColor.gray.withOpacity(0.2), width: 1),
              //           bottom: BorderSide(
              //               color: TColor.gray.withOpacity(0.2), width: 1),
              //         ),
              //       ),
              //     ),
              //     onSelectedItemChanged: (index) {},
              //     childCount: 60,
              //     itemBuilder: (context, index) {
              //       return Row(
              //         mainAxisAlignment: MainAxisAlignment.center,
              //         children: [
              //           Image.asset(
              //             "assets/img/burn.png",
              //             width: 15,
              //             height: 15,
              //             fit: BoxFit.contain,
              //           ),
              //           Text(
              //             " ${(index + 1) * 15} Calories Burn",
              //             style: TextStyle(color: TColor.gray, fontSize: 10),
              //           ),
              //           Text(
              //             " ${index + 1} ",
              //             style: TextStyle(
              //                 color: TColor.gray,
              //                 fontSize: 24,
              //                 fontWeight: FontWeight.w500),
              //           ),
              //           Text(
              //             " times",
              //             style: TextStyle(color: TColor.gray, fontSize: 16),
              //           )
              //         ],
              //       );
              //     },
              //   ),
              // ),
              // RoundButton(title: "Save", elevation: 0, onPressed: () async {}),
              // const SizedBox(
              //   height: 15,
              // ),
            ],
          ),
        ),
      ),
    );
  }
}