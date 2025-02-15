import 'package:flutter/material.dart';
import 'package:mixerator/ui/views/homepage_viewmodel.dart';
import 'package:mixerator/ui/views/scene_viewmodel.dart';
import 'package:mixerator/ui/views/track_viewmodel.dart';
import 'package:mixerator/ui/widgets/scene.dart';

class Homepage extends StatefulWidget {
  // final HomepageViewmodel viewModel;
  // Il viewmodel della traccia è presente temporaneamente per testing, andrà poi spostato nel widget della traccia
  final HomepageViewmodel viewmodel;
  const Homepage({super.key, required this.viewmodel});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: widget.viewmodel,
          builder: (context, _) {
            return Scene(viewmodel: SceneViewmodel());
          },
        ),
      ),
    );
  }
}
