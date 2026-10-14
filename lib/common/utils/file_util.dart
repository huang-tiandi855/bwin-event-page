import 'dart:io';
import 'dart:typed_data';
import 'package:comics_app/common/utils/text_util.dart';
import 'package:flutter/foundation.dart';

import 'array_util.dart';

import 'package:comics_app/common/utils/logger.dart';

const KB_SIZE = 1024;
const MB_SIZE = 1024 * KB_SIZE;
const GB_SIZE = 1024 * MB_SIZE;

/// 文件相关的公共处理
class FileUtil {
  /// 计算切片个数
  static int getPatchCount(int fileLen) {
    var cutSzie = getPatchSize(fileLen);
    return (fileLen + cutSzie - 1) ~/ cutSzie;
  }

  /// 根据文件长度计算切片大小
  static int getPatchSize(int fileLen) {
    var m1 = MB_SIZE;
    if (fileLen < 1 * m1) return 1 * MB_SIZE;
    return 2 * MB_SIZE;
  }

  /// 获取文件Hash(sha1)和md5
  /*static Future<List<Uint8List>> _getFileHash(File file) async {
    var outputsha1 = AccumulatorSink<c.Digest>();
    var inputsha1 = c.sha1.startChunkedConversion(outputsha1);
    var outputmd5 = AccumulatorSink<c.Digest>();
    var inputmd5 = c.md5.startChunkedConversion(outputmd5);
    var s = file.openRead();
    await for (var d in s) {
      inputmd5.add(d);
      inputsha1.add(d);
    }
    inputmd5.close();
    inputsha1.close();
    return [outputmd5.events.single.bytes, outputsha1.events.single.bytes];
  }*/

  /// 获取文件hash
  /*static Future<List<Uint8List>> getFileHash(File file) =>
      compute(_getFileHash, file);*/

  /// 获取文件md5 内部
  /*static Future<Uint8List> _getFileMD5(File file) async {
    var outputmd5 = AccumulatorSink<c.Digest>();
    var inputmd5 = c.md5.startChunkedConversion(outputmd5);
    var s = file.openRead();
    await for (var d in s) {
      inputmd5.add(d);
    }
    inputmd5.close();
    return outputmd5.events.single.bytes;
  }*/

  /// md5
  //static Future<Uint8List> getFileMD5(File file) => compute(_getFileMD5, file);

  /// 获取md5的String
  // static Future<String> getFileMd5String(File file) async {
  // return c.md5.convert(await getFileMD5(file)).toString().toLowerCase();
//  }

// /// 获取数据的md5
// Future<Uint8List> getDataMd5(Uint8List data) async {
//   return Future.value(Utils.md5(data));
// }

  /// 文件是否存在
  static bool isFileExist(String path) {
    return (TextUtil.isNotEmpty(path) && File(path).existsSync());
  }

  /// 获取file从offset之后到blockSize的数据块
  /// [offset]    起始偏移位置
  /// [blockSize] 分块大小
  /// [file]      文件
  static Future<Uint8List> getFileBlock(
      int offset, int blockSize, File file) async {
    Uint8List result = Uint8List(blockSize);
    RandomAccessFile? accessFile;
    try {
      accessFile = await file.open();
      accessFile = await accessFile.setPosition(offset);
      l.d('offset:$offset blocksize:$blockSize');
      result = await accessFile.read(blockSize);
      return result;
    } on Exception {
      return Future.value(Uint8List.fromList([]));
    } finally {
      if (accessFile != null) {
        accessFile.close();
      }
    }
  }

  /// 获取文件长度
  static int getFileSize(String path) {
    if (!isFileExist(path)) return 0;
    return File(path).lengthSync();
  }

//获取文件的格式化大小
  static String byteFmt(int size) {
    if (size > GB_SIZE) {
      return '${(size / GB_SIZE).toStringAsFixed(1)}GB';
    } else if (size > MB_SIZE) {
      return '${(size / MB_SIZE).toStringAsFixed(1)}MB';
    } else {
      return '${(size / KB_SIZE).toStringAsFixed(1)}KB';
    }
  }

  //获取文件的格式化大小bps
  static String byteSpeedFmt(int size) {
    if (size > GB_SIZE) {
      return '${(size / GB_SIZE).toStringAsFixed(1)}GB/s';
    } else if (size > MB_SIZE) {
      return '${(size / MB_SIZE).toStringAsFixed(1)}MB/s';
    } else {
      return '${(size / KB_SIZE).toStringAsFixed(1)}KB/s';
    }
  }

  ///保留小数点位数
  static double formatNum(double num, int position) {
    String result;
    if ((num.toString().length - num.toString().lastIndexOf(".") - 1) <
        position) {
      //小数点后有几位小数
      result = num.toStringAsFixed(position)
          .substring(0, num.toString().lastIndexOf(".") + position + 1)
          .toString();
    } else {
      result = num.toString()
          .substring(0, num.toString().lastIndexOf(".") + position + 1)
          .toString();
    }
    if (TextUtil.isNotEmpty(result)) {
      return double.parse(result);
    } else {
      return num;
    }
  }

  /// 获取文件名带后缀
  /// 获取任何路径url/uri/file/abspath的问题见名称
  static String getName(String absPath) {
    if (TextUtil.isEmpty(absPath)) return absPath;
    absPath = Uri.parse(absPath).path;
    var start = absPath.lastIndexOf(Platform.pathSeparator);
    if (start <= 0 || (start == absPath.length - 1)) {
      return absPath;
    } else {
      return absPath.substring(start + 1);
    }
  }

  /// 获取文件名不带后缀
  /// 获取任何路径url/uri/file/abspath的问题见名称
  static String getNamePrefix(String absPath) {
    var name = getName(absPath);
    if (TextUtil.isEmpty(name)) return name;
    var ar = name.split('.');
    if (ArrayUtil.isEmpty(ar)) return name;
    return ar[0];
  }

  /// 获取文件名后缀,fileExtension
  /// 获取任何路径url/uri/file/abspath的问题见名称
  static String getNameSuffix(String absPath) {
    var name = getName(absPath);
    if (TextUtil.isEmpty(name)) return name;
    var ar = name.split('.');
    if (ArrayUtil.isEmpty(ar)) {
      return name;
    } else if (ar.length < 2) {
      return ar[0];
    } else {
      return ar[ar.length - 1];
    }
  }
}
