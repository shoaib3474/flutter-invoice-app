import 'package:flutter/material.dart';
import '../../models/template/template_enums.dart';

class SettingsEditorWidget extends StatelessWidget {
  final TemplateSettings settings;
  final Function(TemplateSettings) onSettingsChanged;

  const SettingsEditorWidget({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Template Settings',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Show Logo'),
            value: settings.showLogo,
            onChanged: (value) => onSettingsChanged(
              TemplateSettings(
                showLogo: value,
                showCompanyAddress: settings.showCompanyAddress,
                showGstDetails: settings.showGstDetails,
                showTermsAndConditions: settings.showTermsAndConditions,
                enableQrCode: settings.enableQrCode,
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Show Company Address'),
            value: settings.showCompanyAddress,
            onChanged: (value) => onSettingsChanged(
              TemplateSettings(
                showLogo: settings.showLogo,
                showCompanyAddress: value,
                showGstDetails: settings.showGstDetails,
                showTermsAndConditions: settings.showTermsAndConditions,
                enableQrCode: settings.enableQrCode,
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Show GST Details'),
            value: settings.showGstDetails,
            onChanged: (value) => onSettingsChanged(
              TemplateSettings(
                showLogo: settings.showLogo,
                showCompanyAddress: settings.showCompanyAddress,
                showGstDetails: value,
                showTermsAndConditions: settings.showTermsAndConditions,
                enableQrCode: settings.enableQrCode,
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Enable QR Code'),
            value: settings.enableQrCode,
            onChanged: (value) => onSettingsChanged(
              TemplateSettings(
                showLogo: settings.showLogo,
                showCompanyAddress: settings.showCompanyAddress,
                showGstDetails: settings.showGstDetails,
                showTermsAndConditions: settings.showTermsAndConditions,
                enableQrCode: value,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
