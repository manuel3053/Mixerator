import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mixerator/ui/views/track_viewmodel.dart';

class Track extends StatefulWidget {
  final TrackViewmodel viewmodel;
  const Track({super.key, required this.viewmodel});

  @override
  State<Track> createState() => _TrackState();
}

class _TrackState extends State<Track> {
  String secondsToTimeFormat(double totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = (totalSeconds % 60).toInt();
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    widget.viewmodel.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListenableBuilder(
          listenable: widget.viewmodel.selectFile,
          builder: (context, _) {
            if (!widget.viewmodel.selectFile.completed &&
                !widget.viewmodel.selectFile.running) {
              return IconButton(
                onPressed: () => widget.viewmodel.selectFile.execute(),
                icon: Icon(Icons.add),
              );
            }
            if (widget.viewmodel.selectFile.running) {
              return Center(child: CircularProgressIndicator());
            }
            return ListenableBuilder(
              listenable: widget.viewmodel,
              builder: (context, _) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            widget.viewmodel.name,
                            overflow: TextOverflow.fade,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: () => widget.viewmodel.switchTrackStatus(),
                          icon: widget.viewmodel.playing
                              ? Icon(Icons.pause)
                              : Icon(Icons.play_arrow),
                        ),
                        Expanded(
                          child: StreamBuilder(
                            stream: widget.viewmodel.positionStream,
                            builder: (context, AsyncSnapshot<double> snapshot) {
                              if (snapshot.hasData) {
                                return Column(
                                  children: [
                                    Slider(
                                      value: snapshot.data!,
                                      max: widget.viewmodel.duration + 1,
                                      onChanged: (value) {},
                                      onChangeEnd: (position) => widget
                                          .viewmodel
                                          .seek(position.toInt()),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          secondsToTimeFormat(snapshot.data!),
                                        ),
                                        Text(
                                          secondsToTimeFormat(
                                            widget.viewmodel.duration,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              }
                              return CircularProgressIndicator();
                            },
                          ),
                        ),
                        IconButton(
                          isSelected: widget.viewmodel.loopMode == LoopMode.all
                              ? true
                              : false,
                          selectedIcon: Icon(Icons.loop),
                          onPressed: () => widget.viewmodel.switchLoopMode(),
                          icon: Icon(Icons.loop),
                        ),
                      ],
                    ),
                    Row(
                      // mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Icon(Icons.volume_up_sharp),
                        IconButton(
                          onPressed: () {},
                          onLongPress: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Non servo a nulla, il mio padrone mi ha creato perché non aveva voglia di sistemare a mano il layout",
                                ),
                              ),
                            );
                          },
                          icon: Icon(Icons.volume_up_sharp),
                        ),
                        Expanded(
                          child: Slider(
                            value: widget.viewmodel.volume,
                            onChanged: (volume) =>
                                widget.viewmodel.setTargetVolume(volume),
                          ),
                        ),
                        SegmentedButton(
                          showSelectedIcon: false,
                          emptySelectionAllowed: true,
                          multiSelectionEnabled: true,
                          segments: <ButtonSegment<Faders>>[
                            ButtonSegment<Faders>(
                              value: Faders.start,
                              label: Text("In"),
                            ),
                            ButtonSegment<Faders>(
                              value: Faders.end,
                              label: Text("Out"),
                            ),
                          ],
                          selected: widget.viewmodel.faders,
                          onSelectionChanged: (values) =>
                              widget.viewmodel.setFaders(values),
                        ),
                      ],
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
