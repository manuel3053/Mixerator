# mixerator

## Features:
<!-- - Organize your tracks and separate them in different screens for more organization -->
- create scenes with the music that you want to play:
    - in a scene you can play N tracks
    - you can use one scene at a time
- Toggle/untoggle auto crossfade when changing scenes
- If a songs must be played continuosly between scenes, you can:
    - You have SCENE1: A B --- SCENE2: A C
    - You are playing all the tracks in SCENE1 (A B)
    - Now you want to play SCENE2: the track A in SCENE2 kept the playtime of the track A in SCENE1, so the music can continue without stops or jumps
<!-- - Organiza group of tracks where you can play just one of them: if I have a group with A, B, C and I'm playing A, if I play C, A stops and C starts -->
- Loop a track
- Adjust volume for each track
- Save and load projects

## Structure:
- Track: 
    - Volume slider
    - Timeline
        - global: the track keeps track of the playtime globally, so if you use the same song between scenes you can keep playing it seamlessly
        - local: it doesn't keep track of the playtime globally, but just the playtime inside the scene
    - Play:
        - auto: the track is started automatically if triggered "play scene"
        - manual: the track is not played if triggered "play scene"
- Scene: 
    - contains N tracks
    - Play scene: it will crossfade the previous scene and it will play the current scene, which means it will play all the tracks in "auto" mode
    - Crossfade speed slider

# Interface

## Track

### ViewModel
- Gestione dello stato del pulsante play/pause
- Gestione dello stato dello switch auto/manual
- Gestione dello stato dello switch global/local
- getter del titolo della traccia
- getter della stream per la timeline della traccia
- recupero dai repository delle informazioni sulla traccia

### UI
- Pulsante play/pause
- Switch auto/manual
- Switch global/local
- Titolo della traccia
- Timeline traccia

### Repository
- Recupero delle tracce dalla memoria del dispostivo
