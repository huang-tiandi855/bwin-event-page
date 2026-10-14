/// 同步和异步调用，
///  错误和正确数据
class EData<T> {
  final dynamic _e;
  final T? _d;

  EData(dynamic e, T? d)
      : _e = e,
        _d = d;

  get err => _e;

  T? get data => (_d is T) ? _d : null;
}

/// 同步调用
EData<T> syncCall<T>(Function f) {
  try {
    return EData(null, f() as T);
  } catch (e) {
    return EData(e, null);
  }
}

//异步调用
Future<EData<T>> asyncCall<T>(Function f) async {
  try {
    return EData(null, (await f()) as T);
  } catch (e) {
    return EData(e, null);
  }
}
