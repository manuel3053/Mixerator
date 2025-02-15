import 'package:flutter/material.dart';
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
      listenable: widget.viewmodel,
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
          listenable: widget.viewmodel.trackStatus,
          builder: (context, _) {
            return Card(
              color: Colors.blueGrey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(widget.viewmodel.name),
                  Text(widget.viewmodel.trackStatus.toString()),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          widget.viewmodel.switchTrackStatus();
                          setState(() {});
                        },
                        // icon: Icon(widget.viewmodel.iconData),
                        icon:
                            widget.viewmodel.trackStatus == TrackStatus.play
                                ? Icon(Icons.fax_rounded)
                                : Icon(Icons.calendar_view_day_sharp),
                      ),
                      Text("TIMELINE"),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Switch(value: true, onChanged: (b) {}),
                          Switch(value: true, onChanged: (b) {}),
                        ],
                      ),
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
