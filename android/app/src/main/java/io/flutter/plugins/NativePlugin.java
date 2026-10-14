
package io.flutter.plugins;

import android.app.Activity;

import android.content.Context;
import android.util.Log;

import com.meituan.android.walle.WalleChannelReader;
import com.fm.openinstall.OpenInstall;
import com.fm.openinstall.listener.AppInstallListener;
import com.fm.openinstall.model.AppData;
import com.fm.openinstall.model.Error;
import android.os.Handler;
import android.os.Looper;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

///泡芙本地插件
public class NativePlugin implements MethodChannel.MethodCallHandler {

  public static String CHANNEL = "com.yaoJin/device";

  static MethodChannel methodChannel;
  private static final int MAX_INSTALL_ATTEMPTS = 7;
  private static final long INSTALL_RETRY_DELAY_MS = 1000L;
  private static int installAttempt;

  private Activity activity;

  private NativePlugin(Activity activity) {
    this.activity = activity;
  }

  /// 注册
public static void registerWith(PluginRegistry.Registrar registrar) {
    methodChannel = new MethodChannel(registrar.messenger(), CHANNEL);
    NativePlugin instance = new NativePlugin(registrar.activity());
    methodChannel.setMethodCallHandler(instance);
    requestInstallData();
  }


  /// 注册
  public static void registerWith(FlutterActivity flutterActivity, FlutterEngine engine) {
    methodChannel = new MethodChannel(engine.getDartExecutor().getBinaryMessenger(), CHANNEL);
    NativePlugin instance = new NativePlugin(flutterActivity);
    methodChannel.setMethodCallHandler(instance);
    requestInstallData();
  }


  /// 获取 openinstall 安装参数（保留原 Walle 渠道读取流程）
  private static void requestInstallData() {
    installAttempt++;
    OpenInstall.getInstall(new AppInstallListener() {
      @Override public void onInstallFinish(AppData appData, Error error) {
        if (error != null && error.shouldRetry()
            && installAttempt < MAX_INSTALL_ATTEMPTS) {
          new Handler(Looper.getMainLooper()).postDelayed(
              NativePlugin::requestInstallData, INSTALL_RETRY_DELAY_MS);
        }
        // 成功或达到 6 秒上限后结束本轮获取。
        if (error == null || !error.shouldRetry()
            || installAttempt >= MAX_INSTALL_ATTEMPTS) {
          installAttempt = 0;
        }
      }
    });
  }

  /// 调用
  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    if (call.method.equals("getDeviceId")) {
      result.success("最新ID");
    }else if (call.method.equals("getChannel")) {
      // 获取android 渠道的东西
      result.success(getChannel(activity));
    } else if (call.method.equals("reportRegister")) {
      OpenInstall.reportRegister();
      result.success(null);
    }
  }

  /// 获取渠道号
  public static String getChannel(Context context) {

    return  WalleChannelReader.getChannel(context);
  }
}
