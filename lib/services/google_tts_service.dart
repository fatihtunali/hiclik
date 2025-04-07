import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class GoogleTTSService {
  final String apiKey = 'AIzaSyDCSEPAbxbnBzNAuDCEgnfr0ZX3ZLjvCDs';
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isSpeaking = false;
  
  GoogleTTSService() {
    _initTTS();
  }

  Future<void> _initTTS() async {
    _audioPlayer.onPlayerComplete.listen((event) {
      _isSpeaking = false;
    });
  }

  // Convert normal text to enhanced SSML markup
  String _textToSSML(String text) {
    // Escape any XML special characters
    String escaped = text.replaceAll('&', '&amp;')
                         .replaceAll('<', '&lt;')
                         .replaceAll('>', '&gt;')
                         .replaceAll('"', '&quot;')
                         .replaceAll("'", '&apos;');
    
    // Add a brief pause at the beginning for a more meditative feel
    String ssml = '<speak>';
    ssml += '<break time="500ms"/>';
    
    // Split text by punctuation to add appropriate pauses
    List<String> segments = escaped.split(RegExp(r'([.!?;])'));
    for (int i = 0; i < segments.length; i++) {
      if (i % 2 == 0) {
        // This is a text segment
        if (segments[i].isNotEmpty) {
          // Slow down the speaking rate slightly for a more reflective tone
          ssml += '<prosody rate="slow" pitch="-1st">${segments[i]}</prosody>';
        }
      } else if (i < segments.length - 1) {
        // This is punctuation - add it back and add a pause
        ssml += '${segments[i]}<break time="700ms"/>';
      } else {
        // Last punctuation
        ssml += segments[i];
      }
    }
    
    // Add a closing pause
    ssml += '<break time="1s"/>';
    ssml += '</speak>';
    
        return ssml;
  }

  Future<void> speak(String text) async {
    if (_isSpeaking) {
      await stop();
    }
    
    _isSpeaking = true;
    try {
      final url = Uri.parse(
        'https://texttospeech.googleapis.com/v1/text:synthesize?key=$apiKey'
      );
      
      // Convert text to SSML
      String ssml = _textToSSML(text);
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'input': {'ssml': ssml},
          'voice': {
            'languageCode': 'tr-TR',
            'name': 'tr-TR-Wavenet-A', // Google's Turkish voice
            'ssmlGender': 'FEMALE'
          },
          'audioConfig': {
            'audioEncoding': 'MP3',
            'speakingRate': 0.85, // Slightly slower rate for meditation
            'pitch': -1.0,  // Slightly lower pitch for a calmer sound
            'volumeGainDb': 0.0,
            'effectsProfileId': ['headphone-class-device'] // Optimize for headphones
          }
        }),
      );
      
      if (response.statusCode == 200) {
        final audioContent = jsonDecode(response.body)['audioContent'];
        final bytes = base64Decode(audioContent);
        
        // Save to temporary file
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/tts_output.mp3');
        await file.writeAsBytes(bytes);
        
        // Play the audio
        await _audioPlayer.play(DeviceFileSource(file.path));
      } else {

        _isSpeaking = false;
      }
    } catch (e) {

      _isSpeaking = false;
    }
  }

  Future<void> stop() async {
    try {
      await _audioPlayer.stop();

    }  finally {
      _isSpeaking = false;
    }
  }
  
  bool get isSpeaking => _isSpeaking;

  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}