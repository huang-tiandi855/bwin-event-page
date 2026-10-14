
import 'package:flutter/foundation.dart';

debugLog(Object? message, [Object? message2]) {
  if (kDebugMode) {
    if (message is String){
      String logStr = message;
      int maxLength = 1024;
      if (logStr.length < maxLength){
        print(message);
      }else {
        for (int i = 0; i < logStr.length; i += maxLength) {
          if (i + maxLength < logStr.length){
            print(logStr.substring(i, i+maxLength));
          }else {
            print(logStr.substring(i, logStr.length));
          }
        }
      }
    }else {
      print(message);
    }
    if (message2 is String){
      String logStr = message2;
      int maxLength = 1024;
      if (logStr.length < maxLength){
        print(message2);
      }else {
        for (int i = 0; i < logStr.length; i += maxLength) {
          if (i + maxLength < logStr.length){
            print(logStr.substring(i, i+maxLength));
          }else {
            print(logStr.substring(i, logStr.length));
          }
        }
      }
    }else {
      if(message2 != null) {
        print(message2);
      }
    }
  }
}