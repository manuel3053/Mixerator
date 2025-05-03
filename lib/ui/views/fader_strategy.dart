import 'dart:async';

import 'package:just_audio/just_audio.dart';
import 'package:async/async.dart';

class FaderStrategyContext {
  // StreamSubscription: StreamController
  late FaderStrategy _faderStrategy;
  StreamController _faderStreamController;
  double _targetVolume;

  FaderStrategyContext()
    : _faderStrategy = NoFade(),
      _targetVolume = 1.0,
      _faderStreamController = StreamController() {
    _faderStrategy.setTargetVolume(_targetVolume);
  }

  void setTargetVolume(double volume) {
    _targetVolume = volume;
    _faderStrategy.setTargetVolume(_targetVolume);
  }

  void setFaderStrategy(FaderStrategy faderStrategy) {
    _faderStrategy = faderStrategy;
    _faderStrategy.setTargetVolume(_targetVolume);
  }

  StreamController executeFaderStrategy() {
    // _faderStreamController.close();
    _faderStreamController = _faderStrategy.execute();
    return _faderStreamController;
  }
}

abstract class FaderStrategy {
  late double _volume;

  StreamController execute();
  void setTargetVolume(double volume) {
    _volume = volume;
  }
}

class FadeIn extends FaderStrategy {
  final AudioPlayer _audioPlayer;

  FadeIn(AudioPlayer audioPlayer) : _audioPlayer = audioPlayer;

  @override
  StreamController execute() {
    int fadeInEnd = 7000000;

    // FADE IN
    Stream<double> fadeIn = _audioPlayer.positionStream
        .where((time) => (time.inMicroseconds < fadeInEnd))
        .map((time) => _volume * (time.inMicroseconds / fadeInEnd));

    // CONSTANT VOLUME
    Stream<double> constant = _audioPlayer.positionStream
        .where((time) => (time.inMicroseconds >= fadeInEnd))
        .map((time) => _volume);

    Stream<double> stream = StreamGroup.merge([fadeIn, constant]);
    StreamController streamController = StreamController();
    streamController.addStream(stream);

    return streamController;
  }
}

class FadeOut extends FaderStrategy {
  final AudioPlayer _audioPlayer;

  FadeOut(AudioPlayer audioPlayer) : _audioPlayer = audioPlayer;

  @override
  StreamController execute() {
    Duration trackDuration = _audioPlayer.duration ?? Duration(microseconds: 0);
    int trackLength = trackDuration.inMicroseconds;
    int fadeOutStart = trackLength - 7000000;

    // CONSTANT VOLUME
    Stream<double> constant = _audioPlayer.positionStream
        .where((time) => (time.inMicroseconds <= fadeOutStart))
        .map((time) => _volume);

    // FADE OUT
    Stream<double> fadeOut = _audioPlayer.positionStream
        .where((time) => (time.inMicroseconds > fadeOutStart))
        .map(
          (time) =>
              _volume *
              (1 -
                  ((time.inMicroseconds - fadeOutStart) /
                      (trackLength - fadeOutStart))),
        )
        .where((vol) => vol >= 0.0);

    Stream<double> stream = StreamGroup.merge([constant, fadeOut]);
    StreamController streamController = StreamController();
    streamController.addStream(stream);

    return streamController;
  }
}

class FadeInOut extends FaderStrategy {
  final AudioPlayer _audioPlayer;

  FadeInOut(AudioPlayer audioPlayer) : _audioPlayer = audioPlayer;

  @override
  StreamController execute() {
    int fadeInEnd = 7000000;
    Duration trackDuration = _audioPlayer.duration ?? Duration(microseconds: 0);
    int trackLength = trackDuration.inMicroseconds;
    int fadeOutStart = trackLength - 7000000;

    // FADE IN
    Stream<double> fadeIn = _audioPlayer.positionStream
        .where((time) => (time.inMicroseconds < fadeInEnd))
        .map((time) => _volume * (time.inMicroseconds / fadeInEnd));

    // CONSTANT VOLUME
    Stream<double> constant = _audioPlayer.positionStream
        .where(
          (time) =>
              (time.inMicroseconds >= fadeInEnd &&
              time.inMicroseconds <= fadeOutStart),
        )
        .map((time) => _volume);

    // FADE OUT
    Stream<double> fadeOut = _audioPlayer.positionStream
        .where((time) => (time.inMicroseconds > fadeOutStart))
        .map(
          (time) =>
              _volume *
              (1 -
                  ((time.inMicroseconds - fadeOutStart) /
                      (trackLength - fadeOutStart))),
        )
        .where((vol) => vol >= 0.0);

    Stream<double> tmp = StreamGroup.merge([fadeIn, constant]);
    Stream<double> stream = StreamGroup.merge([tmp, fadeOut]);
    StreamController streamController = StreamController();
    streamController.addStream(stream);

    return streamController;
  }
}

class NoFade extends FaderStrategy {
  @override
  StreamController execute() {
    // CONSTANT VOLUME
    Stream<double> constant = Stream.value(_volume);
    StreamController streamController = StreamController();
    streamController.addStream(constant);

    return streamController;
  }
}
