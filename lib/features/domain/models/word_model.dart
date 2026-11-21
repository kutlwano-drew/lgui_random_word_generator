// lib/features/word_generator/domain/models/word_model.dart

import 'package:flutter/foundation.dart';

@immutable
class WordModel {
  final String word;
  final String partOfSpeech;

  const WordModel({
    required this.word,
    required this.partOfSpeech,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WordModel &&
          runtimeType == other.runtimeType &&
          word == other.word &&
          partOfSpeech == other.partOfSpeech;

  @override
  int get hashCode => word.hashCode ^ partOfSpeech.hashCode;

  @override
  String toString() => 'WordModel(word: $word, partOfSpeech: $partOfSpeech)';
}