import 'package:flutter/material.dart';
import 'dart:async';
import '../services/real_time_build_service.dart';

class RealTimeBuildScreen extends StatefulWidget {
  final BuildConfiguration buildConfig;

  const RealTimeBuildScreen({
    Key? key,
    required this.buildConfig,
  }) : super(key: key);

  @override
  State<RealTimeBuildScreen> createState() => _RealTimeBuildScreenState();
}

class _RealTimeBuildScreenState extends State<RealTimeBuildScreen>
    with TickerProviderStateMixin {
  final RealTimeBuildService _buildService = RealTimeBuildService();
  
  // Animation controllers
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late AnimationController _successController;
  
  // Animations
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _successAnimation;
  
  // Stream subscriptions
  StreamSubscription<BuildProgress>? _progressSubscription;
  StreamSubscription<String>? _logSubscription;
  StreamSubscription<BuildMetrics>? _metricsSubscription;
  
  // State
  BuildProgress? _currentProgress;
  BuildMetrics? _currentMetrics;
  final List<String> _buildLogs = [];
  final ScrollController _logScrollController = ScrollController();
  bool _showLogs = false;
  bool _buildStarted = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupStreamListeners();
    _startBuild();
  }

  void _initializeAnimations() {
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _successController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _successAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
    );
    
    _pulseController.repeat(reverse: true);
  }

  void _setupStreamListeners() {
    _progressSubscription = _buildService.progressStream.listen((progress) {
      setState(() {
        _currentProgress = progress;
      });
      
      // Update progress animation
      _progressController.animateTo(progress.percentage / 100);
      
      // Handle build completion
      if (progress.status == BuildStatus.completed) {
        _successController.forward();
        _pulseController.stop();
      } else if (progress.status == BuildStatus.failed) {
        _pulseController.stop();
      }
    });
    
    _logSubscription = _buildService.logStream.listen((log) {
      setState(() {
        _buildLogs.add(log);
      });
      
      // Auto-scroll to bottom
      if (_logScrollController.hasClients) {
        _logScrollController.animateTo(
          _logScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
    
    _metricsSubscription = _buildService.metricsStream.listen((metrics) {
      setState(() {
        _currentMetrics = metrics;
      });
    });
  }

  Future<void> _startBuild() async {
    setState(() {
      _buildStarted = true;
    });
    
    try {
      final result = await _buildService.startRealTimeBuild(
        config: widget.buildConfig,
      );
      
      if (result.success) {
        _showBuildSuccessDialog(result);
      } else {
        _showBuildErrorDialog(result.error ?? 'Unknown error');
      }
    } catch (e) {
      _showBuildErrorDialog(e.toString());
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    _successController.dispose();
    _progressSubscription?.cancel();
    _logSubscription?.cancel();
    _metricsSubscription?.cancel();
    _logScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Building APK'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_showLogs ? Icons.visibility_off : Icons.visibility),
            onPressed: () {
              setState(() {
                _showLogs = !_showLogs;
              });
            },
            tooltip: _showLogs ? 'Hide Logs' : 'Show Logs',
          ),
          if (_currentProgress?.status == BuildStatus.running)
            IconButton(
              icon: const Icon(Icons.stop),
              onPressed: _cancelBuild,
              tooltip: 'Cancel Build',
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            // Progress Section
            Expanded(
              flex: _showLogs ? 1 : 2,
              child: _buildProgressSection(),
            ),
            
            // Logs Section
            if (_showLogs)
              Expanded(
                flex: 1,
                child: _buildLogsSection(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Main Progress Card
          _buildMainProgressCard(),
          const SizedBox(height: 16),
          
          // Metrics Card
          if (_currentMetrics != null)
            _buildMetricsCard(),
          const SizedBox(height: 16),
          
          // Step Progress
          _buildStepProgress(),
        ],
      ),
    );
  }

  Widget _buildMainProgressCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            // Animated Progress Circle
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background circle
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[200],
                    ),
                  ),
                  
                  // Progress circle
                  AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return SizedBox(
                        width: 120,
                        height: 120,
                        child: CircularProgressIndicator(
                          value: _progressAnimation.value,
                          strokeWidth: 8,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getProgressColor(),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  // Center content
                  AnimatedBuilder(
                    animation: _currentProgress?.status == BuildStatus.running 
                        ? _pulseAnimation 
                        : _successAnimation,
                    builder: (context, child) {
                      Widget centerWidget;
                      
                      if (_currentProgress?.status == BuildStatus.completed) {
                        centerWidget = Transform.scale(
                          scale: _successAnimation.value,
                          child: const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 48,
                          ),
                        );
                      } else if (_currentProgress?.status == BuildStatus.failed) {
                        centerWidget = const Icon(
                          Icons.error,
                          color: Colors.red,
                          size: 48,
                        );
                      } else {
                        centerWidget = Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.build,
                                color: Colors.blue,
                                size: 32,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${(_currentProgress?.percentage ?? 0).toInt()}%',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      
                      return centerWidget;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Step Information
            Text(
              _currentProgress?.stepName ?? 'Preparing...',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: _getProgressColor(),
              ),
            ),
            const SizedBox(height: 8),
            
            Text(
              _currentProgress?.message ?? 'Getting ready to build...',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            // Progress Bar
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return LinearProgressIndicator(
                  value: _progressAnimation.value,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor()),
                  minHeight: 6,
                );
              },
            ),
            const SizedBox(height: 8),
            
            // Step Counter
            Text(
              'Step ${_currentProgress?.step ?? 0} of ${_currentProgress?.totalSteps ?? 8}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Build Metrics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    'Elapsed Time',
                    _formatDuration(_currentMetrics!.elapsedTime),
                    Icons.timer,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    'Estimated Total',
                    _formatDuration(_currentMetrics!.estimatedTotalTime),
                    Icons.schedule,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    'Memory Usage',
                    '${_currentMetrics!.memoryUsage.toInt()}%',
                    Icons.memory,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    'CPU Usage',
                    '${_currentMetrics!.cpuUsage.toInt()}%',
                    Icons.speed,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStepProgress() {
    final steps = [
      'Initializing',
      'Cleaning',
      'Dependencies',
      'Code Generation',
      'Building APK',
      'Optimizing',
      'Signing',
      'Finalizing',
    ];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Build Steps',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            ...steps.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;
              final stepNumber = index + 1;
              final currentStep = _currentProgress?.step ?? 0;
              
              final isCompleted = stepNumber < currentStep;
              final isCurrent = stepNumber == currentStep;
              final isPending = stepNumber > currentStep;
              
              return _buildStepItem(
                step,
                stepNumber,
                isCompleted: isCompleted,
                isCurrent: isCurrent,
                isPending: isPending,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepItem(
    String stepName,
    int stepNumber, {
    required bool isCompleted,
    required bool isCurrent,
    required bool isPending,
  }) {
    Color getColor() {
      if (isCompleted) return Colors.green;
      if (isCurrent) return Colors.blue;
      return Colors.grey;
    }

    IconData getIcon() {
      if (isCompleted) return Icons.check_circle;
      if (isCurrent) return Icons.radio_button_checked;
      return Icons.radio_button_unchecked;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: Icon(
              getIcon(),
              color: getColor(),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              stepName,
              style: TextStyle(
                color: getColor(),
                fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
          if (isCurrent)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }

  Widget _buildLogsSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.terminal, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Build Logs',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_buildLogs.length} entries',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Container(
              color: Colors.grey[50],
              child: ListView.builder(
                controller: _logScrollController,
                padding: const EdgeInsets.all(8),
                itemCount: _buildLogs.length,
                itemBuilder: (context, index) {
                  final log = _buildLogs[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 1),
                    child: Text(
                      log,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor() {
    if (_currentProgress?.status == BuildStatus.completed) return Colors.green;
    if (_currentProgress?.status == BuildStatus.failed) return Colors.red;
    if (_currentProgress?.status == BuildStatus.cancelled) return Colors.orange;
    return Colors.blue;
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  void _cancelBuild() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Build'),
        content: const Text('Are you sure you want to cancel the build process?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue Building'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _buildService.cancelBuild();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cancel Build'),
          ),
        ],
      ),
    );
  }

  void _showBuildSuccessDialog(BuildResult result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 32),
            const SizedBox(width: 12),
            const Text('Build Successful!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your APK has been built successfully!'),
            const SizedBox(height: 12),
            Text('Build Time: ${_formatDuration(result.buildDuration!)}'),
            Text('APK Size: ${(result.fileSize! / (1024 * 1024)).toStringAsFixed(1)} MB'),
            Text('Location: ${result.apkPath}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              // Share APK logic here
            },
            child: const Text('Share APK'),
          ),
        ],
      ),
    );
  }

  void _showBuildErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 32),
            SizedBox(width: 12),
            Text('Build Failed'),
          ],
        ),
        content: Text('Build failed with error:\n\n$error'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startBuild(); // Retry
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
