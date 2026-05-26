import 'package:ai_buddy/features/media/data/services/photo_picker_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final photoPickerServiceProvider = Provider<PhotoPickerService>((ref) {
  return PhotoPickerService();
});
