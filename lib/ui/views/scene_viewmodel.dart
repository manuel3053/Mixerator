import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mixerator/ui/views/track_viewmodel.dart';
import 'package:mixerator/utils/command.dart';
import 'package:mixerator/utils/result.dart';

class HomeViewmodel extends ChangeNotifier {
  final Set<TrackViewmodel> tracks = {};

  HomeViewmodel() {
    tracks.add(TrackViewmodel());
  }

  void addTrack() {
    tracks.add(TrackViewmodel());
    notifyListeners();
  }

  void removeTrackAt(int index) {
    tracks.remove(tracks.elementAt(index));
    notifyListeners();
  }

  void switchAutoTracks() {
    for (TrackViewmodel t in tracks) {
      t.switchTrackStatus();
    }
  }
}
