import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;

class BuddyRiveView extends StatefulWidget {
  final String assetPath;
  final double? height;
  final double? width;
  final rive.Fit fit;

  const BuddyRiveView({
    required this.assetPath,
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
    _painter = _BuddyRivePainter(riveFit: widget.fit);
    _riveFile = _loadRiveFile();
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
  rive.StateMachine? _stateMachine;
  rive.Animation? _animation;

  _BuddyRivePainter({required rive.Fit riveFit}) : super(fit: riveFit);

  @override
  void artboardChanged(rive.Artboard artboard) {
    _stateMachine?.dispose();
    _animation?.dispose();
    _stateMachine = null;
    _animation = null;

    super.artboardChanged(artboard);

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
