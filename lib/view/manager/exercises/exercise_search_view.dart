import 'package:flutter/material.dart';
import 'package:vivafit_personal_app/common/color_extension.dart';
import 'package:vivafit_personal_app/models/exercise.dart';
import 'package:vivafit_personal_app/models/paginated_exercises.dart';
import 'package:vivafit_personal_app/services/exercise_service.dart';
import 'package:vivafit_personal_app/common_widget/round_button.dart';
import 'package:vivafit_personal_app/common_widget/round_textfield.dart';
import 'package:vivafit_personal_app/common_widget/exercises_row.dart';
import 'package:vivafit_personal_app/view/manager/create_exercise_view.dart';
import 'package:vivafit_personal_app/view/manager/exercises/exercise_importation_view.dart';
import 'package:vivafit_personal_app/view/workout_tracker/exercises_stpe_details.dart';

class ExerciseSearchView extends StatefulWidget {
  final Function(Exercise) onExerciseSelected;

  ExerciseSearchView({required this.onExerciseSelected});

  @override
  _ExerciseSearchViewState createState() => _ExerciseSearchViewState();
}

class _ExerciseSearchViewState extends State<ExerciseSearchView> {
  List<Exercise> exercises = [];
  List<Exercise> filteredExercises = [];
  String? selectedCategory = 'Todas';
  TextEditingController searchController = TextEditingController();
  final ExerciseService _exerciseService = ExerciseService();
  final List<String> categories = [
    'Todas',
    'Peito',
    'Costas',
    'Pernas',
    'Ombros',
    'Braços',
    'Glúteos',
    'Abdômen',
    'Core',
    'Cardio',
    'Exercícios Funcionais'
  ];
  final ScrollController _scrollController = ScrollController();
  bool isLoading = false;
  bool hasMore = true;
  final int itemsPerPage = 10;
  List<Exercise> selectedExercises = [];

void _selectExercise(Exercise exercise) {
  setState(() {
    if (selectedExercises.contains(exercise)) {
      selectedExercises.remove(exercise);
    } else {
      selectedExercises.add(exercise);
    }
  });
}

  @override
  void dispose() {
    _exerciseService.resetPagination();
    searchController.removeListener(() {
      filterExercises(searchController.text);
    });
    searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadExercises();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !isLoading && hasMore) {
        _loadMoreExercises();
      }
    });
    searchController.addListener(() {
      filterExercises(searchController.text);
    });
  }

  Future<void> _loadExercises() async {
    setState(() {
      isLoading = true;
    });
    PaginatedExercises result = await _exerciseService.searchExercisesWithPagination(category: selectedCategory!, limit: itemsPerPage);
    List<Exercise> newExercises = result.exercises;
    setState(() {
      exercises = newExercises;
      hasMore = result.hasMore;
      filterExercises(searchController.text);
      isLoading = false;
    });
  }

  Future<void> _loadMoreExercises() async {
    setState(() {
      isLoading = true;
    });
    PaginatedExercises result = await _exerciseService.loadMoreExercises(category: selectedCategory!, limit: itemsPerPage);
    List<Exercise> moreExercises = result.exercises;
    setState(() {
      exercises.addAll(moreExercises);
      hasMore = result.hasMore;
      filterExercises(searchController.text);
      isLoading = false;
    });
  }

  void filterExercises(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredExercises = exercises;
      });
      return;
    }

    List<Exercise> filteredList = exercises.where((exercise) {
      bool matchesCategory = selectedCategory == null || selectedCategory == 'Todas' || exercise.category == selectedCategory;
      bool matchesQuery = exercise.title.toLowerCase().contains(query.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();

    setState(() {
      filteredExercises = filteredList;
    });
  }

  void _navigateToImportation() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ExerciseImportationView(),
      ),
    );
    _loadExercises();
  }

  void _navigateToCreate() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateExerciseView(),
      ),
    );
    _loadExercises();
  }

  @override
  Widget build(BuildContext context) {    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.white,
        centerTitle: true,
        elevation: 0,
        title: Text(
        "Administração de treinos",
        style: TextStyle(
              color: TColor.black, fontSize: 16, fontWeight: FontWeight.w700),
        ),
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
      ),
      backgroundColor: TColor.white,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                RoundTextField(
                  controller: TextEditingController(text: selectedCategory),
                  hitText: "Selecione uma categoria",
                  icon: 'assets/img/choose_workout.png',
                  margin: EdgeInsets.only(bottom: 16.0),
                  keyboardType: TextInputType.text,
                  dropdownItems: categories,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCategory = newValue;
                    });
                    _exerciseService.resetPagination();
                    _loadExercises();
                  },
                ),
                RoundTextField(
                  controller: searchController,
                  hitText: "Pesquisar Exercícios",
                  icon: 'assets/img/search.png',
                  margin: EdgeInsets.only(bottom: 16.0),
                  rigtIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      filterExercises(searchController.text);
                    },
                  ),
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    shrinkWrap: true,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: filteredExercises.length + (isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == filteredExercises.length) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      Exercise exercise = filteredExercises[index];  
                      bool isSelected = selectedExercises.contains(exercise);                    
                      return ExercisesRow(
                        eObj: {
                          "image": "assets/img/what_3.png",
                          "title": exercise.title,
                          "value": exercise.description,
                          "category": exercise.category,
                          "id": exercise.id
                        },
                        onPressed: () {
                          _selectExercise(exercise);
                        },
                        isSelected: isSelected,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 30),
                SafeArea(
                  child: Column(
                    children: [
                      RoundButton(
                        title: "Confirmar Seleção",
                        onPressed: () async {
                          Navigator.pop(context, selectedExercises);
                        },
                      ),
                      // const SizedBox(height: 16),
                      // RoundButton(
                      //   title: "Importar Exercícios",
                      //   onPressed: () async {
                      //     _navigateToImportation();
                      //   },
                      // ),
                      const SizedBox(height: 16),
                      RoundButton(
                        title: "Criar Exercício",
                        onPressed: () async {
                          _navigateToCreate();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}