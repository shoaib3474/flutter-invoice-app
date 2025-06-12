import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Month {
  final int month;
  final int year;
  final String display;

  Month({required this.month, required this.year})
      : display = '${DateFormat('MMMM').format(DateTime(year, month))} ${year.toString()}';

  @override
  String toString() => display;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Month &&
          runtimeType == other.runtimeType &&
          month == other.month &&
          year == other.year;

  @override
  int get hashCode => month.hashCode ^ year.hashCode;
}

class MonthPickerWidget extends StatefulWidget {
  final Month? initialMonth;
  final Function(Month) onMonthSelected;
  final String labelText;
  final String? helperText;
  final bool isRequired;
  final int? startYear;
  final int? endYear;

  const MonthPickerWidget({
    Key? key,
    this.initialMonth,
    required this.onMonthSelected,
    required this.labelText,
    this.helperText,
    this.isRequired = false,
    this.startYear,
    this.endYear,
  }) : super(key: key);

  @override
  _MonthPickerWidgetState createState() => _MonthPickerWidgetState();
}

class _MonthPickerWidgetState extends State<MonthPickerWidget> {
  late Month _selectedMonth;
  late List<Month> _months;

  @override
  void initState() {
    super.initState();
    _initializeMonths();
    _selectedMonth = widget.initialMonth ?? _months.first;
  }

  void _initializeMonths() {
    final currentYear = DateTime.now().year;
    final startYear = widget.startYear ?? (currentYear - 5);
    final endYear = widget.endYear ?? currentYear;
    
    _months = [];
    for (int year = endYear; year >= startYear; year--) {
      for (int month = 12; month >= 1; month--) {
        _months.add(Month(month: month, year: year));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<Month>(
      decoration: InputDecoration(
        labelText: widget.labelText + (widget.isRequired ? ' *' : ''),
        helperText: widget.helperText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      value: _selectedMonth,
      items: _months.map((Month month) {
        return DropdownMenuItem<Month>(
          value: month,
          child: Text(month.display),
        );
      }).toList(),
      onChanged: (Month? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedMonth = newValue;
          });
          widget.onMonthSelected(newValue);
        }
      },
    );
  }
}
