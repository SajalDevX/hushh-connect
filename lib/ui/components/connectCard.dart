import 'package:flutter/material.dart';
import 'package:flutter_tilt/flutter_tilt.dart';

class TiltCard extends StatefulWidget {
  final String imagePath;
  final String name;
  final VoidCallback onCardClick;
  final ValueNotifier<int> currentCardIndex;
  final ValueNotifier<bool> onSwipeTrigger; // Trigger for the swipe animation

  const TiltCard({
    Key? key,
    required this.imagePath,
    required this.name,
    required this.onCardClick,
    required this.currentCardIndex,
    required this.onSwipeTrigger, // Accept the ValueNotifier for swipe trigger
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TiltCardState();
}

class _TiltCardState extends State<TiltCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _offsetXAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _alphaAnimation;

  double offsetX = 0;
  double rotation = 0;
  double alpha = 1;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();

    // Listen for the swipe trigger from ConnectScreen
    widget.onSwipeTrigger.addListener(() {
      if (widget.onSwipeTrigger.value) {
        _performSwipeAnimation(); // Perform the swipe animation
        widget.onSwipeTrigger.value = false; // Reset the trigger
      }
    });

    // Listen for current card index changes
    widget.currentCardIndex.addListener(_onCardIndexChanged);
  }

  void _onCardIndexChanged() {
    // This will handle if the card index changes
    setState(() {
      // Reset card position to initial when index changes
      offsetX = 0;
      rotation = 0;
      alpha = 1;
      _controller.reset();
    });
  }

  void _performSwipeAnimation() {
    _controller.forward(from: 0).then((_) {
      // Animation is complete, update card index now
      setState(() {
        offsetX = 0;
        rotation = 0;
        alpha = 1;
        // Notify parent to update to the next card
        widget.currentCardIndex.value++;
      });
    });
  }

  void _onDragUpdate(DragUpdateDetails details, double screenWidth) {
    setState(() {
      offsetX += details.delta.dx;
      rotation = (offsetX / screenWidth) * 30;
      alpha = 1 - (offsetX.abs() / screenWidth);
    });
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _controller.addListener(() {
      setState(() {
        // Update animation values dynamically during swipe
        offsetX = _offsetXAnimation.value;
        rotation = _rotationAnimation.value;
        alpha = _alphaAnimation.value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Initialize animations based on the screen width
    _offsetXAnimation =
        Tween<double>(begin: 0, end: screenWidth * 1.2).animate(_controller);
    _rotationAnimation = Tween<double>(begin: 0, end: 30).animate(_controller);
    _alphaAnimation = Tween<double>(begin: 1, end: 0).animate(_controller);

    return GestureDetector(
      onPanUpdate: (details) => _onDragUpdate(details, screenWidth),
      child: Opacity(
        opacity: alpha,
        child: Transform.translate(
          offset: Offset(offsetX, 0),
          child: Transform.rotate(
            angle: rotation * (3.1415927 / 180),
            child: InkWell(
              onTap: widget.onCardClick,
              child: Tilt(
                tiltConfig: const TiltConfig(
                  angle: 15,
                ),
                lightConfig: const LightConfig(disable: true),
                shadowConfig: const ShadowConfig(disable: true),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: SizedBox(
                      height: 400,
                      width: 300,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.network(
                              widget.imagePath,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            bottom: 20,
                            left: 20,
                            right: 20,
                            child: TiltParallax(
                              size: const Offset(59, 15),
                              child: Text(
                                widget.name,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 28,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 10.0,
                                      color: Colors.black54,
                                      offset: Offset(3.0, 3.0),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
