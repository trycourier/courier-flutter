import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class SwipableContainer extends StatefulWidget {
  final Widget child;
  final bool canPerformGestures;
  final bool isRead;
  final IconData readIcon;
  final IconData unreadIcon;
  final Color readColor;
  final Color unreadColor;
  final IconData archiveIcon;
  final Color archiveColor;
  final double actionThreshold;
  final Function() onLeftToRightAction;
  final Function() onRightToLeftAction;
  final Duration animationDuration;

  const SwipableContainer({
    super.key,
    required this.child,
    required this.canPerformGestures,
    required this.isRead,
    required this.readIcon,
    required this.unreadIcon,
    required this.readColor,
    required this.unreadColor,
    required this.archiveIcon,
    required this.archiveColor,
    required this.onLeftToRightAction,
    required this.onRightToLeftAction,
    this.actionThreshold = 0.25,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  @override
  State<SwipableContainer> createState() => _SwipableContainerState();
}

class _SwipableContainerState extends State<SwipableContainer> with TickerProviderStateMixin {
  late AnimationController _gestureController;
  late AnimationController _bounceController;
  late Animation<Offset> _animation;
  late Animation<double> _bounceAnimation;
  double _actionWidth = 0;
  double _dragExtent = 0;
  double _iconScale = 0;
  bool _dragUnderway = false;
  bool _hasTriggeredHaptic = false;
  double _thresholdWidth = 0;

  @override
  void initState() {
    super.initState();

    _gestureController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(_gestureController);

    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 1),
    ]).animate(_bounceController);

    _gestureController.addListener(() {
      if (!mounted) return;
      final size = context.size;
      if (size == null) return;
      setState(() {
        _actionWidth = size.width * _animation.value.dx.abs();
        _thresholdWidth = size.width * widget.actionThreshold;
      });
    });
  }

  @override
  void dispose() {
    _gestureController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    if (!widget.canPerformGestures) return;
    _dragUnderway = true;
    _hasTriggeredHaptic = false;
    _gestureController.stop();
    _dragExtent = 0;
    _iconScale = 0;
  }

  void didReachThreshold() {
    HapticFeedback.mediumImpact();
    _bounceController.forward(from: 0);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!widget.canPerformGestures || !_dragUnderway) return;

    final delta = details.primaryDelta ?? 0;
    final size = context.size;
    if (size == null) return;
    final width = size.width;
    final threshold = widget.actionThreshold * width;

    if (_dragExtent > threshold && delta > 0) {
      _dragExtent += delta * 0.3; // Apply resistance factor
    } else {
      _dragExtent += delta;
    }
    
    if (!_hasTriggeredHaptic && _dragExtent.abs() > threshold) {
      didReachThreshold();
      _hasTriggeredHaptic = true;
    } else if (_dragExtent.abs() <= threshold) {
      _hasTriggeredHaptic = false;
    }

    // Calculate icon scale
    if (_dragExtent.abs() <= threshold) {
      _iconScale = _dragExtent.abs() / threshold;
    } else {
      _iconScale = 1.0;
    }
    _iconScale = _iconScale.clamp(0.0, 1.0);
    
    setState(() {
      _animation = Tween<Offset>(
        begin: Offset.zero,
        end: Offset(_dragExtent / width, 0),
      ).animate(CurvedAnimation(
        parent: _gestureController,
        curve: Curves.linear,
      ));
      _gestureController.value = 1.0;
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!widget.canPerformGestures || !_dragUnderway) return;
    _dragUnderway = false;

    final size = context.size;
    if (size == null) return;
    final width = size.width;
    final threshold = widget.actionThreshold * width;
    
    if (_dragExtent.abs() > threshold) {
      if (_dragExtent > 0) {
        widget.onLeftToRightAction();
      } else if (_dragExtent < 0) {
        widget.onRightToLeftAction();
      }
    }

    setState(() {
      _animation = Tween<Offset>(
        begin: Offset(_dragExtent / width, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _gestureController,
        curve: Curves.easeOut,
      ));
    });

    _gestureController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_dragExtent < 0)
          Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            width: math.max(_thresholdWidth, _actionWidth),
            child: Container(
              color: widget.archiveColor,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Center(
                child: AnimatedBuilder(
                  animation: _bounceAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _iconScale * (_hasTriggeredHaptic ? _bounceAnimation.value : 1.0),
                      child: child,
                    );
                  },
                  child: Icon(
                    widget.archiveIcon,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        if (_dragExtent > 0)
          Positioned(
            top: 0,
            bottom: 0,
            width: math.max(_thresholdWidth, _actionWidth),
            left: 0,
            child: Container(
              color: widget.isRead ? widget.readColor : widget.unreadColor,
              child: Center(
                child: AnimatedBuilder(
                  animation: _bounceAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _iconScale * (_hasTriggeredHaptic ? _bounceAnimation.value : 1.0),
                      child: child,
                    );
                  },
                  child: Center(
                    child: Icon(
                      widget.isRead ? widget.readIcon : widget.unreadIcon,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        GestureDetector(
          onHorizontalDragStart: widget.canPerformGestures ? _handleDragStart : null,
          onHorizontalDragUpdate: widget.canPerformGestures ? _handleDragUpdate : null,
          onHorizontalDragEnd: widget.canPerformGestures ? _handleDragEnd : null,
          child: SlideTransition(
            position: _animation,
            child: widget.child,
          ),
        ),
      ],
    );
  }
}
