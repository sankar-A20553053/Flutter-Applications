import 'package:flutter/material.dart';
import 'package:mp3/models/deckbox.dart';

class CustomCard extends StatefulWidget {
  final bool color;
  final Cards? flashcards;
  final VoidCallback? click;
  final VoidCallback? update;
  final String? title;
  final int? totalCards;

  const CustomCard({
    Key? key,
    this.color = false,
    this.flashcards,
    this.click,
    this.update,
    this.title,
    this.totalCards,
  }) : super(key: key);

  @override
  _CustomCardState createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _opacityAnimation = Tween<double>(begin: 0.5, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut))
      ..addListener(() {
        setState(() {});
      });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      color: widget.color ? Colors.lightGreen[50] : Colors.orange[100],
      elevation: 10,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          gradient: LinearGradient(
            colors: [
              widget.color
                  ? Colors.lightGreen.shade200
                  : Colors.orange.shade200,
              widget.color
                  ? Colors.lightGreen.shade400
                  : Colors.orange.shade400,
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Stack(
          children: [
            InkWell(
              onTap: widget.click,
              borderRadius: BorderRadius.circular(20.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  widget.flashcards != null
                      ? widget.color
                          ? '${widget.flashcards?.answer}'
                          : '${widget.flashcards?.question}'
                      : '${widget.title}\n(${widget.totalCards} cards)',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white, // Bright text color for contrast
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    shadows: [
                      Shadow(
                        blurRadius: 2.0,
                        color: Colors.black38,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (widget.flashcards == null)
              Positioned(
                bottom: 8,
                right: 8,
                child: FadeTransition(
                  opacity: _opacityAnimation,
                  child: IconButton(
                    icon: Icon(Icons.edit, color: Colors.deepPurple[900]),
                    onPressed: widget.update,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
