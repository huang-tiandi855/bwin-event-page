package io.flutter.plugins;

import android.app.Activity;
import android.os.Handler;
import android.os.Looper;

import com.fm.openinstall.OpenInstall;
import com.fm.openinstall.listener.AppInstallListener;
import com.fm.openinstall.model.AppData;
import com.fm.openinstall.model.Error;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

/** Flutter bridge for the OpenInstall installation channel. */
public class NativePlugin implements MethodChannel.MethodCallHandler {
  public static final String CHANNEL = "com.yaoJin/device";
  private static final long CALLBACK_TIMEOUT_MS = 5000L;
  private static final long RETRY_DELAY_MS = 500L;
  private static String installChannel = "";
  private static boolean installFinished = false;
  private static MethodChannel methodChannel;
  private final Activity activity;

  private NativePlugin(Activity activity) { this.activity = activity; }

  public static void registerWith(PluginRegistry.Registrar registrar) {
    methodChannel = new MethodChannel(registrar.messenger(), CHANNEL);
    NativePlugin instance = new NativePlugin(registrar.activity());
    methodChannel.setMethodCallHandler(instance);
    requestInstallData();
  }

  public static void registerWith(FlutterActivity flutterActivity, FlutterEngine engine) {
    methodChannel = new MethodChannel(engine.getDartExecutor().getBinaryMessenger(), CHANNEL);
    NativePlugin instance = new NativePlugin(flutterActivity);
    methodChannel.setMethodCallHandler(instance);
    requestInstallData();
  }

  private static void requestInstallData() {
    OpenInstall.getInstall(new AppInstallListener() {
      @Override public void onInstallFinish(AppData appData, Error error) {
        if (error != null && error.shouldRetry()) {
          new Handler(Looper.getMainLooper()).postDelayed(
              NativePlugin::requestInstallData, RETRY_DELAY_MS);
          return;
        }
        installChannel = appData == null || appData.getChannel() == null
            ? "" : appData.getChannel();
        installFinished = true;
      }
    });
  }

  @Override public void onMethodCall(MethodCall call, final MethodChannel.Result result) {
    if ("getDeviceId".equals(call.method)) {
      result.success("最新ID");
    } else if ("getChannel".equals(call.method)) {
      waitForInstallChannel(result);
    } else {
      result.notImplemented();
    }
  }

  private void waitForInstallChannel(final MethodChannel.Result result) {
    if (installFinished) {
      result.success(installChannel);
      return;
    }
    final Handler handler = new Handler(Looper.getMainLooper());
    final long deadline = android.os.SystemClock.uptimeMillis() + CALLBACK_TIMEOUT_MS;
    final Runnable[] poll = new Runnable[1];
    poll[0] = () -> {
      if (installFinished || android.os.SystemClock.uptimeMillis() >= deadline) {
        result.success(installChannel);
      } else {
        handler.postDelayed(poll[0], 50L);
      }
    };
    handler.post(poll[0]);
  }

  public static String getChannel() {
    return installChannel;
  }
}
