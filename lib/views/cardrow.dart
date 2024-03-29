import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mp3/models/deckbox.dart';
import 'package:mp3/models/informer.dart';
import 'package:mp3/views/editdeck.dart';
import 'package:mp3/views/flashcards.dart';
import 'package:provider/provider.dart';

class DeckList extends StatelessWidget {
  const DeckList({super.key});

  Future<List<mainD>> _FromJson() async {
    final dataString = await rootBundle.loadString('assets/flashcards.json');
    List<dynamic> jsonData = json.decode(dataString);

    List<mainD> decks = [];
    await Future.wait(jsonData.map((deckData) async {
      mainD deck = mainD.fromJson(deckData);
      await deck.dbSave();
      await Future.wait(deck.flashcards.map((flashcard) async {
        flashcard.deckId = deck.id;
        await flashcard.dbSave();
      }));
      decks.add(deck);
    }));

    return decks;
  }

  @override
  Widget build(BuildContext context) {
    final box = Provider.of<List<mainD?>>(context);
    final Notifylist notifier = Notifylist();

    if (box.isEmpty) {
      return Scaffold(
        body: const Center(
          child: CircularProgressIndicator(color: Colors.teal),
        ),
        backgroundColor: Colors.grey[200],
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Flashcard Decks',
              style: TextStyle(color: Colors.amberAccent)),
          backgroundColor: Colors.deepOrange,
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.download, color: Colors.amberAccent),
              onPressed: () async {
                box.addAll(await _FromJson());
                notifier.reloadDeck();
              },
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blueAccent,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => EditDeck(
                      existcard: box,
                      save: () => notifier.reloadDeck(),
                      isEdit: false)),
            );
          },
          child: const Icon(Icons.add),
        ),
        body: ListenableBuilder(
          listenable: notifier,
          builder: (BuildContext context, Widget? child) {
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: (MediaQuery.of(context).size.width ~/ 300) + 1,
                childAspectRatio: 3 / 2,
              ),
              padding: const EdgeInsets.all(8),
              itemCount: box.length,
              itemBuilder: (context, index) {
                final deck = box[index];
                return Card(
                  color:
                      Colors.lightBlue[50],
                  elevation: 4,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => Flashcards(
                                  deck: deck!,
                                  notifier: notifier,
                                  sort: notifier.clickSort,
                                  click: notifier.clickColor,
                                )),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(deck?.title ?? 'Untitled Deck',
                              style: const TextStyle(
                                  color: Colors.deepOrange,
                                  fontWeight: FontWeight.bold)),
                          Text('Cards: ${deck?.flashcards.length ?? 0}',
                              style: TextStyle(color: Colors.grey[700])),
                          IconButton(
                            icon: const Icon(Icons.edit,
                                color: Colors
                                    .deepOrange),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) {
                                  return EditDeck(
                                    card: deck,
                                    existcard: box,
                                    save: () {
                                      notifier.reloadDeck();
                                    },
                                    isEdit: true,
                                    delete: () {
                                      box.remove(deck);
                                      notifier.reloadDeck();
                                    },
                                  );
                                }),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      );
    }
  }
}
