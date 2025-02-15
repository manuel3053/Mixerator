import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mixerator/utils/command.dart';
import 'package:mixerator/utils/result.dart';

enum PlayMode { auto, manual }

enum TimelineMode { global, local }

enum TrackStatus { play, pause }

class TrackViewmodel extends ChangeNotifier {
  File? _track;
  final AudioPlayer _audioPlayer;
  PlayMode _playMode;
  TimelineMode _timelineMode;
  TrackStatus _trackStatus;

  late Command0 selectFile;

  TrackViewmodel({required File track})
    : _audioPlayer = AudioPlayer(),
      _playMode = PlayMode.auto,
      _trackStatus = TrackStatus.pause,
      _timelineMode = TimelineMode.global {
    selectFile = Command0(_selectFile);
  }

  // get trackStatusControllerListeners => _trackStatusController.hasListeners;
  // get iconData => _trackStatusController.iconData;
  get trackStatus => _trackStatus;
  get listeners => hasListeners;
  // get trackStatusController => _trackStatusController;
  get name => _track!.path.substring(_track!.path.lastIndexOf('/') + 1);
  set playMode(PlayMode p) => _playMode = p;
  set timelineMode(TimelineMode t) => _timelineMode = t;

  Future<void> switchTrackStatus() async {
    switch (_trackStatus) {
      case TrackStatus.play:
        _trackStatus = TrackStatus.pause;
        await _audioPlayer.pause();
      case TrackStatus.pause:
        _trackStatus = TrackStatus.play;
        await _audioPlayer.play();
    }
    // notifyListeners();
    print(_trackStatus.toString());
  }

  Future<Result> _selectFile() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result != null) {
        _track = File(result.files.single.path!);
        await _audioPlayer.setUrl(_track!.path);
        // _isFileSelected = true;
        return Result.ok(_track);
      }
      return Result.error(Exception());
    } finally {
      notifyListeners();
    }
  }
}
