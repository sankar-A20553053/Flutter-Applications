import 'package:flutter/material.dart';
import 'package:mp3/models/deckbox.dart';
import 'package:mp3/utils/db_helper.dart';

class EditDeck extends StatelessWidget {
  final mainD? card;
  final List<dynamic>? existcard;
  final VoidCallback? save;
  final VoidCallback? delete;
  final int? index;
  final bool isEdit;

  const EditDeck(
      {super.key,
      this.card,
      this.save,
      this.index,
      this.existcard,
      required this.isEdit,
      this.delete});

  @override
  Widget build(BuildContext context) {
    String question = '';
    dynamic answer = '';

    if (index != null) {
      if (index == -1) {
        question = '';
        answer = '';
      } else {
        question = card!.flashcards[index!].question;
        answer = card!.flashcards[index!].answer;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(index != null ? 'Edit Card' : 'Edit Deck'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Center(
            child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                initialValue: index != null ? question : card?.title,
                decoration: InputDecoration(
                  hintText: 'Name',
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onChanged: (value) => (index != null
                    ? question = value
                    : (card == null)
                        ? question = value
                        : card!.title = value),
              ),
              const SizedBox(height: 20),
              if (index != null)
                TextFormField(
                  initialValue: answer,
                  decoration: InputDecoration(
                    hintText: 'Description',
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onChanged: (value) => answer = value,
                ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    child: const Text('Confirm'),
                    onPressed: () async {
                      const int showErrorDialog = 0;
                      const int addNewCard = 1;
                      const int updateCard = 2;
                      const int createDeck = 3;
                      const int updateDeck = 4;
                      int actionToPerform = showErrorDialog; // Default action

                      if ((card == null && index == null && question == '') ||
                          (card != null && card!.title == '') ||
                          (index != null && (question == '' || answer == ''))) {
                        actionToPerform = showErrorDialog;
                      } else if (card == null) {
                        actionToPerform = createDeck;
                      } else if (index != null) {
                        if (index == -1) {
                          actionToPerform = addNewCard;
                        } else {
                          actionToPerform = updateCard;
                        }
                      } else {
                        actionToPerform = updateDeck;
                      }

                      switch (actionToPerform) {
                        case showErrorDialog:
                          showDialog(
                              context: context,
                              builder: (context) {
                                Future.delayed(const Duration(seconds: 1), () {
                                  Navigator.of(context).pop(true);
                                });
                                return const AlertDialog(
                                  title: Text('Fields cannot be empty'),
                                );
                              });
                          break;
                        case addNewCard:
                          Cards tempcard = Cards(
                              question: question,
                              answer: answer,
                              deckId: card!.id!);
                          await tempcard.dbSave();
                          card!.flashcards.add(tempcard);
                          Navigator.of(context).pop(card);
                          save!();
                          break;
                        case updateCard:
                          card!.flashcards[index!].question = question;
                          card!.flashcards[index!].answer = answer;
                          await card!.flashcards[index!].dbUpdate();
                          Navigator.of(context).pop(card);
                          save!();
                          break;
                        case createDeck:
                          mainD tempdeck =
                              mainD(title: question, flashcards: []);
                          await tempdeck.dbSave();
                          existcard!.add(tempdeck);
                          Navigator.of(context).pop(card);
                          save!();
                          break;
                        case updateDeck:
                          await card!.dbUpdate();
                          Navigator.of(context).pop(card);
                          save!();
                          break;
                      }
                    },
                  ),
                  if (isEdit)
                    TextButton(
                      child: const Text('Remove'),
                      onPressed: () async {
                        // Define action identifiers
                        const int deleteFlashcard = 0;
                        const int deleteDeck = 1;
                        int actionToPerform;

                        // Determine the action to perform based on conditions
                        if (index != null && card != null) {
                          actionToPerform = deleteFlashcard;
                        } else if (card != null) {
                          actionToPerform = deleteDeck;
                        } else {
                          return; // Exit if neither condition is met
                        }

                        // Execute the action using a switch statement
                        switch (actionToPerform) {
                          case deleteFlashcard:
                            // Delete a specific flashcard from the deck
                            var flashcardId = card!.flashcards[index!].id;
                            if (flashcardId != null) {
                              await DataStore().removeRecord(
                                  'study_flashcards', flashcardId);
                              card!.flashcards.removeAt(index!);
                            }
                            break;
                          case deleteDeck:
                            await DataStore().removeAllRecordsFromDeck(
                                'study_flashcards', card!.id!);
                            await DataStore()
                                .removeRecord('study_decks', card!.id!);
                            existcard!.removeWhere((d) => d.id == card!.id);
                            break;
                        }

                        // After deletion, trigger any necessary UI updates and pop the current context
                        if (delete != null) delete!();
                        Navigator.pop(context, card);
                      },
                    ),
                ],
              )
            ],
          ),
        )),
      ),
    );
  }
}
