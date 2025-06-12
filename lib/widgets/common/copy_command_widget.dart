import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CopyCommandWidget extends StatefulWidget {
  final String command;
  final String? description;
  final bool showTerminalStyle;
  final VoidCallback? onCopied;

  const CopyCommandWidget({
    Key? key,
    required this.command,
    this.description,
    this.showTerminalStyle = true,
    this.onCopied,
  }) : super(key: key);

  @override
  State<CopyCommandWidget> createState() => _CopyCommandWidgetState();
}

class _CopyCommandWidgetState extends State<CopyCommandWidget>
    with SingleTickerProviderStateMixin {
  bool _isCopied = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _copyCommand() async {
    await Clipboard.setData(ClipboardData(text: widget.command));
    
    setState(() {
      _isCopied = true;
    });
    
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    
    widget.onCopied?.call();
    
    // Reset copied state after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isCopied = false;
        });
      }
    });
    
    // Show snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Command copied: ${widget.command}'),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.description != null) ...[
          Text(
            widget.description!,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
        ],
        
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: widget.showTerminalStyle 
                    ? Colors.grey.shade900 
                    : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: _isCopied 
                    ? Border.all(color: Colors.green, width: 2)
                    : null,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            if (widget.showTerminalStyle) ...[
                              const Text(
                                '\$ ',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                            Expanded(
                              child: Text(
                                widget.command,
                                style: TextStyle(
                                  color: widget.showTerminalStyle 
                                    ? Colors.white 
                                    : Colors.black87,
                                  fontFamily: 'monospace',
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _copyCommand,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: _isCopied
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.green,
                                  key: ValueKey('check'),
                                )
                              : Icon(
                                  Icons.copy,
                                  color: widget.showTerminalStyle 
                                    ? Colors.white70 
                                    : Colors.grey.shade600,
                                  key: const ValueKey('copy'),
                                ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
