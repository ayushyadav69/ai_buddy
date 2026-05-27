import 'package:ai_buddy/features/buddy/presentation/controllers/buddy_activity_state.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;

class BuddyRiveView extends StatefulWidget {
  final String assetPath;
  final BuddyActivityState activity;
  final double? height;
  final double? width;
  final rive.Fit fit;

  const BuddyRiveView({
    required this.assetPath,
    this.activity = BuddyActivityState.idle,
    this.height,
    this.width,
    this.fit = rive.Fit.contain,
    super.key,
  });

  @override
  State<BuddyRiveView> createState() => _BuddyRiveViewState();
}

class _BuddyRiveViewState extends State<BuddyRiveView> {
  late final Future<rive.File> _riveFile;
  late final _BuddyRivePainter _painter;

  rive.File? _loadedFile;
  var _isDisposed = false;

  @override
  void initState() {
    super.initState();

    _painter = _BuddyRivePainter(
      riveFit: widget.fit,
      activity: widget.activity,
    );

    _riveFile = _loadRiveFile();
  }

  @override
  void didUpdateWidget(covariant BuddyRiveView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.activity != widget.activity) {
      _painter.setActivity(widget.activity);
    }
  }

  Future<rive.File> _loadRiveFile() async {
    final file = await rive.File.asset(
      widget.assetPath,
      riveFactory: rive.Factory.rive,
    );

    if (file == null) {
      throw FlutterError('Unable to decode ${widget.assetPath}');
    }

    if (_isDisposed) {
      file.dispose();
    } else {
      _loadedFile = file;
    }

    return file;
  }

  @override
  void dispose() {
    _isDisposed = true;
    _painter.dispose();
    _loadedFile?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: FutureBuilder<rive.File>(
        future: _riveFile,
        builder: (context, snapshot) {
          final file = snapshot.data;

          if (file != null) {
            return rive.RiveFileWidget(file: file, painter: _painter);
          }

          if (snapshot.hasError) {
            debugPrint('Failed to load Rive asset: ${snapshot.error}');
            return const Center(
              child: Icon(Icons.smart_toy_outlined, size: 48),
            );
          }

          return const Center(
            child: SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
      ),
    );
  }
}

base class _BuddyRivePainter extends rive.BasicArtboardPainter {
  static const _talkInputName = 'Talk';
  static const _hearInputName = 'Hear';
  static const _checkInputName = 'Check';
  static const _lookInputName = 'Look';

  rive.Artboard? _artboard;
  rive.StateMachine? _stateMachine;
  rive.Animation? _animation;

  rive.BooleanInput? _talkInput;
  rive.BooleanInput? _hearInput;
  rive.BooleanInput? _checkInput;
  rive.BooleanInput? _lookInput;

  BuddyActivityState _activity;
  String? _currentAnimationName;

  _BuddyRivePainter({
    required rive.Fit riveFit,
    required BuddyActivityState activity,
  }) : _activity = activity,
       super(fit: riveFit);

  void setActivity(BuddyActivityState activity) {
    if (_activity == activity) {
      return;
    }

    _activity = activity;
    _applyActivityToRive();
  }

  @override
  void artboardChanged(rive.Artboard artboard) {
    _disposeRuntimeObjects();

    _artboard = artboard;

    super.artboardChanged(artboard);

    debugPrint('Rive artboard loaded: ${artboard.name}');
    debugPrint('Rive state machine count: ${artboard.stateMachineCount()}');
    debugPrint('Rive animation count: ${artboard.animationCount()}');

    for (var index = 0; index < artboard.stateMachineCount(); index++) {
      final stateMachine = artboard.stateMachineAt(index);
      debugPrint('Rive state machine[$index]: ${stateMachine?.name}');
    }

    for (var index = 0; index < artboard.animationCount(); index++) {
      final animation = artboard.animationAt(index);
      debugPrint('Rive animation[$index]: ${animation.name}');
    }

    _stateMachine =
        artboard.defaultStateMachine() ??
        (artboard.stateMachineCount() > 0 ? artboard.stateMachineAt(0) : null);

    final stateMachine = _stateMachine;

    if (stateMachine != null) {
      _talkInput = _booleanInput(stateMachine, _talkInputName);
      _hearInput = _booleanInput(stateMachine, _hearInputName);
      _checkInput = _booleanInput(stateMachine, _checkInputName);
      _lookInput = _booleanInput(stateMachine, _lookInputName);
    }

    _applyActivityToRive();
    notifyListeners();
  }

  void _applyActivityToRive() {
    if (_canUseBooleanInputs) {
      _applyActivityUsingInputs();
      return;
    }

    _applyActivityUsingAnimations();
  }

  bool get _canUseBooleanInputs {
    return _talkInput != null ||
        _hearInput != null ||
        _checkInput != null ||
        _lookInput != null;
  }

  void _applyActivityUsingInputs() {
    final stateMachine = _stateMachine;

    if (stateMachine == null) {
      return;
    }

    _setInput(_talkInput, false);
    _setInput(_hearInput, false);
    _setInput(_checkInput, false);
    _setInput(_lookInput, false);

    switch (_activity) {
      case BuddyActivityState.idle:
        _setInput(_lookInput, true);

      case BuddyActivityState.listening:
        _setInput(_hearInput, true);

      case BuddyActivityState.thinking:
        _setInput(_checkInput, true);

      case BuddyActivityState.talking:
        _setInput(_talkInput, true);

      case BuddyActivityState.celebrating:
        _setInput(_lookInput, true);

      case BuddyActivityState.offline:
        _setInput(_lookInput, true);
    }

    stateMachine.requestAdvance();
    notifyListeners();
  }

  void _applyActivityUsingAnimations() {
    final animationName = _animationNameForActivity(_activity);
    _setAnimationByName(animationName);
    notifyListeners();
  }

  String _animationNameForActivity(BuddyActivityState activity) {
    switch (activity) {
      case BuddyActivityState.idle:
        return 'Idle';

      case BuddyActivityState.listening:
        return 'Greeting';

      case BuddyActivityState.thinking:
        return 'Thinking';

      case BuddyActivityState.talking:
        return 'Talking';

      case BuddyActivityState.celebrating:
        return 'Celebrate';

      case BuddyActivityState.offline:
        return 'Idle';
    }
  }

  void _setAnimationByName(String animationName) {
    final artboard = _artboard;

    if (artboard == null) {
      return;
    }

    if (_currentAnimationName == animationName && _animation != null) {
      return;
    }

    _animation?.dispose();
    _animation = null;
    _currentAnimationName = null;

    for (var index = 0; index < artboard.animationCount(); index++) {
      final animation = artboard.animationAt(index);

      if (animation.name == animationName) {
        _animation = animation;
        _currentAnimationName = animationName;
        return;
      }

      animation.dispose();
    }

    for (var index = 0; index < artboard.animationCount(); index++) {
      final animation = artboard.animationAt(index);

      if (animation.name == 'Idle') {
        _animation = animation;
        _currentAnimationName = 'Idle';
        return;
      }

      animation.dispose();
    }
  }

  void _setInput(rive.BooleanInput? input, bool value) {
    if (input == null) {
      return;
    }

    input.value = value;
  }

  rive.BooleanInput? _booleanInput(
    rive.StateMachine stateMachine,
    String inputName,
  ) {
    // Rive now recommends Data Binding, but some marketplace .riv files
    // expose old-style state machine boolean inputs.
    //
    // Keeping this access in one place makes it easy to migrate later.
    // ignore: deprecated_member_use
    return stateMachine.boolean(inputName);
  }

  @override
  bool advance(double elapsedSeconds) {
    if (_canUseBooleanInputs) {
      final stateMachine = _stateMachine;

      if (stateMachine != null) {
        return stateMachine.advanceAndApply(elapsedSeconds);
      }
    }

    final animation = _animation;

    if (animation != null) {
      return animation.advanceAndApply(elapsedSeconds);
    }

    return super.advance(elapsedSeconds);
  }

  @override
  void dispose() {
    _disposeRuntimeObjects();
    super.dispose();
  }

  void _disposeRuntimeObjects() {
    _stateMachine?.dispose();
    _animation?.dispose();

    _artboard = null;
    _stateMachine = null;
    _animation = null;

    _talkInput = null;
    _hearInput = null;
    _checkInput = null;
    _lookInput = null;

    _currentAnimationName = null;
  }
}
