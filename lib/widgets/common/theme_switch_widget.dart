import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_invoice_app/providers/theme_provider.dart';

class ThemeSwitch extends StatelessWidget {
  final bool showLabel;
  
  const ThemeSwitch({
    Key? key,
    this.showLabel = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel) ...[
          const Icon(Icons.wb_sunny_outlined),
          const SizedBox(width: 8),
        ],
        Switch(
          value: themeProvider.isDarkMode,
          onChanged: (_) {
            themeProvider.toggleTheme();
          },
        ),
        if (showLabel) ...[
          const SizedBox(width: 8),
          const Icon(Icons.nightlight_round),
        ],
      ],
    );
  }
}
