import 'package:mp3/utils/db_helper.dart';

class Cards {
  int? id;
  String question;
  String answer;
  int? deckId;

  Cards({
    this.id,
    required this.question,
    required this.answer,
    this.deckId,
  });

  factory Cards.fromJson(dynamic json) {
    return Cards(
      question: json['question'] as String,
      answer: json['answer'] as String,
    );
  }

  factory Cards.clone(Cards source) {
    return Cards(
      question: source.question,
      answer: source.answer,
    );
  }

  Future<void> dbSave() async {
    id = await DataStore().addRecord('study_flashcards', {
      'question': question,
      'answer': answer,
      'deck_id': deckId,
    });
  }

  Future<void> dbUpdate() async {
    await DataStore().modifyRecord('study_flashcards', {
      'id': id,
      'question': question,
      'answer': answer,
      'deck_id': deckId,
    });
  }
}

class mainD {
  int? id;
  String title;
  List<dynamic> flashcards;

  mainD({
    this.id,
    required this.title,
    required this.flashcards,
  });

  factory mainD.fromJson(Map<String, dynamic> json) {
    return mainD(
      title: json['title'] as String,
      flashcards: json['flashcards'].map((e) => Cards.fromJson(e)).toList()
          as List<dynamic>,
    );
  }

  Future<void> dbSave() async {
    id = await DataStore().addRecord('study_decks', {
      'title': title,
    });
  }

  Future<void> dbUpdate() async {
    await DataStore().modifyRecord('study_decks', {
      'id': id,
      'title': title,
    });
  }
}
