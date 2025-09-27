import 'package:crypto_portfolio_tracker/View/portfolio_screen.dart';
import 'package:flutter/material.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();

    // Fade in
    Future.delayed(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      setState(() {
        _opacity = 1.0;
      });
    });

    // Hold, then fade out and navigate (total ~2.5s)
    Future.delayed(const Duration(milliseconds: 1700), () {
      if (!mounted) return;
      setState(() {
        _opacity = 0.0;
      });
    });

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PortfolioScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color background = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: background,
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeInOut,
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.account_balance_wallet, size: 96, color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Crypto Portfolio Tracker',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}