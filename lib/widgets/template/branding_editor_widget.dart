import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/template/invoice_template_model.dart';
import '../../widgets/common/custom_text_field.dart';

class BrandingEditorWidget extends StatefulWidget {
  final CompanyBranding branding;
  final Function(CompanyBranding) onBrandingChanged;

  const BrandingEditorWidget({
    Key? key,
    required this.branding,
    required this.onBrandingChanged,
  }) : super(key: key);

  @override
  State<BrandingEditorWidget> createState() => _BrandingEditorWidgetState();
}

class _BrandingEditorWidgetState extends State<BrandingEditorWidget> {
  late TextEditingController _companyNameController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _pinCodeController;
  late TextEditingController _countryController;
  late TextEditingController _gstinController;
  late TextEditingController _panController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _websiteController;
  late TextEditingController _taglineController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _companyNameController = TextEditingController(text: widget.branding.companyName);
    _addressController = TextEditingController(text: widget.branding.address);
    _cityController = TextEditingController(text: widget.branding.city);
    _stateController = TextEditingController(text: widget.branding.state);
    _pinCodeController = TextEditingController(text: widget.branding.pinCode);
    _countryController = TextEditingController(text: widget.branding.country);
    _gstinController = TextEditingController(text: widget.branding.gstin);
    _panController = TextEditingController(text: widget.branding.pan);
    _emailController = TextEditingController(text: widget.branding.email);
    _phoneController = TextEditingController(text: widget.branding.phone);
    _websiteController = TextEditingController(text: widget.branding.website ?? '');
    _taglineController = TextEditingController(text: widget.branding.tagline ?? '');

    // Add listeners to update branding when text changes
    _companyNameController.addListener(_updateBranding);
    _addressController.addListener(_updateBranding);
    _cityController.addListener(_updateBranding);
    _stateController.addListener(_updateBranding);
    _pinCodeController.addListener(_updateBranding);
    _countryController.addListener(_updateBranding);
    _gstinController.addListener(_updateBranding);
    _panController.addListener(_updateBranding);
    _emailController.addListener(_updateBranding);
    _phoneController.addListener(_updateBranding);
    _websiteController.addListener(_updateBranding);
    _taglineController.addListener(_updateBranding);
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pinCodeController.dispose();
    _countryController.dispose();
    _gstinController.dispose();
    _panController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _taglineController.dispose();
    super.dispose();
  }

  void _updateBranding() {
    final updatedBranding = widget.branding.copyWith(
      companyName: _companyNameController.text,
      address: _addressController.text,
      city: _cityController.text,
      state: _stateController.text,
      pinCode: _pinCodeController.text,
      country: _countryController.text,
      gstin: _gstinController.text,
      pan: _panController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      website: _websiteController.text.isEmpty ? null : _websiteController.text,
      tagline: _taglineController.text.isEmpty ? null : _taglineController.text,
    );
    widget.onBrandingChanged(updatedBranding);
  }

  Future<void> _pickLogo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 500,
      maxHeight: 500,
    );

    if (image != null) {
      final updatedBranding = widget.branding.copyWith(logoPath: image.path);
      widget.onBrandingChanged(updatedBranding);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLogoSection(),
          const SizedBox(height: 24),
          _buildCompanyInfoSection(),
          const SizedBox(height: 24),
          _buildContactInfoSection(),
          const SizedBox(height: 24),
          _buildTaxInfoSection(),
          const SizedBox(height: 24),
          _buildAdditionalInfoSection(),
        ],
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Company Logo',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: widget.branding.logoPath != null
              ? Stack(
                  children: [
                    Center(
                      child: Image.asset(
                        widget.branding.logoPath!,
                        height: 80,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.image_not_supported, size: 50);
                        },
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () {
                          final updatedBranding = widget.branding.copyWith(logoPath: null);
                          widget.onBrandingChanged(updatedBranding);
                        },
                      ),
                    ),
                  ],
                )
              : InkWell(
                  onTap: _pickLogo,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Tap to add logo', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
        ),
        if (widget.branding.logoPath == null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: ElevatedButton.icon(
              onPressed: _pickLogo,
              icon: const Icon(Icons.upload),
              label: const Text('Upload Logo'),
            ),
          ),
      ],
    );
  }

  Widget _buildCompanyInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Company Information',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: _companyNameController,
          label: 'Company Name',
          hint: 'Enter company name',
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _taglineController,
          label: 'Tagline (Optional)',
          hint: 'Enter company tagline',
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _addressController,
          label: 'Address',
          hint: 'Enter company address',
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _cityController,
                label: 'City',
                hint: 'Enter city',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                controller: _stateController,
                label: 'State',
                hint: 'Enter state',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _pinCodeController,
                label: 'PIN Code',
                hint: 'Enter PIN code',
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                controller: _countryController,
                label: 'Country',
                hint: 'Enter country',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact Information',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: _emailController,
          label: 'Email',
          hint: 'Enter email address',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _phoneController,
          label: 'Phone',
          hint: 'Enter phone number',
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _websiteController,
          label: 'Website (Optional)',
          hint: 'Enter website URL',
          keyboardType: TextInputType.url,
        ),
      ],
    );
  }

  Widget _buildTaxInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tax Information',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: _gstinController,
          label: 'GSTIN',
          hint: 'Enter GST identification number',
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _panController,
          label: 'PAN',
          hint: 'Enter PAN number',
        ),
      ],
    );
  }

  Widget _buildAdditionalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Information',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'This information will be displayed on your invoices. Make sure all details are accurate and up to date.',
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
