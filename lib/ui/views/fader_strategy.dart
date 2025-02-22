import 'package:just_audio/just_audio.dart';

class FaderStrategyContext {
  FaderStrategy _faderStrategy;

  FaderStrategyContext() : _faderStrategy = NoFade();

  void setFaderStrategy(FaderStrategy faderStrategy) {
    _faderStrategy = faderStrategy;
  }

  void executeFaderStrategy(
    AudioPlayer audioPlayer,
    Function(double) callback,
  ) {
    _faderStrategy.execute(audioPlayer, callback);
  }
}

abstract class FaderStrategy {
  void execute(AudioPlayer audioPlayer, Function(double) callback);
}

class FadeIn implements FaderStrategy {
  @override
  void execute(AudioPlayer audioPlayer, Function(double) callback) async {
    int fadeInEnd = 7000000;

    // FADE IN
    audioPlayer.positionStream
        .where((time) => (time.inMicroseconds < fadeInEnd))
        .map((time) => 1.0 * (time.inMicroseconds / fadeInEnd))
        .listen(callback);

    // COSTANT VOLUME
    audioPlayer.positionStream
        .where((time) => (time.inMicroseconds >= fadeInEnd))
        .map((time) => 1.0)
        .listen(callback);
  }
}

class FadeOut implements FaderStrategy {
  @override
  void execute(AudioPlayer audioPlayer, Function(double) callback) async {
    Duration trackDuration =
        await audioPlayer.durationStream.first ?? Duration(microseconds: 0);
    int trackLength = trackDuration.inMicroseconds;
    int fadeOutStart = 7000000;
    // COSTANT VOLUME
    audioPlayer.positionStream
        .where((time) => (time.inMicroseconds <= fadeOutStart))
        .map((time) => 1.0)
        .listen(callback);

    // FADE OUT
    audioPlayer.positionStream
        .where((time) => (time.inMicroseconds > fadeOutStart))
        .map(
          (time) =>
              1.0 *
              (1 -
                  ((time.inMicroseconds - fadeOutStart) /
                      (trackLength - fadeOutStart))),
        )
        .where((vol) => vol >= 0.0)
        .listen(callback);
  }
}

class FadeInOut implements FaderStrategy {
  @override
  void execute(AudioPlayer audioPlayer, Function(double) callback) async {
    // formulare una formula matematica che sia in grado di funzionare sia per fade in che per fade out, sfruttando soltanto la variazione del tempo
    int fadeInEnd = 7000000;
    Duration trackDuration =
        await audioPlayer.durationStream.first ?? Duration(microseconds: 0);
    int trackLength = trackDuration.inMicroseconds;
    int fadeOutStart = trackLength - 7000000;

    // FADE IN
    audioPlayer.positionStream
        .where((time) => (time.inMicroseconds < fadeInEnd))
        .map((time) => 1.0 * (time.inMicroseconds / fadeInEnd))
        .listen(callback);

    // COSTANT VOLUME
    audioPlayer.positionStream
        .where(
          (time) =>
              (time.inMicroseconds >= fadeInEnd &&
                  time.inMicroseconds <= fadeOutStart),
        )
        .map((time) => 1.0)
        .listen(callback);

    // FADE OUT
    audioPlayer.positionStream
        .where((time) => (time.inMicroseconds > fadeOutStart))
        .map(
          (time) =>
              1.0 *
              (1 -
                  ((time.inMicroseconds - fadeOutStart) /
                      (trackLength - fadeOutStart))),
        )
        .where((vol) => vol >= 0.0)
        .listen(callback);
  }
}

class NoFade implements FaderStrategy {
  @override
  void execute(AudioPlayer audioPlayer, Function(double) callback) async {
    // COSTANT VOLUME
    audioPlayer.positionStream.map((time) => 1.0).listen(callback);
  }
}
