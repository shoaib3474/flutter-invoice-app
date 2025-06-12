import 'package:flutter/material.dart';
import 'package:flutter_invoice_app/utils/asset_compressor.dart';
import 'package:flutter_invoice_app/utils/build_helper.dart';
import 'package:flutter_invoice_app/utils/memory_optimizer.dart';
import 'package:flutter_invoice_app/utils/responsive_helper.dart';
import 'package:flutter_invoice_app/widgets/common/custom_button.dart';
import 'package:flutter_invoice_app/widgets/common/loading_indicator.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class AppOptimizationScreen extends StatefulWidget {
  const AppOptimizationScreen({Key? key}) : super(key: key);

  @override
  State<AppOptimizationScreen> createState() => _AppOptimizationScreenState();
}

class _AppOptimizationScreenState extends State<AppOptimizationScreen> {
  final MemoryOptimizer _memoryOptimizer = MemoryOptimizer();
  final AssetCompressor _assetCompressor = AssetCompressor();
  final BuildHelper _buildHelper = BuildHelper();
  
  bool _isLoading = false;
  String _cacheSize = '0 B';
  String _appVersion = '';
  String _buildMessage = '';
  bool _isBuildSuccessful = false;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Get cache size
      final int cacheSize = await _memoryOptimizer.getAppCacheSize();
      _cacheSize = _memoryOptimizer.formatSize(cacheSize);
      
      // Get app version
      _appVersion = await _buildHelper.getAppVersion();
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _clearCache() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await _memoryOptimizer.clearAppCache();
      await _assetCompressor.clearCache();
      
      // Refresh cache size
      final int cacheSize = await _memoryOptimizer.getAppCacheSize();
      _cacheSize = _memoryOptimizer.formatSize(cacheSize);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cache cleared successfully')),
      );
    } catch (e) {
      print('Error clearing cache: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error clearing cache: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _buildOptimizedApk() async {
    setState(() {
      _isLoading = true;
      _buildMessage = 'Building optimized APK...';
      _isBuildSuccessful = false;
    });
    
    try {
      final String? apkPath = await _buildHelper.buildOptimizedApk();
      
      if (apkPath != null) {
        setState(() {
          _buildMessage = 'APK built successfully: $apkPath';
          _isBuildSuccessful = true;
        });
      } else {
        setState(() {
          _buildMessage = 'Failed to build APK';
          _isBuildSuccessful = false;
        });
      }
    } catch (e) {
      print('Error building APK: $e');
      setState(() {
        _buildMessage = 'Error building APK: $e';
        _isBuildSuccessful = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Optimization'),
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : SingleChildScrollView(
              padding: ResponsiveHelper.getScreenPadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App info section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'App Information',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow('App Version', _appVersion),
                          _buildInfoRow('Cache Size', _cacheSize),
                          const SizedBox(height: 16),
                          CustomButton(
                            onPressed: _clearCache,
                            text: 'Clear Cache',
                            icon: Icons.cleaning_services,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Build optimization section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Build Optimization',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Build an optimized APK with reduced size and improved performance.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          if (_buildMessage.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _isBuildSuccessful
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _isBuildSuccessful
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                              child: Text(
                                _buildMessage,
                                style: TextStyle(
                                  color: _isBuildSuccessful
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          CustomButton(
                            onPressed: _buildOptimizedApk,
                            text: 'Build Optimized APK',
                            icon: Icons.build,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Performance tips section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Performance Tips',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          _buildTipItem(
                            'Use compressed images',
                            'Compress images to reduce app size and improve loading times.',
                          ),
                          _buildTipItem(
                            'Enable R8 shrinking',
                            'R8 shrinks, optimizes, and obfuscates your code to reduce APK size.',
                          ),
                          _buildTipItem(
                            'Split APKs by ABI',
                            'Create separate APKs for different CPU architectures to reduce download size.',
                          ),
                          _buildTipItem(
                            'Use App Bundle',
                            'Android App Bundle delivers optimized APKs for each device configuration.',
                          ),
                          _buildTipItem(
                            'Lazy load resources',
                            'Load resources only when needed to improve startup time.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }
  
  Widget _buildTipItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline, color: Colors.amber),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(description),
        ],
      ),
    );
  }
}
