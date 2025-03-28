import 'package:just_audio/just_audio.dart';
import 'package:async/async.dart';

class FaderStrategyContext {
  late FaderStrategy _faderStrategy;
  double _targetVolume = 1.0;

  FaderStrategyContext() : _faderStrategy = FadeInOut() {
    setTargetVolume(_targetVolume);
  }

  void setTargetVolume(double volume) {
    _targetVolume = volume;
    _faderStrategy.setTargetVolume(volume);
  }

  void setFaderStrategy(FaderStrategy faderStrategy) {
    _faderStrategy = faderStrategy;
  }

  Stream<double> executeFaderStrategy(AudioPlayer audioPlayer) {
    return _faderStrategy.execute(audioPlayer);
  }
}

abstract class FaderStrategy {
  late double _volume;

  Stream<double> execute(AudioPlayer audioPlayer);
  void setTargetVolume(double volume) {
    _volume = volume;
  }
}

class FadeIn extends FaderStrategy {
  @override
  Stream<double> execute(AudioPlayer audioPlayer) {
    int fadeInEnd = 7000000;

    // FADE IN
    Stream<double> fadeIn = audioPlayer.positionStream
        .where((time) => (time.inMicroseconds < fadeInEnd))
        .map((time) => _volume * (time.inMicroseconds / fadeInEnd));

    // CONSTANT VOLUME
    Stream<double> constant = audioPlayer.positionStream
        .where((time) => (time.inMicroseconds >= fadeInEnd))
        .map((time) => _volume);

    Stream<double> stream = StreamGroup.merge([fadeIn, constant]);

    return stream;
  }
}

class FadeOut extends FaderStrategy {
  @override
  Stream<double> execute(AudioPlayer audioPlayer) {
    Duration trackDuration = audioPlayer.duration ?? Duration(microseconds: 0);
    int trackLength = trackDuration.inMicroseconds;
    int fadeOutStart = 7000000;

    // CONSTANT VOLUME
    Stream<double> constant = audioPlayer.positionStream
        .where((time) => (time.inMicroseconds <= fadeOutStart))
        .map((time) => _volume);

    // FADE OUT
    Stream<double> fadeOut = audioPlayer.positionStream
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

    return stream;
  }
}

class FadeInOut extends FaderStrategy {
  @override
  Stream<double> execute(AudioPlayer audioPlayer) {
    int fadeInEnd = 7000000;
    Duration trackDuration = audioPlayer.duration ?? Duration(microseconds: 0);
    int trackLength = trackDuration.inMicroseconds;
    int fadeOutStart = trackLength - 7000000;

    // FADE IN
    Stream<double> fadeIn = audioPlayer.positionStream
        .where((time) => (time.inMicroseconds < fadeInEnd))
        .map((time) => _volume * (time.inMicroseconds / fadeInEnd));

    // CONSTANT VOLUME
    Stream<double> constant = audioPlayer.positionStream
        .where(
          (time) =>
              (time.inMicroseconds >= fadeInEnd &&
                  time.inMicroseconds <= fadeOutStart),
        )
        .map((time) => _volume);

    // FADE OUT
    Stream<double> fadeOut = audioPlayer.positionStream
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

    return stream;
  }
}

class NoFade extends FaderStrategy {
  @override
  Stream<double> execute(AudioPlayer audioPlayer) {
    // CONSTANT VOLUME
    Stream<double> constant = Stream.value(_volume);
    return constant;
  }
}
