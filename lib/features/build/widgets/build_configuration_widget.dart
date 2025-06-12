import 'package:flutter/material.dart';

class BuildConfigurationWidget extends StatelessWidget {
  final bool splitPerAbi;
  final bool obfuscate;
  final bool shrinkResources;
  final ValueChanged<bool> onSplitPerAbiChanged;
  final ValueChanged<bool> onObfuscateChanged;
  final ValueChanged<bool> onShrinkResourcesChanged;

  const BuildConfigurationWidget({
    Key? key,
    required this.splitPerAbi,
    required this.obfuscate,
    required this.shrinkResources,
    required this.onSplitPerAbiChanged,
    required this.onObfuscateChanged,
    required this.onShrinkResourcesChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Build Configuration',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // Split per ABI
            SwitchListTile(
              title: const Text('Split per ABI'),
              subtitle: const Text('Create separate APKs for different CPU architectures (recommended)'),
              value: splitPerAbi,
              onChanged: onSplitPerAbiChanged,
              secondary: const Icon(Icons.architecture),
            ),
            
            // Code Obfuscation
            SwitchListTile(
              title: const Text('Code Obfuscation'),
              subtitle: const Text('Obfuscate Dart code to make reverse engineering harder'),
              value: obfuscate,
              onChanged: onObfuscateChanged,
              secondary: const Icon(Icons.security),
            ),
            
            // Resource Shrinking
            SwitchListTile(
              title: const Text('Resource Shrinking'),
              subtitle: const Text('Remove unused resources to reduce APK size'),
              value: shrinkResources,
              onChanged: onShrinkResourcesChanged,
              secondary: const Icon(Icons.compress),
            ),
            
            const SizedBox(height: 16),
            
            // Configuration Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Build Optimization',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'These settings optimize your APK for production use. '
                    'Split per ABI creates smaller APKs for each device type. '
                    'Obfuscation protects your code. Resource shrinking reduces file size.',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
