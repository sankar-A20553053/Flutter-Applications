import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mp3/models/deckbox.dart';
import 'package:mp3/utils/db_helper.dart';
import 'package:mp3/views/cardrow.dart';
import 'package:provider/provider.dart';

class Upperbox extends StatelessWidget {
  const Upperbox({super.key});

  Future<List<mainD>> _fromDB(BuildContext context) async {
    final dstore = await DataStore().query('study_decks');
    List<mainD> struc = [];

    if (dstore.isNotEmpty) {
      //print('from db');
      int index = 0;
      while (index < dstore.length) {
        final fdb = await DataStore().query('study_flashcards',
            where: 'deck_id = ${dstore[index]['id'] as int}');
        final List<Cards> temp = fdb
            .map((e) => Cards(
                id: e['id'] as int,
                question: e['question'] as String,
                answer: e['answer'] as String,
                deckId: e['deck_id'] as int))
            .toList();

        struc.add(mainD(
          id: dstore[index]['id'] as int,
          title: dstore[index]['title'] as String,
          flashcards: temp,
        ));
        index++;
      }
    } else {
      //print('from json');
      final mem = await DefaultAssetBundle.of(context)
          .loadString('assets/flashcards.json');

      List<dynamic> dynamicList = json.decode(mem);
      int i = 0;
      while (i < dynamicList.length) {
        struc.add(mainD.fromJson(dynamicList[i]));
        await struc[i].dbSave();
        int j = 0;
        while (j < struc[i].flashcards.length) {
          struc[i].flashcards[j].deckId = struc[i].id;

          await struc[i].flashcards[j].dbSave();
          j++;
        }
        i++;
      }
    }
    await Future.delayed(const Duration(seconds: 5));

    return struc;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureProvider<List<mainD?>>(
        create: (context) => _fromDB(context),
        initialData: const [],
        child: const DeckList(),
      ),
    );
  }
}
