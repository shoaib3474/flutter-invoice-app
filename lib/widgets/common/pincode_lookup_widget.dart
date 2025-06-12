import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/api/pincode_api_service.dart';
import '../../models/address/pincode_model.dart';

class PincodeLookupWidget extends StatefulWidget {
  final Function(AddressInfo) onAddressSelected;
  final String? initialPincode;
  final bool enabled;

  const PincodeLookupWidget({
    super.key,
    required this.onAddressSelected,
    this.initialPincode,
    this.enabled = true,
  });

  @override
  State<PincodeLookupWidget> createState() => _PincodeLookupWidgetState();
}

class _PincodeLookupWidgetState extends State<PincodeLookupWidget> {
  final TextEditingController _pincodeController = TextEditingController();
  bool _isLoading = false;
  List<PostOffice> _postOffices = [];
  String? _errorMessage;
  PostOffice? _selectedPostOffice;

  @override
  void initState() {
    super.initState();
    if (widget.initialPincode != null) {
      _pincodeController.text = widget.initialPincode!;
      _lookupPincode();
    }
  }

  @override
  void dispose() {
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _lookupPincode() async {
    final pincode = _pincodeController.text.trim();
    
    if (pincode.length != 6) {
      setState(() {
        _errorMessage = 'Please enter a valid 6-digit PIN code';
        _postOffices = [];
        _selectedPostOffice = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _postOffices = [];
      _selectedPostOffice = null;
    });

    try {
      final postOffices = await PincodeApiService.getAddressByPincode(pincode);
      setState(() {
        _postOffices = postOffices;
        _isLoading = false;
        if (postOffices.isNotEmpty) {
          _selectedPostOffice = postOffices.first;
          final addressInfo = AddressInfo.fromPostOffices(postOffices);
          widget.onAddressSelected(addressInfo);
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _postOffices = [];
        _selectedPostOffice = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // PIN Code Input Field
        TextFormField(
          controller: _pincodeController,
          enabled: widget.enabled,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          decoration: InputDecoration(
            labelText: 'PIN Code',
            hintText: 'Enter 6-digit PIN code',
            prefixIcon: const Icon(Icons.location_on),
            suffixIcon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: widget.enabled ? _lookupPincode : null,
                  ),
            border: const OutlineInputBorder(),
            errorText: _errorMessage,
          ),
          onChanged: (value) {
            if (value.length == 6) {
              _lookupPincode();
            } else {
              setState(() {
                _postOffices = [];
                _selectedPostOffice = null;
                _errorMessage = null;
              });
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter PIN code';
            }
            if (value.length != 6) {
              return 'PIN code must be 6 digits';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // Address Information Display
        if (_postOffices.isNotEmpty) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Address Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildAddressRow('State', _selectedPostOffice!.state),
                  _buildAddressRow('District', _selectedPostOffice!.district),
                  _buildAddressRow('Division', _selectedPostOffice!.division),
                  _buildAddressRow('Region', _selectedPostOffice!.region),
                  _buildAddressRow('PIN Code', _selectedPostOffice!.pincode),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),

          // Post Offices List
          if (_postOffices.length > 1) ...[
            const Text(
              'Available Post Offices',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                itemCount: _postOffices.length,
                itemBuilder: (context, index) {
                  final postOffice = _postOffices[index];
                  final isSelected = _selectedPostOffice == postOffice;
                  
                  return ListTile(
                    title: Text(postOffice.name),
                    subtitle: Text(
                      '${postOffice.branchType} - ${postOffice.deliveryStatus}',
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : null,
                    selected: isSelected,
                    onTap: () {
                      setState(() {
                        _selectedPostOffice = postOffice;
                      });
                      final addressInfo = AddressInfo.fromPostOffices([postOffice]);
                      widget.onAddressSelected(addressInfo);
                    },
                  );
                },
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildAddressRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
