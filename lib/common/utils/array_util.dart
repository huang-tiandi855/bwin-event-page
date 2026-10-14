/// 数组工具
class ArrayUtil {
  static bool isEmpty(List array) {
    return (array.isEmpty);
  }

  static bool isNotEmpty(List? array) {
    // not use array.isNotEmpty to
    return (null != array && array.isNotEmpty);
  }
}
