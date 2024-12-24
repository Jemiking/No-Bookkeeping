import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/calendar_state.dart';
import 'swipeable_calendar_content.dart';

class AnimatedCalendarView extends StatefulWidget {
  const AnimatedCalendarView({Key? key}) : super(key: key);

  @override
  State<AnimatedCalendarView> createState() => _AnimatedCalendarViewState();
}

class _AnimatedCalendarViewState extends State<AnimatedCalendarView> with SingleTickerProviderStateMixin {
  static const double WEEK_HEIGHT = 65.0;
  static const double HEADER_HEIGHT = 35.0;
  static const double MONTH_VIEW_HEIGHT = 400.0;
  static const double CALENDAR_MARGIN = 4.0;
  static const double ARROW_BUTTON_HEIGHT = 24.0;
  static const double ARROW_BUTTON_MARGIN = 6.0;
  
  late AnimationController _controller;
  late Animation<double> _heightAnimation;
  late Animation<double> _rotationAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _heightAnimation = Tween<double>(
      begin: MONTH_VIEW_HEIGHT,
      end: HEADER_HEIGHT + WEEK_HEIGHT,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
    
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0.5,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _handleExpandToggle() {
    final calendarState = context.read<CalendarState>();
    calendarState.toggleExpanded();
    
    if (calendarState.isExpanded) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(CALENDAR_MARGIN, 0, CALENDAR_MARGIN, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _heightAnimation,
            builder: (context, child) {
              return SizedBox(
                height: _heightAnimation.value,
                child: const SwipeableCalendarContent(),
              );
            },
          ),
          _buildExpandButton(),
        ],
      ),
    );
  }
  
  Widget _buildExpandButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _handleExpandToggle,
        child: Container(
          width: ARROW_BUTTON_HEIGHT,
          height: ARROW_BUTTON_HEIGHT + ARROW_BUTTON_MARGIN * 2,
          padding: const EdgeInsets.symmetric(vertical: ARROW_BUTTON_MARGIN),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  offset: const Offset(0, 1),
                  blurRadius: 3,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: AnimatedBuilder(
              animation: _rotationAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationAnimation.value * 3.14159 * 2,
                  child: const Icon(
                    Icons.expand_less,
                    color: Color(0xFF6B5B95),
                    size: 14,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
} 