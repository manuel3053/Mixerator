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

  late Command0 selectFile;
  // late Command0 switchTrackStatus;
  // late Command0 switchPlayMode;
  // late Command0 switchTimelineMode;
  // late Command0 switchLoopMode;

  TrackViewmodel({required File track})
    : _audioPlayer = AudioPlayer(),
      _playMode = PlayMode.auto,
      _timelineMode = TimelineMode.global {
    selectFile = Command0(_selectFile);
    // switchTrackStatus = Command0(_switchTrackStatus);
    // switchPlayMode = Command0(_switchPlayMode);
    // switchTimelineMode = Command0(_switchTimelineMode);
    // switchLoopMode = Command0(_switchLoopMode);
  }

  get name => _track!.path.substring(_track!.path.lastIndexOf('/') + 1);
  get loopMode => _audioPlayer.loopMode;
  get playing => _audioPlayer.playing;
  get position => _audioPlayer.position.inSeconds.toDouble();
  get duration => _audioPlayer.duration!.inSeconds.toDouble();
  get positionStream => _audioPlayer.positionStream.map((pos) => pos.inSeconds.toDouble());
  double get volume => _audioPlayer.volume;
  // In questo momento gli switch non rispondono bene all'input perché non c'è notifyListeners, inoltre passare da bool ad enum è sempre dispendioso, trovare una soluzione
  get boolPlayMode => _playMode == PlayMode.auto ? true : false;
  get boolTimelineMode => _timelineMode == TimelineMode.global ? true : false;

  void seek(int position) {
    _audioPlayer.seek(Duration(seconds: position));
    // notifyListeners();
  }

  void setVolume(double volume) {
    _audioPlayer.setVolume(volume);
    notifyListeners();
  }

  void switchLoopMode() {
      switch (loopMode) {
          case LoopMode.all:
        _audioPlayer.setLoopMode(LoopMode.off);
          case LoopMode.off:
        _audioPlayer.setLoopMode(LoopMode.all);
      }
      notifyListeners();
  }

  void switchTimelineMode() {
      switch (_timelineMode) {
          case TimelineMode.global:
          _timelineMode = TimelineMode.local;
        case TimelineMode.local:
          _timelineMode = TimelineMode.global;
      }
      notifyListeners();
  }

  void switchPlayMode() {
      switch (_playMode) {
        case PlayMode.auto:
          _playMode = PlayMode.manual;
        case PlayMode.manual:
          _playMode = PlayMode.auto;
      }
      notifyListeners();
  }

  void switchTrackStatus() {
      _audioPlayer.playing ? _audioPlayer.pause() : _audioPlayer.play();
      notifyListeners();
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
