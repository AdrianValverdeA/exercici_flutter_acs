import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weekday_selector/weekday_selector.dart';
import 'data.dart';

class ScreenSchedule extends StatefulWidget {
  final UserGroup userGroup;

  const ScreenSchedule({super.key, required this.userGroup});

  @override
  State<ScreenSchedule> createState() => _ScreenScheduleState();
}

class _ScreenScheduleState extends State<ScreenSchedule> {
  late DateTime _fromDate;
  late DateTime _toDate;
  late TimeOfDay _fromTime;
  late TimeOfDay _toTime;
  late List<bool> _weekdays;

  @override
  void initState() {
    super.initState();
    Schedule s = widget.userGroup.schedule;
    _fromDate = s.fromDate;
    _toDate = s.toDate;
    _fromTime = s.fromTime;
    _toTime = s.toTime;

    _weekdays = List.filled(7, false);
    for (int d in s.weekdays) {
      int index = d % 7;
      _weekdays[index] = true;
    }
  }

  // Funció auxiliar per mostrar l'alerta (Slide 22)
  void _showAlert(String title, String message) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(child: Text(message)),
          actions: <Widget>[
            TextButton(
              child: const Text('Accept'),
              onPressed: () { Navigator.of(context).pop(); },
            ),
          ],
        );
      },
    );
  }

  // Funció per comparar TimeOfDay
  double _toDouble(TimeOfDay myTime) => myTime.hour + myTime.minute / 60.0;

  void _saveSchedule() {
    // 1. Validació de Dates
    if (_fromDate.isAfter(_toDate)) {
      _showAlert("Range dates", "The From date is after the To date.\nPlease, select a new date range.");
      return;
    }

    // 2. Validació d'Hores
    if (_toDouble(_fromTime) >= _toDouble(_toTime)) {
      _showAlert("Range time", "The From time must be before the To time.");
      return;
    }

    // Si tot és correcte, guardem
    widget.userGroup.schedule.fromDate = _fromDate;
    widget.userGroup.schedule.toDate = _toDate;
    widget.userGroup.schedule.fromTime = _fromTime;
    widget.userGroup.schedule.toTime = _toTime;

    List<int> savedWeekdays = [];
    for (int i = 0; i < 7; i++) {
      if (_weekdays[i]) {
        int dayValue = (i == 0) ? 7 : i;
        savedWeekdays.add(dayValue);
      }
    }
    widget.userGroup.schedule.weekdays = savedWeekdays;

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Schedule ${widget.userGroup.name}"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDateRow("From", _fromDate, (date) => setState(() => _fromDate = date)),
          _buildDateRow("To", _toDate, (date) => setState(() => _toDate = date)),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text("Weekdays", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          WeekdaySelector(
            onChanged: (int day) {
              setState(() {
                final index = day % 7;
                _weekdays[index] = !_weekdays[index];
              });
            },
            values: _weekdays,
          ),
          const Divider(),
          _buildTimeRow("From", _fromTime, (time) => setState(() => _fromTime = time)),
          _buildTimeRow("To", _toTime, (time) => setState(() => _toTime = time)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _saveSchedule,
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  // ... (Els mètodes _buildDateRow i _buildTimeRow són els mateixos d'abans)
  Widget _buildDateRow(String label, DateTime current, Function(DateTime) onChange) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Row(
          children: [
            Text(DateFormat.yMd().format(current)),
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () async {
                final picked = await showDatePicker(
                    context: context,
                    initialDate: current, firstDate: DateTime(2020), lastDate: DateTime(2030));
                if (picked != null) onChange(picked);
              },
            ),
          ],
        )
      ],
    );
  }

  Widget _buildTimeRow(String label, TimeOfDay current, Function(TimeOfDay) onChange) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Row(
          children: [
            Text(current.format(context)),
            IconButton(
              icon: const Icon(Icons.access_time),
              onPressed: () async {
                final picked = await showTimePicker(context: context, initialTime: current);
                if (picked != null) onChange(picked);
              },
            ),
          ],
        )
      ],
    );
  }
}