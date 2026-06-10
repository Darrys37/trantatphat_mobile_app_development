// lib/screens/order_success_screen.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;

class OrderSuccessScreen extends StatefulWidget {
  const OrderSuccessScreen({super.key});
  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;
  final List<_Confetti> _confetti = List.generate(30, (_) => _Confetti());

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim  = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(children: [
          // Confetti
          ...(_confetti.map((c) => Positioned(
            left: c.x * MediaQuery.of(context).size.width,
            top: c.y * MediaQuery.of(context).size.height * 0.6,
            child: Transform.rotate(
              angle: c.angle,
              child: Container(
                width: c.size, height: c.size * 0.4,
                color: c.color,
              ),
            ),
          ))),

          // Content
          Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Shopping bags illustration
                      SizedBox(
                        height: 180,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Orange bag
                            Positioned(
                              left: 40, top: 10,
                              child: Transform.rotate(
                                angle: -0.15,
                                child: _ShoppingBagIcon(
                                    color: const Color(0xFFFF9800), size: 110),
                              ),
                            ),
                            // Red bag
                            Positioned(
                              right: 30, top: 30,
                              child: Transform.rotate(
                                angle: 0.1,
                                child: _ShoppingBagIcon(
                                    color: const Color(0xFFE53935), size: 100),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text('Success!',
                          style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                      const SizedBox(height: 12),
                      Text(
                        'Your order will be delivered soon.\nThank you for choosing our app!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.grey[600], fontSize: 15, height: 1.5),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () =>
                              Navigator.pushNamedAndRemoveUntil(
                                  context, '/home', (r) => false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE53935),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28)),
                            elevation: 0,
                          ),
                          child: const Text('CONTINUE SHOPPING',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  letterSpacing: 1.2)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _ShoppingBagIcon extends StatelessWidget {
  final Color color;
  final double size;
  const _ShoppingBagIcon({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 1.1),
      painter: _BagPainter(color: color),
    );
  }
}

class _BagPainter extends CustomPainter {
  final Color color;
  const _BagPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    // Bag body
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, size.height * 0.28, size.width, size.height * 0.72),
      const Radius.circular(8),
    );
    canvas.drawRRect(bodyRect, paint);
    // Handle
    final handlePaint = Paint()
      ..color = color.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(size.width * 0.3, size.height * 0.28)
      ..cubicTo(
          size.width * 0.3, size.height * 0.0,
          size.width * 0.7, size.height * 0.0,
          size.width * 0.7, size.height * 0.28);
    canvas.drawPath(path, handlePaint);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _Confetti {
  final double x, y, size, angle;
  final Color color;

  _Confetti()
      : x     = math.Random().nextDouble(),
        y     = math.Random().nextDouble(),
        size  = math.Random().nextDouble() * 8 + 4,
        angle = math.Random().nextDouble() * math.pi,
        color = [
          const Color(0xFFE53935),
          const Color(0xFF1565C0),
          const Color(0xFF2E7D32),
          const Color(0xFFFF8F00),
          const Color(0xFF6A1B9A),
        ][math.Random().nextInt(5)];
}