import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// 메인 +1 버튼
/// 88dp 높이의 대형 버튼으로 쉬운 탭
class MainCounterButton extends StatefulWidget {
  final VoidCallback onPressed;

  const MainCounterButton({
    super.key,
    required this.onPressed,
  });

  @override
  State<MainCounterButton> createState() => _MainCounterButtonState();
}

class _MainCounterButtonState extends State<MainCounterButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onPressed();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          height: 88,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(_isPressed ? 0.2 : 0.35),
                offset: Offset(0, _isPressed ? 4 : 8),
                blurRadius: _isPressed ? 12 : 24,
              ),
            ],
          ),
          child: const Center(
            child: Text(
              '+ 1',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
