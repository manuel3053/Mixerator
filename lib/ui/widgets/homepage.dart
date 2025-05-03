import 'package:flutter/material.dart';
import 'package:mixerator/ui/views/scene_viewmodel.dart';
import 'package:mixerator/ui/widgets/track.dart';

class Homepage extends StatefulWidget {
  final HomeViewmodel viewmodel;
  const Homepage({super.key, required this.viewmodel});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add_rounded),
        onPressed: () => widget.viewmodel.addTrack(),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: widget.viewmodel,
          builder: (context, _) {
            return ListenableBuilder(
              listenable: widget.viewmodel,
              builder: (context, _) {
                return CustomScrollView(
                  slivers: [
                    SliverList.builder(
                      itemCount: widget.viewmodel.tracks.length,
                      itemBuilder: (_, index) {
                        return Dismissible(
                          // key: UniqueKey(),
                          key: ValueKey(
                            widget.viewmodel.tracks.elementAt(index),
                          ),
                          onDismissed: (_) =>
                              widget.viewmodel.removeTrackAt(index),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Track(
                              viewmodel: widget.viewmodel.tracks.elementAt(
                                index,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
