import 'package:flutter/material.dart';

class Quarter {
  final int quarter;
  final int year;
  final String display;

  Quarter({required this.quarter, required this.year})
      : display = 'Q$quarter ${year.toString()}';

  @override
  String toString() => display;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Quarter &&
          runtimeType == other.runtimeType &&
          quarter == other.quarter &&
          year == other.year;

  @override
  int get hashCode => quarter.hashCode ^ year.hashCode;
}

class QuarterPickerWidget extends StatefulWidget {
  final Quarter? initialQuarter;
  final Function(Quarter) onQuarterSelected;
  final String labelText;
  final String? helperText;
  final bool isRequired;
  final int? startYear;
  final int? endYear;

  const QuarterPickerWidget({
    Key? key,
    this.initialQuarter,
    required this.onQuarterSelected,
    required this.labelText,
    this.helperText,
    this.isRequired = false,
    this.startYear,
    this.endYear,
  }) : super(key: key);

  @override
  _QuarterPickerWidgetState createState() => _QuarterPickerWidgetState();
}

class _QuarterPickerWidgetState extends State<QuarterPickerWidget> {
  late Quarter _selectedQuarter;
  late List<Quarter> _quarters;

  @override
  void initState() {
    super.initState();
    _initializeQuarters();
    _selectedQuarter = widget.initialQuarter ?? _quarters.first;
  }

  void _initializeQuarters() {
    final currentYear = DateTime.now().year;
    final startYear = widget.startYear ?? (currentYear - 5);
    final endYear = widget.endYear ?? currentYear;
    
    _quarters = [];
    for (int year = endYear; year >= startYear; year--) {
      for (int quarter = 4; quarter >= 1; quarter--) {
        _quarters.add(Quarter(quarter: quarter, year: year));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<Quarter>(
      decoration: InputDecoration(
        labelText: widget.labelText + (widget.isRequired ? ' *' : ''),
        helperText: widget.helperText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      value: _selectedQuarter,
      items: _quarters.map((Quarter quarter) {
        return DropdownMenuItem<Quarter>(
          value: quarter,
          child: Text(quarter.display),
        );
      }).toList(),
      onChanged: (Quarter? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedQuarter = newValue;
          });
          widget.onQuarterSelected(newValue);
        }
      },
    );
  }
}
