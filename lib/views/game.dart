import 'package:flutter/material.dart';
import 'package:mp3/models/deckbox.dart';
import 'package:mp3/models/informer.dart';
import 'package:mp3/views/layoutdeck.dart';

class QuizBoard extends StatelessWidget {
  final mainD? pack;
  final Notifylist? inform;

  const QuizBoard({super.key, this.pack, this.inform});

  @override
  Widget build(BuildContext context) {
    var generate = List<int>.generate(pack!.flashcards.length, (i) => i)
      ..shuffle();
    bool trf = false;
    var check = <dynamic>{};
    var viewed = <dynamic>{};

    return Scaffold(
      appBar: AppBar(
        title: Text('${pack!.title} Quiz'),
        backgroundColor: Colors.tealAccent[400],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: ListenableBuilder(
          listenable: inform!,
          builder: (BuildContext context, Widget? child) {
            check.add(inform!.index);
            if (trf) {
              viewed.add(inform!.index);
            }

            double progress = check.length / pack!.flashcards.length;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[300],
                  color: Colors.teal,
                  minHeight: 8,
                ),
                const SizedBox(height: 20),
                Text(
                  'Question ${inform!.index + 1} of ${pack!.flashcards.length}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: Card(
                    elevation: 4,
                    margin: const EdgeInsets.all(16),
                    child: Center(
                      child: CustomCard(
                        color: trf,
                        flashcards: pack!.flashcards[generate[inform!.index]],
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FloatingActionButton(
                      heroTag: 'prevBtn',
                      backgroundColor: Colors.teal,
                      mini: true,
                      child: const Icon(Icons.chevron_left),
                      onPressed: () {
                        inform!.index--;
                        if (inform!.index < 0) {
                          inform!.index = pack!.flashcards.length - 1;
                        }
                        trf = false;
                        inform!.newindex();
                      },
                    ),
                    FloatingActionButton(
                      heroTag: 'revealBtn',
                      backgroundColor: Colors.orange,
                      mini: true,
                      child:
                          Icon(trf ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        trf = !trf;
                        inform!.reloadDeck();
                      },
                    ),
                    FloatingActionButton(
                      heroTag: 'nextBtn',
                      backgroundColor: Colors.teal,
                      mini: true,
                      child: const Icon(Icons.chevron_right),
                      onPressed: () {
                        inform!.index++;
                        if (inform!.index == pack!.flashcards.length) {
                          inform!.index = 0;
                        }
                        trf = false;
                        inform!.newindex();
                      },
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    'viewed ${check.length} of ${pack!.flashcards.length} cards',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Peeked at ${viewed.length} of ${check.length} answers',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
