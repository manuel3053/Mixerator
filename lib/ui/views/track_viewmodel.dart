import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mixerator/utils/command.dart';
import 'package:mixerator/utils/result.dart';

enum PlayMode { auto, manual }

enum TimelineMode { global, local }

enum TrackStatus { play, pause }

class _TrackStatusController extends ChangeNotifier {
  final AudioPlayer _audioPlayer;
  IconData _iconData;
  TrackStatus _trackStatus;

  _TrackStatusController({required AudioPlayer audioPlayer})
    : _audioPlayer = audioPlayer,
      _iconData = Icons.bedtime_off_rounded,
      // _iconData = Icons.play_circle_outlined,
      _trackStatus = TrackStatus.pause;

  get iconData => _iconData;

  Future<void> switchTrackStatus() async {
    switch (_trackStatus) {
      case TrackStatus.play:
        _trackStatus = TrackStatus.pause;
        _iconData = Icons.play_circle_outlined;
        await _audioPlayer.pause();
        notifyListeners();
      case TrackStatus.pause:
        _trackStatus = TrackStatus.play;
        _iconData = Icons.pause_circle_outlined;
        await _audioPlayer.play();
        notifyListeners();
    }
  }
}

class TrackViewmodel extends ChangeNotifier {
  File? _track;
  final AudioPlayer _audioPlayer;
  late _TrackStatusController _trackStatusController;
  PlayMode _playMode;
  TimelineMode _timelineMode;

  late Command0 selectFile;

  TrackViewmodel({required File track})
    : _audioPlayer = AudioPlayer(),
      _playMode = PlayMode.auto,
      _timelineMode = TimelineMode.global {
    _trackStatusController = _TrackStatusController(audioPlayer: _audioPlayer);
    _trackStatusController.addListener(notifyListeners);
    selectFile = Command0(_selectFile);
  }

  get trackStatusControllerListeners => _trackStatusController.hasListeners;
  get iconData => _trackStatusController.iconData;
  get listeners => hasListeners;
  get trackStatusController => _trackStatusController;
  get name => _track!.path.substring(_track!.path.lastIndexOf('/') + 1);
  set playMode(PlayMode p) => _playMode = p;
  set timelineMode(TimelineMode t) => _timelineMode = t;

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
