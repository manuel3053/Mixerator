import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mixerator/ui/views/fader_strategy.dart';
import 'package:mixerator/utils/command.dart';
import 'package:mixerator/utils/result.dart';

enum PlayMode { auto, manual }

enum Faders { start, end }

enum TimelineMode { global, local }

enum TrackStatus { play, pause }

class TrackViewmodel extends ChangeNotifier {
  late File? _track;
  final AudioPlayer _audioPlayer;
  final Set<Faders> _faders = {Faders.start, Faders.end};
  PlayMode _playMode;
  TimelineMode _timelineMode;
  FaderStrategyContext _faderStrategyContext;

  late Command0 selectFile;

  TrackViewmodel()
    : _audioPlayer = AudioPlayer(),
      _playMode = PlayMode.auto,
      _faderStrategyContext = FaderStrategyContext(),
      _timelineMode = TimelineMode.global {
    selectFile = Command0(_selectFile);
    // _fade();
    _faderStrategyContext.executeFaderStrategy(_audioPlayer, setVolume);
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

  void setFaders(Set<Faders> faders) {
    _faders.clear();
    _faders.addAll(faders);
    if (faders.contains(Faders.start) && faders.contains(Faders.end)) {
      _faderStrategyContext.setFaderStrategy(FadeInOut());
    } else if (faders.contains(Faders.start) && !faders.contains(Faders.end)) {
      _faderStrategyContext.setFaderStrategy(FadeIn());
    } else if (!faders.contains(Faders.start) && faders.contains(Faders.end)) {
      _faderStrategyContext.setFaderStrategy(FadeOut());
    } else {
      _faderStrategyContext.setFaderStrategy(NoFade());
    }

    notifyListeners();
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
