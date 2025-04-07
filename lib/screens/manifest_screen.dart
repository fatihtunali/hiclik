import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:hiclik_app/screens/quotes_screen.dart';
import 'package:hiclik_app/utils/constants.dart';

class ManifestScreen extends StatelessWidget {
  const ManifestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                AppTexts.manifestTitle,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 24),
              AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText(
                    AppTexts.manifestText,
                    textStyle: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 18,
                      height: 1.5,
                      fontWeight: FontWeight.w300,
                    ),
                    speed: const Duration(milliseconds: 50),
                  ),
                ],
                totalRepeatCount: 1,
                displayFullTextOnTap: true,
              ),
              const SizedBox(height: 60),
              Center(
                child: Container(
                  width: size.width * 0.6,
                  height: size.width * 0.6,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.format_quote_rounded,
                      size: 80,
                      color: Colors.white30,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const QuotesScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    AppTexts.getStarted,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}