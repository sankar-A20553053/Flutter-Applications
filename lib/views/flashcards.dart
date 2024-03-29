import 'package:flutter/material.dart';
import 'package:mp3/models/deckbox.dart';
import 'package:mp3/models/informer.dart';
import 'package:mp3/views/layoutdeck.dart';
import 'package:mp3/views/editdeck.dart';
import 'package:mp3/views/game.dart';

class Flashcards extends StatelessWidget {
  final mainD? deck;
  final VoidCallback? sort;
  final VoidCallback? click;
  final Notifylist notifier;

  const Flashcards({
    super.key,
    this.sort,
    this.click, // Assigning in constructor
    required this.notifier,
    this.deck,
  });

  @override
  Widget build(BuildContext context) {
    List<Cards> mainList = [];
    notifier.isSort = false;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        leading: BackButton(onPressed: () {
          int i = mainList.length;
          while (i < deck!.flashcards.length) {
            mainList.add(deck!.flashcards[i]);
            i++;
          }
          deck!.flashcards =
              List.from(mainList); // Ensure a fresh copy is assigned if needed.
          Navigator.pop(context, false);
        }),
        title: Text(deck!.title, style: const TextStyle(color: Colors.amber)),
        actions: <Widget>[
          IconButton(
            icon: ListenableBuilder(
              listenable: notifier,
              builder: (BuildContext context, Widget? child) {
                return Icon(
                  notifier.isSort ? Icons.history : Icons.sort,
                  color: Colors.amber,
                );
              },
            ),
            onPressed: () {
              int sortFlag = notifier.isSort ? 1 : 0;

              switch (sortFlag) {
                case 1: // Equivalent to if(notifier.isSort)
                  int i = mainList.length;
                  while (i < deck!.flashcards.length) {
                    mainList.add(deck!.flashcards[i]);
                    i++;
                  }
                  deck!.flashcards.clear();
                  deck!.flashcards.addAll(mainList.toList());
                  mainList.clear();
                  break;
                case 0: // Equivalent to else
                  int i = 0;
                  while (i < deck!.flashcards.length) {
                    mainList.add(deck!.flashcards[i]);
                    i++;
                  }
                  deck!.flashcards
                      .sort((a, b) => a.question.compareTo(b.question));
                  break;
              }
              //print('sort clicked');
              sort!();
            },
          ),
          IconButton(
            icon: const Icon(Icons.airplay, color: Colors.amber),
            onPressed: () {
              if (deck!.flashcards.isNotEmpty) {
                notifier.index = 0;
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => QuizBoard(pack: deck, inform: notifier),
                ));
              }
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.amber),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => EditDeck(
                card: deck,
                index: -1,
                save: notifier.reloadDeck,
                isEdit: false),
          ));
        },
      ),
      body: ListenableBuilder(
        listenable: notifier,
        builder: (BuildContext context, Widget? child) {
          return GridView.count(
            crossAxisCount:
                ((MediaQuery.of(context).size.width ~/ 180) + 1).toInt(),
            padding: const EdgeInsets.all(
                12), // Slightly increased padding for more space
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio:
                0.8, // Adjusted for cards to be taller, considering content size
            children: List.generate(deck!.flashcards.length, (index) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors
                      .lightBlue.shade50, // Lighter shade for card background
                  borderRadius: BorderRadius.circular(
                      12), // Rounded corners for a modern look
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5), // Shadow color
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3), // Vertical shadow
                    ),
                  ],
                ),
                child: InkWell(

                  onTap: () {
                    click?.call();
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) {
                        var delete = deck!.flashcards[index];
                        return EditDeck(
                          card: deck,
                          index: index,
                          save: notifier.reloadDeck,
                          isEdit: true,
                          delete: () {
                            mainList.remove(delete);
                            notifier.reloadDeck();
                          },
                        );
                      },
                    ));
                  },
                  child: CustomCard(
                    color: false,
                    flashcards: deck!.flashcards[index],

                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
