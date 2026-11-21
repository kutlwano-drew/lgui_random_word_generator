// lib/features/word_generator/data/word_repository.dart

import 'dart:math';
import 'package:word_generator/word_generator.dart'; // From pub.dev
import '../../../../core/constants/fallback_words.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/error_handler.dart';
import '../domain/models/word_model.dart';

class WordRepository {
  final WordGenerator _wordGenerator = WordGenerator();
  final Random _random = Random();

  /// Fetches a random noun or verb from the word_generator package safely.
  /// If an error occurs, it smoothly intercepts and serves a high-quality fallback word.
  WordModel getRandomWord() {
    try {
      // Randomly cycle between a noun and a verb
      final isNoun = _random.nextBool();
      
      if (isNoun) {
        final noun = _wordGenerator.randomNoun();
        if (noun.isEmpty) {
          throw const WordGenerationException(message: 'Generated noun returned empty.');
        }
        return WordModel(word: noun, partOfSpeech: 'noun');
      } else {
        final verb = _wordGenerator.randomVerb();
        if (verb.isEmpty) {
          throw const WordGenerationException(message: 'Generated verb returned empty.');
        }
        return WordModel(word: verb, partOfSpeech: 'verb');
      }
    } catch (e, stackTrace) {
      // Intercept package-level crashes and record details without crashing the app
      ErrorHandler.log(e, stackTrace);
      
      // Serve a local word from our static fallback dictionary
      final fallbackList = FallbackWords.list;
      final fallbackWord = fallbackList[_random.nextInt(fallbackList.length)];
      
      return WordModel(
        word: fallbackWord,
        partOfSpeech: 'fallback word',
      );
    }
  }
}