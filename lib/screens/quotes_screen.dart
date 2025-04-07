import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hiclik_app/models/quote.dart';
import 'package:hiclik_app/services/google_tts_service.dart';
import 'package:hiclik_app/utils/quotes_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:hiclik_app/screens/manifest_screen.dart';

class QuotesScreen extends StatefulWidget {
  const QuotesScreen({super.key});

  @override
  State<QuotesScreen> createState() => _QuotesScreenState();
}

class _QuotesScreenState extends State<QuotesScreen> with SingleTickerProviderStateMixin {
  final GoogleTTSService _ttsService = GoogleTTSService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<Quote> _quotes = [];
  int _currentIndex = 0;
  bool _isSpeaking = false;
  bool _isAudioPlaying = false;
  Timer? _quoteTimer;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _loadQuotes();
    _playBackgroundAudio();
    _scheduleNextQuote();
  }

  void _loadQuotes() {
    _quotes = QuotesProvider.getQuotes().map((text) => Quote(text: text)).toList();
    _currentIndex = DateTime.now().millisecondsSinceEpoch % _quotes.length;
    Future.delayed(const Duration(milliseconds: 500), () {
      _speakCurrentQuote();
      _fadeController.forward();
    });
  }

  Future<void> _playBackgroundAudio() async {
    try {
      await _audioPlayer.setVolume(0.3);
      await _audioPlayer.play(AssetSource('audio/ambient.mp3'));
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      setState(() {
        _isAudioPlaying = true;
      });
    } catch (_) {}
  }

  void _toggleBackgroundAudio() async {
    try {
      if (_isAudioPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.resume();
      }
      setState(() {
        _isAudioPlaying = !_isAudioPlaying;
      });
    } catch (_) {}
  }

  void _speakCurrentQuote() async {
    if (_quotes.isEmpty) return;
    if (_isSpeaking) {
      await _ttsService.stop();
      setState(() {
        _isSpeaking = false;
      });
      return;
    }
    setState(() {
      _isSpeaking = true;
    });
    final quote = _quotes[_currentIndex];
    if (_isAudioPlaying) {
      await _audioPlayer.setVolume(0.1);
    }
    try {
      await _ttsService.speak(quote.text);
    } catch (_) {}
    if (_isAudioPlaying) {
      await _audioPlayer.setVolume(0.3);
    }
    if (mounted) {
      setState(() {
        _isSpeaking = false;
      });
    }
  }

  void _scheduleNextQuote() {
    _quoteTimer?.cancel();
    _quoteTimer = Timer(const Duration(seconds: 20), () {
      if (_isSpeaking) {
        _scheduleNextQuote();
        return;
      }
      _fadeController.reverse().then((_) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _quotes.length;
        });
        _fadeController.forward();
        _speakCurrentQuote();
        _scheduleNextQuote();
      });
    });
  }

  void _nextQuote() {
    if (_isSpeaking) {
      _ttsService.stop();
      setState(() {
        _isSpeaking = false;
      });
    }
    _fadeController.reverse().then((_) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % _quotes.length;
      });
      _fadeController.forward();
      _speakCurrentQuote();
      _scheduleNextQuote();
    });
  }

  void _previousQuote() {
    if (_isSpeaking) {
      _ttsService.stop();
      setState(() {
        _isSpeaking = false;
      });
    }
    _fadeController.reverse().then((_) {
      setState(() {
        _currentIndex = (_currentIndex - 1 + _quotes.length) % _quotes.length;
      });
      _fadeController.forward();
      _speakCurrentQuote();
      _scheduleNextQuote();
    });
  }

  @override
  void dispose() {
    _quoteTimer?.cancel();
    _ttsService.dispose();
    _audioPlayer.dispose();
    _fadeController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white54),
          onPressed: () {
            _ttsService.stop();
            _audioPlayer.stop();
            _quoteTimer?.cancel();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const ManifestScreen()),
            );
          },
        ),
      ),
      body: _quotes.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : GestureDetector(
        onTap: () {
          _quoteTimer?.cancel();
          if (_isSpeaking) {
            _ttsService.stop();
            setState(() {
              _isSpeaking = false;
            });
          } else {
            _speakCurrentQuote();
          }
          _scheduleNextQuote();
        },
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            _previousQuote();
          } else if (details.primaryVelocity! < 0) {
            _nextQuote();
          }
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black, Colors.black.withBlue(40)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    _quotes[_currentIndex].text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w300,
                      height: 1.6,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 60),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.skip_previous, color: Colors.white54),
                      onPressed: _previousQuote,
                      iconSize: 32,
                    ),
                    FloatingActionButton(
                      backgroundColor: Colors.white24,
                      child: Icon(
                        _isSpeaking ? Icons.stop : Icons.volume_up,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        if (_isSpeaking) {
                          await _ttsService.stop();
                          setState(() {
                            _isSpeaking = false;
                          });
                        } else {
                          _speakCurrentQuote();
                        }
                        _scheduleNextQuote();
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        _isAudioPlaying ? Icons.music_note : Icons.music_off,
                        color: Colors.white54,
                      ),
                      onPressed: _toggleBackgroundAudio,
                      iconSize: 28,
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next, color: Colors.white54),
                      onPressed: _nextQuote,
                      iconSize: 32,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
