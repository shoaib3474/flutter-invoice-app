import 'package:flutter/material.dart';
import '../../utils/gstin_validator.dart';

class GstinSearchWidget extends StatefulWidget {
  final Function(String) onGstinSelected;
  final String? initialGstin;

  const GstinSearchWidget({
    super.key,
    required this.onGstinSelected,
    this.initialGstin,
  });

  @override
  State<GstinSearchWidget> createState() => _GstinSearchWidgetState();
}

class _GstinSearchWidgetState extends State<GstinSearchWidget> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialGstin != null) {
      _controller.text = widget.initialGstin!;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _searchGstin() {
    final gstin = _controller.text.trim().toUpperCase();
    
    if (!GstinValidator.isValid(gstin)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid GSTIN'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        widget.onGstinSelected(gstin);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Search GSTIN',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Enter GSTIN',
                      hintText: '22AAAAA0000A1Z5',
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.characters,
                    maxLength: 15,
                    validator: GstinValidator.validate,
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _searchGstin,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Search'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
