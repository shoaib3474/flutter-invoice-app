import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/gstin_tracking_provider.dart';
import '../../utils/pan_validator.dart';

class PanSearchWidget extends StatefulWidget {
  final Function(String) onPanSelected;
  final bool showHistory;

  const PanSearchWidget({
    Key? key,
    required this.onPanSelected,
    this.showHistory = true,
  }) : super(key: key);

  @override
  _PanSearchWidgetState createState() => _PanSearchWidgetState();
}

class _PanSearchWidgetState extends State<PanSearchWidget> {
  final TextEditingController _panController = TextEditingController();
  String? _errorText;
  List<String> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  void _loadRecentSearches() async {
    final provider = Provider.of<GstinTrackingProvider>(context, listen: false);
    final searches = await provider.getRecentPanSearches();
    setState(() {
      _recentSearches = searches;
    });
  }

  void _searchPan() {
    final pan = _panController.text.trim().toUpperCase();
    if (pan.isEmpty) {
      setState(() {
        _errorText = 'Please enter a PAN';
      });
      return;
    }

    if (!PanValidator.isValid(pan)) {
      setState(() {
        _errorText = 'Invalid PAN format';
      });
      return;
    }

    setState(() {
      _errorText = null;
    });

    final provider = Provider.of<GstinTrackingProvider>(context, listen: false);
    provider.addToRecentPanSearches(pan);
    _loadRecentSearches();
    widget.onPanSelected(pan);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _panController,
          decoration: InputDecoration(
            labelText: 'Enter PAN',
            hintText: 'e.g., AAPFU0939F',
            errorText: _errorText,
            prefixIcon: const Icon(Icons.credit_card),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _panController.clear();
                setState(() {
                  _errorText = null;
                });
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          textCapitalization: TextCapitalization.characters,
          onChanged: (value) {
            if (_errorText != null) {
              setState(() {
                _errorText = null;
              });
            }
          },
          onSubmitted: (_) => _searchPan(),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: _searchPan,
          icon: const Icon(Icons.search),
          label: const Text('Search PAN'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
        if (widget.showHistory && _recentSearches.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'Recent Searches',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _recentSearches.map((pan) {
              return ActionChip(
                label: Text(pan),
                onPressed: () {
                  _panController.text = pan;
                  _searchPan();
                },
                avatar: const Icon(Icons.history, size: 16),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  @override
  void dispose() {
    _panController.dispose();
    super.dispose();
  }
}
