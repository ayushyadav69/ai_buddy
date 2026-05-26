import 'package:image_picker/image_picker.dart';

class PhotoPickerService {
  final ImagePicker _picker = ImagePicker();

  Future<XFile?> takePhotoWithCamera() {
    return _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 1600,
    );
  }
}
