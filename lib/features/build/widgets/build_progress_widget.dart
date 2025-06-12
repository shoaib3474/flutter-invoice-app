import 'package:flutter/material.dart';

class BuildProgressWidget extends StatefulWidget {
  const BuildProgressWidget({Key? key}) : super(key: key);

  @override
  State<BuildProgressWidget> createState() => _BuildProgressWidgetState();
}

class _BuildProgressWidgetState extends State<BuildProgressWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  int _currentStep = 0;
  final List<String> _buildSteps = [
    'Cleaning previous builds...',
    'Getting dependencies...',
    'Generating code...',
    'Building APK...',
    'Optimizing resources...',
    'Signing APK...',
    'Finalizing build...',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
    
    _animationController.repeat();
    _simulateBuildProgress();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _simulateBuildProgress() async {
    for (int i = 0; i < _buildSteps.length; i++) {
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        setState(() {
          _currentStep = i;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _animation.value * 2 * 3.14159,
                      child: const Icon(
                        Icons.build,
                        color: Colors.blue,
                        size: 24,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                Text(
                  'Building APK...',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Progress indicator
            LinearProgressIndicator(
              value: (_currentStep + 1) / _buildSteps.length,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 8),
            
            Text(
              '${_currentStep + 1} of ${_buildSteps.length} steps completed',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            
            // Current step
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _currentStep < _buildSteps.length 
                        ? _buildSteps[_currentStep]
                        : 'Build completed!',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Build steps
            Column(
              children: _buildSteps.asMap().entries.map((entry) {
                final index = entry.key;
                final step = entry.value;
                final isCompleted = index < _currentStep;
                final isCurrent = index == _currentStep;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Icon(
                        isCompleted ? Icons.check_circle : 
                        isCurrent ? Icons.radio_button_checked :
                        Icons.radio_button_unchecked,
                        size: 16,
                        color: isCompleted ? Colors.green :
                               isCurrent ? Colors.blue :
                               Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          step,
                          style: TextStyle(
                            fontSize: 12,
                            color: isCompleted ? Colors.green :
                                   isCurrent ? Colors.blue :
                                   Colors.grey,
                            fontWeight: isCurrent ? FontWeight.w500 : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
