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
    return Track(viewmodel: TrackViewmodel(track: File("")));
  }
}
