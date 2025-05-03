import 'dart:async';
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
  late StreamSubscription _streamSubscription;
  final FaderStrategyContext _faderStrategyContext;
  final Set<Faders> _faders = {};
  PlayMode _playMode;
  TimelineMode _timelineMode;

  late Command0 selectFile;

  TrackViewmodel()
    : _audioPlayer = AudioPlayer(),
      _playMode = PlayMode.auto,
      _faderStrategyContext = FaderStrategyContext(),
      _timelineMode = TimelineMode.global {
    selectFile = Command0(_selectFile);
    _streamSubscription = _faderStrategyContext
        .executeFaderStrategy()
        .stream
        .listen((vol) => setVolume(vol));
    setFaders(_faders);
  }

  get name => _track!.path
      .substring(_track!.path.lastIndexOf('/') + 1)
      .split('.')
      .first;
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
      _faderStrategyContext.setFaderStrategy(FadeInOut(_audioPlayer));
    } else if (faders.contains(Faders.start) && !faders.contains(Faders.end)) {
      _faderStrategyContext.setFaderStrategy(FadeIn(_audioPlayer));
    } else if (!faders.contains(Faders.start) && faders.contains(Faders.end)) {
      _faderStrategyContext.setFaderStrategy(FadeOut(_audioPlayer));
    } else {
      _faderStrategyContext.setFaderStrategy(NoFade());
    }
    _streamSubscription.cancel();
    _streamSubscription = _faderStrategyContext
        .executeFaderStrategy()
        .stream
        .listen((vol) => setVolume(vol));
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

  void setTargetVolume(double volume) {
    // _audioPlayer.setVolume(volume);
    _faderStrategyContext.setTargetVolume(volume);
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
