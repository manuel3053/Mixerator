import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mixerator/utils/command.dart';
import 'package:mixerator/utils/result.dart';

enum PlayMode { auto, manual }

enum Faders { start, end }

enum TimelineMode { global, local }

enum TrackStatus { play, pause }

class TrackViewmodel extends ChangeNotifier {
  late File? _track;
  final AudioPlayer _audioPlayer;
  final Set<Faders> _faders = {};
  double _faderVolume;
  PlayMode _playMode;
  TimelineMode _timelineMode;

  late Command0 selectFile;
  late Command0 fadeIn;

  TrackViewmodel()
    : _audioPlayer = AudioPlayer(),
      _playMode = PlayMode.auto,
      _faderVolume = 1.0,
      _timelineMode = TimelineMode.global {
    selectFile = Command0(_selectFile);
    fadeIn = Command0(_fadeIn);
    _fade();
  }

  get name => _track!.path.substring(_track!.path.lastIndexOf('/') + 1);
  get loopMode => _audioPlayer.loopMode;
  get playing => _audioPlayer.playing;
  get position => _audioPlayer.position.inSeconds.toDouble();
  get duration => _audioPlayer.duration!.inSeconds.toDouble();
  get positionStream =>
      _audioPlayer.positionStream.map((pos) => pos.inSeconds.toDouble());
  get faders => _faders;
  double get volume => _audioPlayer.volume;
  // In questo momento gli switch non rispondono bene all'input perché non c'è notifyListeners, inoltre passare da bool ad enum è sempre dispendioso, trovare una soluzione
  get boolPlayMode => _playMode == PlayMode.auto ? true : false;
  get boolTimelineMode => _timelineMode == TimelineMode.global ? true : false;

  void seek(int position) {
    _audioPlayer.seek(Duration(seconds: position));
    notifyListeners();
  }

  void setFaders(Set<Faders> f) {
    _faders.clear();
    _faders.addAll(f);
    notifyListeners();
  }

  Future<Result> _fadeIn() async {
    // il rapporto ottimale tra il tempo e l'incremento sembra 0.001 : 1 = x : y
    double endVolume = _audioPlayer.volume;
    for (double i = 0.0; i <= endVolume; i += 0.001) {
      _audioPlayer.setVolume(i);
      await Future.delayed(Duration(microseconds: 1));
      notifyListeners();
    }
    return Result.ok(endVolume);
  }

  void setFaderVolume(double v) {
    _audioPlayer.setVolume(v);
    notifyListeners();
  }

  void _fade() async {
    _audioPlayer.positionStream
        .where((time) => time.inMicroseconds < 7000000)
        .map((time) => 1.0 * (time.inMicroseconds / 7000000))
        .listen(setFaderVolume);
  }

  void switchTrackStatus() async {
    if (_audioPlayer.playing) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
    notifyListeners();
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
