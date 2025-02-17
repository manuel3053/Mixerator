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
  late File? _track;
  final AudioPlayer _audioPlayer;
  double _faderSpeed;
  bool _isFaderActive;
  PlayMode _playMode;
  TimelineMode _timelineMode;

  late Command0 selectFile;
  late Command0 fadeIn;

  TrackViewmodel()
    : _audioPlayer = AudioPlayer(),
      _playMode = PlayMode.auto,
      _faderSpeed = 1,
      _isFaderActive = true,
      _timelineMode = TimelineMode.global {
    selectFile = Command0(_selectFile);
    fadeIn = Command0(_fadeIn);
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
  get faderSpeed => _faderSpeed;
  get isFaderActive => _isFaderActive;

  void seek(int position) {
    _audioPlayer.seek(Duration(seconds: position));
    notifyListeners();
  }

  Future<Result> _fadeIn() async {
    // il rapporto ottimale tra il tempo e l'incremento sembra 0.001 : 1 = x : y
    double endVolume = _audioPlayer.volume;
    for (double i = 0.0; i <= endVolume; i += 0.001 ) {
      _audioPlayer.setVolume(i);
      await Future.delayed(Duration(microseconds: _faderSpeed.toInt()));
      notifyListeners();
      if (!_audioPlayer.playing) {
        _audioPlayer.pause();
        _audioPlayer.setVolume(endVolume);
        break;
      }
    }
    return Result.ok(endVolume);
  }
   
  void setFaderSpeed(double speed) {
    _faderSpeed = speed;
    notifyListeners();
  }

  void switchTrackStatus() async {
    if (_audioPlayer.playing) {
      _audioPlayer.pause();
    }
    else {
      // if (_isFaderActive && _audioPlayer.position.inSeconds.toDouble() < _faderSpeed) {
      //   double endVolume = _audioPlayer.volume;
      //   double volume = 0.0;
      //   // double increment = 0.001;
      //   double increment = endVolume / ((_faderSpeed - _audioPlayer.position.inSeconds.toDouble()) * 100);
      //   print("Increment");
      //   print(increment);
      //   _audioPlayer.play();
      //   while (_audioPlayer.position.inSeconds.toDouble() < _faderSpeed && volume < endVolume) {
      //     _audioPlayer.setVolume(volume);
      //     await Future.delayed(Duration(microseconds: 1));
      //     notifyListeners();
      //     volume += increment;
      //   }
      // }
      // else {
      //   _audioPlayer.play();
      // }
      // double endVolume = _audioPlayer.volume;
        _audioPlayer.play();
      if (_isFaderActive) {
        fadeIn.execute();
      }
    }
    notifyListeners();
  }

  void setVolume(double volume) {
    _audioPlayer.setVolume(volume);
    notifyListeners();
  }

  void switchFader() {
    _isFaderActive = !_isFaderActive;
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
