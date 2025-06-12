import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_invoice_app/services/settings/logo_service.dart';
import 'package:flutter_invoice_app/widgets/common/custom_button.dart';
import 'package:flutter_invoice_app/widgets/common/loading_indicator.dart';

class LogoSettingsScreen extends StatefulWidget {
  const LogoSettingsScreen({Key? key}) : super(key: key);

  @override
  _LogoSettingsScreenState createState() => _LogoSettingsScreenState();
}

class _LogoSettingsScreenState extends State<LogoSettingsScreen> {
  final LogoService _logoService = LogoService();
  bool _isLoading = false;
  String? _logoPath;
  bool _hasCustomLogo = false;

  @override
  void initState() {
    super.initState();
    _loadLogoStatus();
  }

  Future<void> _loadLogoStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final hasCustomLogo = await _logoService.hasCustomLogo();
      setState(() {
        _hasCustomLogo = hasCustomLogo;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackbar('Failed to load logo status: $e');
    }
  }

  Future<void> _pickLogoFromGallery() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _logoService.setLogoFromGallery();
      if (success) {
        await _loadLogoStatus();
        if (mounted) {
          _showSuccessSnackbar('Logo updated successfully');
        }
      } else {
        _showErrorSnackbar('Failed to update logo');
      }
    } catch (e) {
      _showErrorSnackbar('Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickLogoFromCamera() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _logoService.setLogoFromCamera();
      if (success) {
        await _loadLogoStatus();
        if (mounted) {
          _showSuccessSnackbar('Logo updated successfully');
        }
      } else {
        _showErrorSnackbar('Failed to update logo');
      }
    } catch (e) {
      _showErrorSnackbar('Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resetToDefaultLogo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _logoService.resetToDefaultLogo();
      if (success) {
        await _loadLogoStatus();
        if (mounted) {
          _showSuccessSnackbar('Reset to default logo');
        }
      } else {
        _showErrorSnackbar('Failed to reset logo');
      }
    } catch (e) {
      _showErrorSnackbar('Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Logo Settings'),
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Company Logo',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Your logo will appear on all invoices and other documents. For best results, use a square image with transparent background.',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: FutureBuilder<dynamic>(
                      future: _logoService.getLogoBytes(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const SizedBox(
                            width: 150,
                            height: 150,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        
                        if (snapshot.hasError || !snapshot.hasData) {
                          return Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                            ),
                          );
                        }
                        
                        return Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              snapshot.data,
                              fit: BoxFit.contain,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomButton(
                        text: 'Gallery',
                        icon: Icons.photo_library,
                        color: Colors.blue,
                        onPressed: _pickLogoFromGallery,
                      ),
                      const SizedBox(width: 16),
                      CustomButton(
                        text: 'Camera',
                        icon: Icons.camera_alt,
                        color: Colors.green,
                        onPressed: _pickLogoFromCamera,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_hasCustomLogo)
                    Center(
                      child: CustomButton(
                        text: 'Reset to Default',
                        icon: Icons.restore,
                        color: Colors.red,
                        onPressed: _resetToDefaultLogo,
                      ),
                    ),
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    'Logo Guidelines',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildGuidelineItem(
                    icon: Icons.aspect_ratio,
                    title: 'Recommended Size',
                    description: '500 x 500 pixels or similar square aspect ratio',
                  ),
                  _buildGuidelineItem(
                    icon: Icons.format_paint,
                    title: 'File Format',
                    description: 'PNG or JPG format (PNG with transparency recommended)',
                  ),
                  _buildGuidelineItem(
                    icon: Icons.photo_size_select_small,
                    title: 'File Size',
                    description: 'Keep under 1MB for optimal performance',
                  ),
                  _buildGuidelineItem(
                    icon: Icons.remove_red_eye,
                    title: 'Visibility',
                    description: 'Ensure logo is clearly visible on white background',
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildGuidelineItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
