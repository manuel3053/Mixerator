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
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white30,
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
                          ),
                        ),
                        // Switch(
                        //   value: widget.viewmodel.boolPlayMode,
                        //   onChanged: (b) => widget.viewmodel.switchPlayMode(),
                        //   thumbIcon: WidgetStateProperty<Icon>.fromMap(
                        //     <WidgetStatesConstraint, Icon>{
                        //       WidgetState.selected: Icon(Icons.auto_mode),
                        //       WidgetState.any: Icon(Icons.close),
                        //     },
                        //   ),
                        // ),
                        // Switch(
                        //   value: widget.viewmodel.boolTimelineMode,
                        //   onChanged:
                        //       (b) => widget.viewmodel.switchTimelineMode(),
                        //   // (b) => widget.viewmodel.switchTimelineMode.executeAndReset(),
                        //   thumbIcon: WidgetStateProperty<Icon>.fromMap(
                        //     <WidgetStatesConstraint, Icon>{
                        //       WidgetState.selected: Icon(Icons.one_k),
                        //       WidgetState.any: Icon(Icons.close),
                        //     },
                        //   ),
                        // ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: () => widget.viewmodel.switchTrackStatus(),
                          icon:
                              widget.viewmodel.playing
                                  ? Icon(Icons.pause_circle_outlined)
                                  : Icon(Icons.play_circle_outlined),
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
                                      onChangeEnd:
                                          (position) => widget.viewmodel.seek(
                                            position.toInt(),
                                          ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(snapshot.data!.toString()),
                                        Text(
                                          widget.viewmodel.duration.toString(),
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
                          isSelected:
                              widget.viewmodel.loopMode == LoopMode.all
                                  ? true
                                  : false,
                          selectedIcon: Icon(Icons.loop_outlined),
                          onPressed: () => widget.viewmodel.switchLoopMode(),
                          icon: Icon(Icons.loop_outlined, color: Colors.grey),
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
                          icon: Icon(Icons.volume_up_outlined),
                        ),
                        Expanded(
                          child: Slider(
                            value: widget.viewmodel.volume,
                            onChanged:
                                (volume) => widget.viewmodel.setVolume(volume),
                            // onChanged: (value) => widget.viewmodel.volume = value,
                          ),
                        ),
                        Expanded(
                          child: SegmentedButton(
                            emptySelectionAllowed: true,
                            multiSelectionEnabled: true,
                            segments: <ButtonSegment<Faders>>[
                              ButtonSegment<Faders>(
                                value: Faders.start,
                                label: Text(
                                  "Fade IN",
                                  textScaler: TextScaler.linear(0.3),
                                ),
                              ),
                              ButtonSegment<Faders>(
                                value: Faders.end,
                                label: Text(
                                  "Fade OUT",
                                  textScaler: TextScaler.linear(0.3),
                                ),
                              ),
                            ],
                            // selected: widget.viewmodel.faders,
                            selected: widget.viewmodel.faders,
                            onSelectionChanged:
                                (values) => widget.viewmodel.setFaders(values),
                          ),
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
