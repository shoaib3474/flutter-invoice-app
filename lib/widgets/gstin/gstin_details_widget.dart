import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/gstin/gstin_details_model.dart';
import 'jurisdiction_info_widget.dart';

class GstinDetailsWidget extends StatelessWidget {
  final GstinDetailsModel details;
  final VoidCallback? onTrackGstin;

  const GstinDetailsWidget({
    Key? key,
    required this.details,
    this.onTrackGstin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'GSTIN Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (onTrackGstin != null)
                  TextButton.icon(
                    onPressed: onTrackGstin,
                    icon: const Icon(Icons.track_changes),
                    label: const Text('Track GSTIN'),
                  ),
              ],
            ),
            const Divider(),
            _buildInfoRow('GSTIN', details.gstin, true),
            _buildInfoRow('Legal Name', details.legalName),
            _buildInfoRow('Trade Name', details.tradeName),
            _buildInfoRow('PAN', details.pan, true),
            _buildInfoRow('Status', details.status),
            _buildInfoRow('Registration Date', details.registrationDate),
            _buildInfoRow('Business Type', details.businessType),
            _buildInfoRow('Taxpayer Type', details.taxpayerType),
            const SizedBox(height: 16),
            const Text(
              'Address',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            _buildInfoRow('Building', details.address.building),
            _buildInfoRow('Floor', details.address.floor),
            _buildInfoRow('Street', details.address.street),
            _buildInfoRow('Location', details.address.location),
            _buildInfoRow('City', details.address.city),
            _buildInfoRow('District', details.address.district),
            _buildInfoRow('State', details.address.state),
            _buildInfoRow('Pincode', details.address.pincode),
            const SizedBox(height: 16),
            JurisdictionInfoWidget(jurisdiction: details.jurisdiction),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, [bool copyable = false]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (copyable)
            IconButton(
              icon: const Icon(Icons.copy, size: 16),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$label copied to clipboard'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              tooltip: 'Copy to clipboard',
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(4),
            ),
        ],
      ),
    );
  }
}
