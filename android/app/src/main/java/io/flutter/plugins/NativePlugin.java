
package io.flutter.plugins;

import android.app.Activity;

import android.content.Context;
import android.util.Log;

import com.meituan.android.walle.WalleChannelReader;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

///泡芙本地插件
public class NativePlugin implements MethodChannel.MethodCallHandler {

  public static String CHANNEL = "com.yaoJin/device";

  static MethodChannel methodChannel;

  private Activity activity;

  private NativePlugin(Activity activity) {
    this.activity = activity;
  }

  /// 注册
public static void registerWith(PluginRegistry.Registrar registrar) {
    methodChannel = new MethodChannel(registrar.messenger(), CHANNEL);
    NativePlugin instance = new NativePlugin(registrar.activity());
    methodChannel.setMethodCallHandler(instance);
  }


  /// 注册
  public static void registerWith(FlutterActivity flutterActivity, FlutterEngine engine) {
    methodChannel = new MethodChannel(engine.getDartExecutor().getBinaryMessenger(), CHANNEL);
    NativePlugin instance = new NativePlugin(flutterActivity);
    methodChannel.setMethodCallHandler(instance);
  }

  /// 调用
  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    if (call.method.equals("getDeviceId")) {
      result.success("最新ID");
    }else if (call.method.equals("getChannel")) {
      // 获取android 渠道的东西
      result.success(getChannel(activity));
    }
  }

  /// 获取渠道号
  public static String getChannel(Context context) {

    return  WalleChannelReader.getChannel(context);
  }
}
