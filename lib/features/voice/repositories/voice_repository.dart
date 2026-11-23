import 'package:speech_to_text/speech_to_text.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/services/functions_client.dart';
import '../models/voice_split_result.dart';

class VoiceRepository {
  VoiceRepository(this._functions, {SpeechToText? speech}) : _speech = speech ?? SpeechToText();

  final FunctionsClient _functions;
  final SpeechToText _speech;
  bool _ready = false;

  Future<bool> init({required void Function(String status) onStatus}) async {
    if (_ready) return true;
    _ready = await _speech.initialize(onStatus: onStatus, onError: (_) => onStatus('error'));
    return _ready;
  }

  Future<void> listen({required String localeId, required void Function(String text, bool isFinal) onResult}) =>
      _speech.listen(
        onResult: (r) => onResult(r.recognizedWords, r.finalResult),
        listenOptions: SpeechListenOptions(
          localeId: localeId,
          listenFor: const Duration(seconds: 45),
          pauseFor: const Duration(seconds: 4),
          partialResults: true,
          listenMode: ListenMode.dictation,
        ),
      );

  Future<void> stop() => _speech.stop();

  Future<void> cancel() => _speech.cancel();

  Future<VoiceSplitResult> parse(String transcript, List<String> itemNames) async {
    final json = await _functions.call(
      'parseVoiceSplit',
      {'transcript': transcript, 'items': itemNames},
      timeout: const Duration(seconds: 30),
    );
    try {
      return VoiceSplitResult.fromJson(json);
    } on AppException {
      rethrow;
    } catch (_) {
      throw const AppException('error_voice_not_understood');
    }
  }
}
