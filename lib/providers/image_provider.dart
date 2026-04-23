import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/db_provider.dart';
import '../services/image_service.dart';

final imageServiceProvider = ChangeNotifierProvider<ImageService>((ref) {
  return ImageService(ref.watch(imagesDaoProvider));
});
