package io.flutter.plugins;

import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.os.Handler;
import android.os.Looper;

import com.fm.openinstall.OpenInstall;
import com.fm.openinstall.listener.AppInstallAdapter;
import com.fm.openinstall.model.AppData;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

/** Native bridge for the Flutter channel value. */
public class NativePlugin implements MethodChannel.MethodCallHandler {
  public static final String CHANNEL = "com.yaoJin/device";
  private static final String PREFS = "openinstall_channel";
  private static final String KEY_CHANNEL = "channel";
  private static final long CALLBACK_TIMEOUT_MS = 5000L;
  private static MethodChannel methodChannel;
  private static String installChannel;
  private static boolean installCallbackFinished;
  private final Activity activity;

  private NativePlugin(Activity activity) { this.activity = activity; }

  public static void registerWith(PluginRegistry.Registrar registrar) {
    methodChannel = new MethodChannel(registrar.messenger(), CHANNEL);
    NativePlugin instance = new NativePlugin(registrar.activity());
    methodChannel.setMethodCallHandler(instance);
    initializeOpenInstall(registrar.activity());
  }

  public static void registerWith(FlutterActivity flutterActivity, FlutterEngine engine) {
    methodChannel = new MethodChannel(engine.getDartExecutor().getBinaryMessenger(), CHANNEL);
    NativePlugin instance = new NativePlugin(flutterActivity);
    methodChannel.setMethodCallHandler(instance);
    initializeOpenInstall(flutterActivity);
  }

  private static void initializeOpenInstall(final Context context) {
    installChannel = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        .getString(KEY_CHANNEL, null);
    // AppKey 在 AndroidManifest.xml 中配置；保持剪切板增强方案开启。
    OpenInstall.clipBoardEnabled(true);
    OpenInstall.init(context);
    OpenInstall.getInstall(new AppInstallAdapter() {
      @Override public void onInstall(AppData appData) {
        installChannel = appData == null ? null : appData.getChannel();
        if (installChannel != null && !installChannel.isEmpty()) {
          context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
              .edit().putString(KEY_CHANNEL, installChannel).apply();
        }
        installCallbackFinished = true;
      }
    });
  }

  @Override public void onMethodCall(MethodCall call, final MethodChannel.Result result) {
    if ("getDeviceId".equals(call.method)) {
      result.success("最新ID");
    } else if ("getChannel".equals(call.method)) {
      getChannelWithTimeout(result);
    } else {
      result.notImplemented();
    }
  }

  private void getChannelWithTimeout(final MethodChannel.Result result) {
    String cached = installChannel;
    if (cached != null && !cached.isEmpty()) { result.success(cached); return; }
    final Handler handler = new Handler(Looper.getMainLooper());
    final long deadline = android.os.SystemClock.uptimeMillis() + CALLBACK_TIMEOUT_MS;
    final Runnable[] poll = new Runnable[1];
    poll[0] = new Runnable() {
      @Override public void run() {
        String value = installChannel;
        if ((installCallbackFinished || value != null && !value.isEmpty())
            || android.os.SystemClock.uptimeMillis() >= deadline) {
          result.success(value == null ? "" : value);
        } else {
          handler.postDelayed(poll[0], 50L);
        }
      }
    };
    handler.post(poll[0]);
  }
}
