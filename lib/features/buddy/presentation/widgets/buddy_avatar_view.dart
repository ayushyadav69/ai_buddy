import 'package:ai_buddy/features/buddy/presentation/controllers/buddy_activity_state.dart';
import 'package:ai_buddy/features/buddy/presentation/controllers/buddy_state_controller.dart';
import 'package:ai_buddy/features/buddy/presentation/widgets/buddy_asset_paths.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;

class BuddyAvatarView extends StatefulWidget {
  final BuddyUiState state;

  const BuddyAvatarView({required this.state, super.key});

  @override
  State<BuddyAvatarView> createState() => _BuddyAvatarViewState();
}

class _BuddyAvatarViewState extends State<BuddyAvatarView> {
  late final Future<rive.File> _riveFile;
  late final _BuddyRivePainter _painter;
  rive.File? _loadedFile;
  var _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _painter = _BuddyRivePainter();
    _riveFile = _loadRiveFile();
  }

  Future<rive.File> _loadRiveFile() async {
    final file = await rive.File.asset(
      BuddyAssetPaths.voiceBuddy,
      riveFactory: rive.Factory.rive,
    );

    if (file == null) {
      throw FlutterError('Unable to decode ${BuddyAssetPaths.voiceBuddy}');
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
      height: 130,
      width: 130,
      child: FutureBuilder<rive.File>(
        future: _riveFile,
        builder: (context, snapshot) {
          final file = snapshot.data;
          if (file != null) {
            return rive.RiveFileWidget(file: file, painter: _painter);
          }

          if (snapshot.hasError) {
            debugPrint('Failed to load buddy Rive asset: ${snapshot.error}');
            return _BuddyAvatarFallback(state: widget.state);
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
  rive.StateMachine? _stateMachine;
  rive.Animation? _animation;

  _BuddyRivePainter() : super(fit: rive.Fit.contain);

  @override
  void artboardChanged(rive.Artboard artboard) {
    _stateMachine?.dispose();
    _animation?.dispose();
    _stateMachine = null;
    _animation = null;

    super.artboardChanged(artboard);

    // debugPrint('Rive artboard loaded: ${artboard.name}');
    // debugPrint('Rive state machine count: ${artboard.stateMachineCount()}');
    // debugPrint('Rive animation count: ${artboard.animationCount()}');

    // for (var index = 0; index < artboard.stateMachineCount(); index++) {
    //   final stateMachine = artboard.stateMachineAt(index);
    //   debugPrint('Rive state machine[$index]: ${stateMachine?.name}');
    // }

    // for (var index = 0; index < artboard.animationCount(); index++) {
    //   final animation = artboard.animationAt(index);
    //   debugPrint('Rive animation[$index]: ${animation.name}');
    // }

    _stateMachine =
        artboard.defaultStateMachine() ??
        (artboard.stateMachineCount() > 0 ? artboard.stateMachineAt(0) : null);

    if (_stateMachine == null && artboard.animationCount() > 0) {
      _animation = artboard.animationAt(0);
    }

    notifyListeners();
  }

  @override
  bool advance(double elapsedSeconds) {
    final stateMachine = _stateMachine;
    if (stateMachine != null) {
      return stateMachine.advanceAndApply(elapsedSeconds);
    }

    final animation = _animation;
    if (animation != null) {
      return animation.advanceAndApply(elapsedSeconds);
    }

    return super.advance(elapsedSeconds);
  }

  @override
  void dispose() {
    _stateMachine?.dispose();
    _animation?.dispose();
    _stateMachine = null;
    _animation = null;
    super.dispose();
  }
}

class _BuddyAvatarFallback extends StatelessWidget {
  final BuddyUiState state;

  const _BuddyAvatarFallback({required this.state});

  @override
  Widget build(BuildContext context) {
    final icon = switch (state.activity) {
      BuddyActivityState.idle => Icons.smart_toy_outlined,
      BuddyActivityState.listening => Icons.hearing,
      BuddyActivityState.thinking => Icons.psychology_alt_outlined,
      BuddyActivityState.talking => Icons.record_voice_over_outlined,
      BuddyActivityState.celebrating => Icons.celebration_rounded,
      BuddyActivityState.offline => Icons.wifi_off,
    };

    return CircleAvatar(radius: 44, child: Icon(icon, size: 44));
  }
}
