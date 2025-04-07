import 'package:flutter/material.dart';

// App Colors
class AppColors {
  static const Color primary = Color(0xFF3498DB);
  static const Color secondary = Color(0xFF2ECC71);
  static const Color background = Color(0xFFF5F5F5);
  static const Color darkBackground = Color(0xFF121212);
  static const Color text = Color(0xFF333333);
  static const Color lightText = Color(0xFFFFFFFF);
}

// App Texts
class AppTexts {
  static const String appName = 'Hiçlik';
  static const String manifestTitle = 'Hiçlik\'e Hoş Geldiniz';
  static const String manifestText = 
      'Hiçlik, günlük ilham ve bilgelik kaynağınızdır. '
      'Sizi gün boyunca motive edecek ve size rehberlik edecek özenle seçilmiş düşünce alıntılarını dinleyin.';
  static const String getStarted = 'Başla';
}

// Durations
class AppDurations {
  static const Duration splashDuration = Duration(seconds: 3);
  static const Duration animationDuration = Duration(milliseconds: 500);
}

// Sample quotes
final List<Map<String, dynamic>> sampleQuotes = [
  {
    'text': 'The only way to do great work is to love what you do.',
    'author': 'Steve Jobs',
    'category': 'Inspiration'
  },
  {
    'text': 'Life is what happens when you\'re busy making other plans.',
    'author': 'John Lennon',
    'category': 'Life'
  },
  {
    'text': 'The purpose of our lives is to be happy.',
    'author': 'Dalai Lama',
    'category': 'Happiness'
  },
  {
    'text': 'Get busy living or get busy dying.',
    'author': 'Stephen King',
    'category': 'Motivation'
  },
  {
    'text': 'You only live once, but if you do it right, once is enough.',
    'author': 'Mae West',
    'category': 'Life'
  },
];