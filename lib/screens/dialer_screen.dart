import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/list_provider.dart';

class DialerScreen extends StatefulWidget {
  const DialerScreen({super.key});

  @override
  State<DialerScreen> createState() => _DialerScreenState();
}

class _DialerScreenState extends State<DialerScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _waveformController;

  bool _isDialing = false;
  bool _isPaused = false;
  String? _selectedListId;
  int _callTimerSeconds = 0;
  String _currentContactName = '';
  String _currentContactPhone = '';

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _waveformController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveformController.dispose();
    super.dispose();
  }

  void _startDialing() {
    if (_selectedListId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a call list first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isDialing = true;
      _isPaused = false;
      _callTimerSeconds = 0;
      _currentContactName = 'John Doe';
      _currentContactPhone = '+91 98765 43210';
    });
    _waveformController.repeat(reverse: true);
    _startTimer();
  }

  void _stopDialing() {
    setState(() {
      _isDialing = false;
      _isPaused = false;
      _callTimerSeconds = 0;
      _currentContactName = '';
      _currentContactPhone = '';
    });
    _waveformController.stop();
    _waveformController.reset();
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
    if (_isPaused) {
      _waveformController.stop();
    } else {
      _waveformController.repeat(reverse: true);
    }
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted || !_isDialing) return false;
      if (!_isPaused) {
        setState(() => _callTimerSeconds++);
      }
      return _isDialing;
    });
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final listProvider = context.watch<ListProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Auto Dialer',
          style: TextStyle(
            color: Color(0xFF1A237E),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_isDialing) ...[
                // Idle state: big phone icon with pulse
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF2962FF).withOpacity(0.1),
                    ),
                    child: const Icon(
                      Icons.phone_rounded,
                      size: 56,
                      color: Color(0xFF2962FF),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Select call list dropdown
                _buildDropdown(listProvider),
                const SizedBox(height: 32),
                // Start button
                _buildStartButton(),
              ] else ...[
                // Active call state
                _buildActiveCall(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(ListProvider listProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedListId,
          hint: const Text('Select Call List'),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF2962FF)),
          items: listProvider.lists.map((list) {
            return DropdownMenuItem(
              value: list.id,
              child: Text(
                list.name,
                style: const TextStyle(
                  color: Color(0xFF1A237E),
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => _selectedListId = value);
          },
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return GestureDetector(
      onTap: _startDialing,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2962FF), Color(0xFF0D47A1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2962FF).withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.phone_rounded, color: Colors.white, size: 22),
            SizedBox(width: 10),
            Text(
              'Start Auto Dialing',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveCall() {
    return Column(
      children: [
        // Waveform animation
        _AnimatedWaveform(controller: _waveformController, isPaused: _isPaused),
        const SizedBox(height: 24),
        // Call status
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Status indicator
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: _isPaused
                      ? Colors.orange.withOpacity(0.12)
                      : Colors.green.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isPaused
                          ? Icons.pause_circle_rounded
                          : Icons.radio_button_checked_rounded,
                      size: 14,
                      color: _isPaused ? Colors.orange : Colors.green,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isPaused ? 'Paused' : 'In Call',
                      style: TextStyle(
                        color: _isPaused ? Colors.orange : Colors.green,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Contact name
              Text(
                _currentContactName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _currentContactPhone,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 12),
              // Timer
              Text(
                _formatTime(_callTimerSeconds),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w300,
                  color: Color(0xFF2962FF),
                  letterSpacing: 4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        // Control buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pause/Resume
            _ControlButton(
              icon: _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
              label: _isPaused ? 'Resume' : 'Pause',
              color: Colors.orange,
              onTap: _togglePause,
            ),
            const SizedBox(width: 32),
            // Stop
            _ControlButton(
              icon: Icons.stop_rounded,
              label: 'Stop',
              color: Colors.red,
              onTap: _stopDialing,
            ),
          ],
        ),
      ],
    );
  }
}

/// Animated waveform displayed during an active call.
class _AnimatedWaveform extends StatelessWidget {
  final AnimationController controller;
  final bool isPaused;

  const _AnimatedWaveform({required this.controller, required this.isPaused});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return CustomPaint(
            size: const Size(double.infinity, 80),
            painter: _WaveformPainter(
              progress: isPaused ? 0.0 : controller.value,
              color: const Color(0xFF2962FF),
            ),
          );
        },
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final double progress;
  final Color color;

  _WaveformPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    const barCount = 30;
    final barWidth = size.width / (barCount * 2);
    final rng = Random(42);

    for (int i = 0; i < barCount; i++) {
      final maxHeight = rng.nextDouble() * size.height * 0.7 + size.height * 0.1;
      final h = maxHeight * (0.3 + 0.7 * progress);
      final x = i * barWidth * 2 + barWidth / 2;
      final top = (size.height - h) / 2;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, top, barWidth, h),
          const Radius.circular(3),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// A circular control button (pause/stop).
class _ControlButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<_ControlButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.9,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnim = _scaleController;
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _scaleController.animateTo(0.9),
      onTapUp: (_) {
        _scaleController.animateTo(1.0);
        widget.onTap();
      },
      onTapCancel: () => _scaleController.animateTo(1.0),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withOpacity(0.12),
              ),
              child: Icon(widget.icon, color: widget.color, size: 30),
            ),
            const SizedBox(height: 8),
            Text(
              widget.label,
              style: TextStyle(
                color: widget.color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
