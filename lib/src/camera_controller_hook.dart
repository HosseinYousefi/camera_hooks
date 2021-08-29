import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

CameraController? useCameraController(
  CameraDescription description,
  ResolutionPreset resolutionPreset, {
  bool enableAudio = true,
  ImageFormatGroup? imageFormatGroup,
  List<Object?>? keys,
}) {
  return use(
    _CameraControllerHook(
      description,
      resolutionPreset,
      enableAudio: enableAudio,
      imageFormatGroup: imageFormatGroup,
      keys: keys,
    ),
  );
}

class _CameraControllerHook extends Hook<CameraController?> {
  /// The properties of the camera device controlled by this controller.
  final CameraDescription description;

  /// The resolution this controller is targeting.
  ///
  /// This resolution preset is not guaranteed to be available on the device,
  /// if unavailable a lower resolution will be used.
  ///
  /// See also: [ResolutionPreset].
  final ResolutionPreset resolutionPreset;

  /// Whether to include audio when recording a video.
  final bool enableAudio;

  /// The [ImageFormatGroup] describes the output of the raw image format.
  ///
  /// When null the imageFormat will fallback to the platforms default.
  final ImageFormatGroup? imageFormatGroup;

  _CameraControllerHook(
    this.description,
    this.resolutionPreset, {
    this.enableAudio = true,
    this.imageFormatGroup,
    List<Object?>? keys,
  }) : super(keys: keys);

  @override
  HookState<CameraController?, Hook<CameraController?>> createState() =>
      _CameraControllerHookState();
}

class _CameraControllerHookState
    extends HookState<CameraController?, _CameraControllerHook>
    with WidgetsBindingObserver {
  CameraController? _cameraController;

  void initController() async {
    final controller = _cameraController;
    _cameraController = null;
    setState(() {});
    await controller?.dispose();
    _cameraController = CameraController(
      hook.description,
      hook.resolutionPreset,
      enableAudio: hook.enableAudio,
      imageFormatGroup: hook.imageFormatGroup,
    );
    _cameraController!.addListener(() {
      setState(() {});
    });
    await _cameraController!.initialize();
  }

  @override
  void initHook() {
    super.initHook();
    _ambiguate(WidgetsBinding.instance)?.addObserver(this);
    initController();
  }

  @override
  void didUpdateHook(_CameraControllerHook oldHook) {
    if (oldHook.description != hook.description ||
        oldHook.enableAudio != hook.enableAudio ||
        oldHook.imageFormatGroup != hook.imageFormatGroup ||
        oldHook.resolutionPreset != hook.resolutionPreset) {
      initController();
    }
  }

  @override
  CameraController? build(BuildContext context) {
    return _cameraController;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (!(_cameraController?.value.isInitialized ?? false)) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      initController();
    }
  }

  @override
  void dispose() {
    _ambiguate(WidgetsBinding.instance)?.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }
}

T? _ambiguate<T>(T? value) => value;
