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
    return ListenableBuilder(
      listenable: widget.viewmodel.selectFile,
      builder: (context, _) {
        if (!widget.viewmodel.selectFile.completed &&
            !widget.viewmodel.selectFile.running &&
            !widget.viewmodel.selectFile.error) {
          return Card(
            child: IconButton(
              onPressed: () => widget.viewmodel.selectFile.execute(),
              icon: Icon(Icons.add),
            ),
          );
        }
        if (widget.viewmodel.selectFile.running) {
          return Center(child: CircularProgressIndicator());
        }
        if (widget.viewmodel.selectFile.error) {
          return Center(child: Text("Goofy ass"));
        }
        return ListenableBuilder(
          listenable: widget.viewmodel,
          builder: (context, _) {
            return Card(
              color: Colors.blueGrey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(widget.viewmodel.name),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
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
                                    max: widget.viewmodel.duration,
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
                      Switch(
                        value: widget.viewmodel.boolPlayMode,
                        onChanged: (b) => widget.viewmodel.switchPlayMode(),
                        thumbIcon: WidgetStateProperty<Icon>.fromMap(
                          <WidgetStatesConstraint, Icon>{
                            WidgetState.selected: Icon(Icons.auto_mode),
                            WidgetState.any: Icon(Icons.close),
                          },
                        ),
                      ),
                      Switch(
                        value: widget.viewmodel.boolTimelineMode,
                        onChanged: (b) => widget.viewmodel.switchTimelineMode(),
                        // (b) => widget.viewmodel.switchTimelineMode.executeAndReset(),
                        thumbIcon: WidgetStateProperty<Icon>.fromMap(
                          <WidgetStatesConstraint, Icon>{
                            WidgetState.selected: Icon(Icons.one_k),
                            WidgetState.any: Icon(Icons.close),
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.volume_up_sharp),
                      Expanded(
                        child: Slider(
                          value: widget.viewmodel.volume,
                          onChanged:
                              (volume) => widget.viewmodel.setVolume(volume),
                          // onChanged: (value) => widget.viewmodel.volume = value,
                        ),
                      ),
                      Icon(Icons.temple_hindu),
                      Expanded(child: Slider(value: 1, onChanged: (value) {})),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
