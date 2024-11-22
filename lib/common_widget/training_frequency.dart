import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class TrainingFrequency extends StatefulWidget {
  final Map<DateTime, Map<String, int>> trainingData;

  TrainingFrequency({required this.trainingData});

  @override
  _TrainingFrequencyState createState() => _TrainingFrequencyState();
}

class _TrainingFrequencyState extends State<TrainingFrequency> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String _selectedPeriod = "week";
  bool _showGasto = true;
  bool _showConsumo = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildCalendar(),
        //_buildPeriodSelector(),
        //_buildToggleButtons(),
        //const SizedBox(height: 10),
        //_buildIntensityChart(),
      ],
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      locale: 'pt_BR',
      firstDay: DateTime.utc(2020, 1, 1),// TODO: Alterar para a data do primeiro treino
      lastDay: DateTime.utc(DateTime.now().year, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,      
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      onPageChanged: (focusedDay) => _focusedDay = focusedDay,
      daysOfWeekStyle: const DaysOfWeekStyle(
        weekdayStyle: TextStyle(color: Colors.grey, fontSize: 12),
        weekendStyle: TextStyle(color: Colors.grey, fontSize: 12),
      ),
      calendarStyle: const CalendarStyle(        
        todayDecoration: BoxDecoration(          
          color: Colors.blueAccent,
          shape: BoxShape.circle,          
        ),
        selectedDecoration: BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
        ),
        markerDecoration: BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
        ),
        markersMaxCount: 1,
        outsideDaysVisible: false,      
        cellMargin: EdgeInsets.all(8.0),
      ),
      headerStyle: const HeaderStyle(
        formatButtonShowsNext: false,
        formatButtonVisible: false,
        titleCentered: true,
        leftChevronVisible: false,
        rightChevronVisible: false,
        headerPadding: EdgeInsets.symmetric(vertical: 10),        
      ),
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) {
          bool trained = widget.trainingData[day]?['gasto'] != null &&
                         widget.trainingData[day]!['gasto']! > 0;
          return Container(
            width: 38, 
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: trained ? Colors.green : Colors.grey[300],              
            ),
            child: Center(
              child: Text('${day.day}', style: const TextStyle(color: Colors.white)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPeriodButton("Semana", "week"),
        _buildPeriodButton("Mês", "month"),
        _buildPeriodButton("Ano", "year"),
      ],
    );
  }

  Widget _buildPeriodButton(String label, String period) {
    return TextButton(
      onPressed: () => setState(() => _selectedPeriod = period),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: _selectedPeriod == period ? Colors.blue : Colors.grey,
        ),
      ),
    );
  }

  Widget _buildToggleButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FilterChip(
          label: const Text("Gasto Calórico"),
          selected: _showGasto,
          onSelected: (selected) => setState(() => _showGasto = selected),
          selectedColor: Colors.blue,
        ),
        const SizedBox(width: 10),
        FilterChip(
          label: const Text("Consumo Calórico"),
          selected: _showConsumo,
          onSelected: (selected) => setState(() => _showConsumo = selected),
          selectedColor: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildIntensityChart() {
    List<int> gastoData;
    List<int> consumoData;

    switch (_selectedPeriod) {
      case "month":
        gastoData = _getMonthlyData('gasto');
        consumoData = _getMonthlyData('consumo');
        break;
      case "year":
        gastoData = _getYearlyData('gasto');
        consumoData = _getYearlyData('consumo');
        break;
      default:
        gastoData = _getWeeklyData('gasto');
        consumoData = _getWeeklyData('consumo');
    }

    return _buildBarChart("Gasto e Consumo Calórico", gastoData, consumoData);
  }

  Widget _buildBarChart(String title, List<int> gastoData, List<int> consumoData) {
    return SizedBox(
      height: 150, // Altura reduzida para ocupar menos espaço
      child: BarChart(
        BarChartData(
          barGroups: List.generate(gastoData.length, (index) {
            int gasto = gastoData[index];
            int consumo = consumoData[index];
            List<BarChartRodData> barRods = [];
            if (_showGasto) {
              barRods.add(BarChartRodData(
                toY: gasto.toDouble(),
                color: Colors.blue,
                width: 8,
                borderRadius: BorderRadius.circular(4),
              ));
            }
            if (_showConsumo) {
              barRods.add(BarChartRodData(
                toY: consumo.toDouble(),
                color: Colors.orange,
                width: 8,
                borderRadius: BorderRadius.circular(4),
              ));
            }
            return BarChartGroupData(x: index, barRods: barRods);
          }),
          titlesData: const FlTitlesData(show: false),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  // Funções para obter dados semanais, mensais e anuais
  List<int> _getWeeklyData(String type) {
    DateTime today = DateTime.now();
    DateTime startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    return List.generate(7, (index) {
      DateTime day = startOfWeek.add(Duration(days: index));
      return widget.trainingData[day]?[type] ?? 0;
    });
  }

  List<int> _getMonthlyData(String type) {
    DateTime today = DateTime.now();
    DateTime startOfMonth = DateTime(today.year, today.month, 1);
    return List.generate(30, (index) {
      DateTime day = startOfMonth.add(Duration(days: index));
      return widget.trainingData[day]?[type] ?? 0;
    });
  }

  List<int> _getYearlyData(String type) {
    DateTime today = DateTime.now();
    return List.generate(12, (index) {
      DateTime month = DateTime(today.year, today.month - index, 1);
      return _getMonthlySum(month, type);
    });
  }

  int _getMonthlySum(DateTime month, String type) {
    int sum = 0;
    for (int i = 0; i < 31; i++) {
      DateTime day = DateTime(month.year, month.month, i + 1);
      sum += widget.trainingData[day]?[type] ?? 0;
    }
    return sum;
  }
}

// Função de exemplo para gerar uma massa de dados com gasto e consumo calórico
Map<DateTime, Map<String, int>> generateMonthlyTrainingData() {
  final random = Random();
  final trainingData = <DateTime, Map<String, int>>{};

  DateTime today = DateTime.now();
  DateTime startOfMonth = DateTime(today.year, today.month, 1);

  for (int i = 0; i < 30; i++) {
    DateTime day = startOfMonth.add(Duration(days: i));
    bool trained = random.nextBool(); 
    int gasto = trained ? random.nextInt(500) + 100 : 0;
    int consumo = trained ? random.nextInt(800) + 500 : random.nextInt(500) + 200;
    trainingData[day] = {'gasto': gasto, 'consumo': consumo};
  }

  return trainingData;
}
