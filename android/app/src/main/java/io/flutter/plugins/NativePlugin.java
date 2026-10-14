package io.flutter.plugins;

import android.app.Activity;
import android.content.Context;
import android.os.Handler;
import android.os.Looper;

import com.fm.openinstall.OpenInstall;
import com.fm.openinstall.listener.AppInstallListener;
import com.fm.openinstall.model.AppData;
import com.fm.openinstall.model.Error;
import com.meituan.android.walle.WalleChannelReader;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

public class NativePlugin implements MethodChannel.MethodCallHandler {
  public static final String CHANNEL = "com.yaoJin/device";
  private static final int MAX_INSTALL_ATTEMPTS = 7;
  private static final long INSTALL_RETRY_DELAY_MS = 1000L;
  private static MethodChannel methodChannel;
  private final Activity activity;

  private NativePlugin(Activity activity) { this.activity = activity; }

  public static void registerWith(PluginRegistry.Registrar registrar) {
    methodChannel = new MethodChannel(registrar.messenger(), CHANNEL);
    NativePlugin instance = new NativePlugin(registrar.activity());
    methodChannel.setMethodCallHandler(instance);
  }

  public static void registerWith(FlutterActivity flutterActivity, FlutterEngine engine) {
    methodChannel = new MethodChannel(engine.getDartExecutor().getBinaryMessenger(), CHANNEL);
    NativePlugin instance = new NativePlugin(flutterActivity);
    methodChannel.setMethodCallHandler(instance);
  }

  @Override public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    if ("getDeviceId".equals(call.method)) {
      result.success("最新ID");
    } else if ("getChannel".equals(call.method)) {
      requestInstallData(result);
    } else if ("reportRegister".equals(call.method)) {
      OpenInstall.reportRegister();
      result.success(null);
    } else {
      result.notImplemented();
    }
  }

  /** 仅在 Flutter 请求 getChannel 时获取 OpenInstall 渠道，最多等待 6 秒。 */
  private static void requestInstallData(final MethodChannel.Result result) {
    requestInstallData(result, 1);
  }

  private static void requestInstallData(final MethodChannel.Result result, final int attempt) {
    OpenInstall.getInstall(new AppInstallListener() {
      @Override public void onInstallFinish(AppData appData, Error error) {
        if (error != null && error.shouldRetry() && attempt < MAX_INSTALL_ATTEMPTS) {
          new Handler(Looper.getMainLooper()).postDelayed(
              () -> requestInstallData(result, attempt + 1), INSTALL_RETRY_DELAY_MS);
          return;
        }
        AppData data = appData == null ? new AppData() : appData;
        result.success(data.getChannel() == null ? "" : data.getChannel());
      }
    });
  }

  /** 保留原 Walle 读取，仅赋给无用变量，不参与 OpenInstall 返回值。 */
  public static String getChannel(Context context) {
    String unusedWalleChannel = WalleChannelReader.getChannel(context);
    return unusedWalleChannel;
  }
}
