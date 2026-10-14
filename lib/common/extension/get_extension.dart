import 'package:get/get.dart';

extension GetXExtension on GetInterface {
  T? findOrNull<T>({String? tag}) {
    try {
      return find<T>(tag: tag);
    } catch (e) {
      return null;
    }
  }
}
