import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mixerator/ui/views/scene_viewmodel.dart';
import 'package:mixerator/ui/views/track_viewmodel.dart';
import 'package:mixerator/ui/widgets/track.dart';

class Scene extends StatefulWidget {
  final SceneViewmodel viewmodel;
  const Scene({super.key, required this.viewmodel});

  @override
  State<Scene> createState() => _SceneState();
}

class _SceneState extends State<Scene> {
  @override
  Widget build(BuildContext context) {
    // return Track(viewmodel: TrackViewmodel());
    return ListenableBuilder(
      listenable: widget.viewmodel,
      builder: (context, _) {
        return Card(
          color: Colors.blue,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    color: Colors.yellow,
                    onPressed: () => widget.viewmodel.switchAutoTracks(),
                    icon: Icon(Icons.play_circle_outlined),
                  ),
                  Text("Nome scena"),
                  IconButton(
                    color: Colors.yellow,
                    onPressed: () => widget.viewmodel.addTrack(),
                    icon: Icon(Icons.add_rounded),
                  ),
                ],
              ),
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverList.builder(
                      itemCount: widget.viewmodel.tracks.length,
                      itemBuilder: (_, index) {
                        return Dismissible(
                          key: UniqueKey(),
                          // key: ValueKey(index),
                          onDismissed:
                              (_) => widget.viewmodel.removeTrackAt(index),
                          child: Track(
                            viewmodel: widget.viewmodel.tracks.elementAt(index),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
