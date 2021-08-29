import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

CameraController useCameraController(
  CameraDescription description,
  ResolutionPreset resolutionPreset, {
  bool enableAudio = true,
  ImageFormatGroup? imageFormatGroup,
}) {
  return use(
    _CameraControllerHook(
      description,
      resolutionPreset,
      enableAudio: enableAudio,
      imageFormatGroup: imageFormatGroup,
    ),
  );
}

class _CameraControllerHook extends Hook<CameraController> {
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
  HookState<CameraController, Hook<CameraController>> createState() =>
      _CameraControllerHookState();
}

class _CameraControllerHookState
    extends HookState<CameraController, _CameraControllerHook> {
  late final CameraController _cameraController;

  @override
  void initHook() {
    _cameraController = CameraController(
      hook.description,
      hook.resolutionPreset,
      enableAudio: hook.enableAudio,
      imageFormatGroup: hook.imageFormatGroup,
    );
    super.initHook();
  }

  @override
  CameraController build(BuildContext context) {
    return _cameraController;
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }
}
