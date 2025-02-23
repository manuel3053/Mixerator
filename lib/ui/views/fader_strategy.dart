import 'package:just_audio/just_audio.dart';
import 'package:async/async.dart';

class FaderStrategyContext {
  late FaderStrategy _faderStrategy;

  FaderStrategyContext() : _faderStrategy = FadeInOut();

  void setFaderStrategy(FaderStrategy faderStrategy) {
    _faderStrategy = faderStrategy;
  }

  Stream<double> executeFaderStrategy(
    AudioPlayer audioPlayer,
    Function(double) callback,
  ) {
    return _faderStrategy.execute(audioPlayer, callback);
  }
}

abstract class FaderStrategy {
  Stream<double> execute(AudioPlayer audioPlayer, Function(double) callback);
}

class FadeIn implements FaderStrategy {
  @override
  Stream<double> execute(AudioPlayer audioPlayer, Function(double) callback) {
    int fadeInEnd = 7000000;

    // FADE IN
    Stream<double> fadeIn = audioPlayer.positionStream
        .where((time) => (time.inMicroseconds < fadeInEnd))
        .map((time) => 1.0 * (time.inMicroseconds / fadeInEnd));

    // CONSTANT VOLUME
    Stream<double> constant = audioPlayer.positionStream
        .where((time) => (time.inMicroseconds >= fadeInEnd))
        .map((time) => 1.0);

    Stream<double> stream = StreamGroup.merge([fadeIn, constant]);

    stream.listen(callback);

    return stream;
  }
}

class FadeOut implements FaderStrategy {
  @override
  Stream<double> execute(AudioPlayer audioPlayer, Function(double) callback) {
    Duration trackDuration = audioPlayer.duration ?? Duration(microseconds: 0);
    int trackLength = trackDuration.inMicroseconds;
    int fadeOutStart = 7000000;
    // CONSTANT VOLUME
    Stream<double> constant = audioPlayer.positionStream
        .where((time) => (time.inMicroseconds <= fadeOutStart))
        .map((time) => 1.0);

    // FADE OUT
    Stream<double> fadeOut = audioPlayer.positionStream
        .where((time) => (time.inMicroseconds > fadeOutStart))
        .map(
          (time) =>
              1.0 *
              (1 -
                  ((time.inMicroseconds - fadeOutStart) /
                      (trackLength - fadeOutStart))),
        )
        .where((vol) => vol >= 0.0);

    Stream<double> stream = StreamGroup.merge([constant, fadeOut]);

    stream.listen(callback);

    return stream;
  }
}

class FadeInOut implements FaderStrategy {
  @override
  Stream<double> execute(AudioPlayer audioPlayer, Function(double) callback) {
    int fadeInEnd = 7000000;
    Duration trackDuration = audioPlayer.duration ?? Duration(microseconds: 0);
    int trackLength = trackDuration.inMicroseconds;
    int fadeOutStart = trackLength - 7000000;

    // FADE IN
    Stream<double> fadeIn = audioPlayer.positionStream
        .where((time) => (time.inMicroseconds < fadeInEnd))
        .map((time) => 1.0 * (time.inMicroseconds / fadeInEnd));

    // CONSTANT VOLUME
    Stream<double> constant = audioPlayer.positionStream
        .where(
          (time) =>
              (time.inMicroseconds >= fadeInEnd &&
                  time.inMicroseconds <= fadeOutStart),
        )
        .map((time) => 1.0);

    // FADE OUT
    Stream<double> fadeOut = audioPlayer.positionStream
        .where((time) => (time.inMicroseconds > fadeOutStart))
        .map(
          (time) =>
              1.0 *
              (1 -
                  ((time.inMicroseconds - fadeOutStart) /
                      (trackLength - fadeOutStart))),
        )
        .where((vol) => vol >= 0.0);

    Stream<double> tmp = StreamGroup.merge([fadeIn, constant]);
    Stream<double> stream = StreamGroup.merge([tmp, fadeOut]);

    stream.listen(callback);

    return stream;
  }
}

class NoFade implements FaderStrategy {
  @override
  Stream<double> execute(AudioPlayer audioPlayer, Function(double) callback) {
    // CONSTANT VOLUME
    Stream<double> constant = audioPlayer.positionStream.map((time) => 1.0);
    constant.listen(callback);
    return constant;
  }
}
