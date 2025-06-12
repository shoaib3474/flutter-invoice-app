import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/hsn_sac_provider.dart';
import '../../models/hsn_sac/hsn_sac_model.dart';

class HsnSacSearchWidget extends StatefulWidget {
  final Function(HsnSacModel) onCodeSelected;
  final bool showHistory;
  final bool isSacMode;

  const HsnSacSearchWidget({
    Key? key,
    required this.onCodeSelected,
    this.showHistory = true,
    this.isSacMode = false,
  }) : super(key: key);

  @override
  _HsnSacSearchWidgetState createState() => _HsnSacSearchWidgetState();
}

class _HsnSacSearchWidgetState extends State<HsnSacSearchWidget> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _errorText;
  List<HsnSacModel> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
  }

  void _searchCode() async {
    final code = _codeController.text.trim();
    final description = _descriptionController.text.trim();
    
    if (code.isEmpty && description.isEmpty) {
      setState(() {
        _errorText = 'Please enter a code or description';
      });
      return;
    }

    setState(() {
      _errorText = null;
      _isSearching = true;
      _hasSearched = true;
    });

    try {
      final provider = Provider.of<HsnSacProvider>(context, listen: false);
      final results = await provider.searchCodes(
        code: code.isNotEmpty ? code : null,
        description: description.isNotEmpty ? description : null,
        isSac: widget.isSacMode,
      );
      
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _errorText = 'Error searching: $e';
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _codeController,
          decoration: InputDecoration(
            labelText: widget.isSacMode ? 'Enter SAC Code' : 'Enter HSN Code',
            hintText: widget.isSacMode ? 'e.g., 998431' : 'e.g., 8471',
            errorText: _errorText,
            prefixIcon: const Icon(Icons.numbers),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _codeController.clear();
                setState(() {
                  _errorText = null;
                });
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            if (_errorText != null) {
              setState(() {
                _errorText = null;
              });
            }
          },
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _descriptionController,
          decoration: InputDecoration(
            labelText: 'Description',
            hintText: 'e.g., computer parts',
            prefixIcon: const Icon(Icons.description),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _descriptionController.clear();
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _isSearching ? null : _searchCode,
          icon: _isSearching 
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.search),
          label: Text(_isSearching ? 'Searching...' : 'Search'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
        if (_hasSearched) ...[
          const SizedBox(height: 16),
          Text(
            'Search Results (${_searchResults.length})',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          if (_isSearching)
            const Center(
              child: CircularProgressIndicator(),
            )
          else if (_searchResults.isEmpty)
            const Center(
              child: Text('No results found'),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final item = _searchResults[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(
                      widget.isSacMode 
                          ? 'SAC: ${item.code}' 
                          : 'HSN: ${item.code}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.description),
                        const SizedBox(height: 4),
                        Text('GST Rate: ${item.gstRate}%'),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      widget.onCodeSelected(item);
                    },
                  ),
                );
              },
            ),
        ],
      ],
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
