package com.jyfls.shell;

import android.app.Activity;
import android.app.Application;
import android.content.ComponentName;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.ArrayList;
import java.util.List;

import io.flutter.app.FlutterApplication;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugins.GeneratedPluginRegistrant;
import com.fm.openinstall.OpenInstall;
//import io.flutter.plugins.NativePlugin;

public class CustomApplication extends FlutterApplication implements Application.ActivityLifecycleCallbacks{

    boolean isNeedChangIcon = false;
    boolean isOriginIcon = false;
    private List<Activity> activityList = new ArrayList<>();
    private int activityReferences = 0;
    private boolean isActivityChangingConfigurations = false;

    @Override
    public void onCreate() {
        super.onCreate();
        OpenInstall.preInit(this);
        registerActivityLifecycleCallbacks(this);
    }


    @Override
    public void onActivityCreated(@NonNull Activity activity, @Nullable Bundle savedInstanceState) {

    }

    @Override
    public void onActivityStarted(@NonNull Activity activity) {
        if (activityReferences == 0 && !isActivityChangingConfigurations) {
            // App enters foreground
            onAppForegrounded(activity);
        }
        activityReferences++;
    }

    private void onAppForegrounded(Activity activity) {
        Log.d("onAppForegrounded", "==========");
        activityList.add(activity);
    }

    @Override
    public void onActivityResumed(@NonNull Activity activity) {

    }

    @Override
    public void onActivityPaused(@NonNull Activity activity) {

    }

    @Override
    public void onActivityStopped(@NonNull Activity activity) {
        activityReferences--;
        isActivityChangingConfigurations = activity.isChangingConfigurations();

        if (activityReferences == 0 && !isActivityChangingConfigurations) {
            // App goes to background
            onAppBackgrounded(activity);
        }
    }

    private void onAppBackgrounded(Activity activity) {
        Log.d("onAppBackgrounded", "==========");
        if (isNeedChangIcon) {
            isNeedChangIcon = false;
            changeLogo(activity);
        }
    }

    private void changeLogo(Activity activity) {
        try {
            PackageManager manager = getPackageManager();
            String packageName = this.getPackageName();
            String name;
            if(isOriginIcon){
                name = packageName+".MainActivity";
            }else{
                name = packageName+".newYear";
            }
            String alias = Utils.Companion.getUserAlias(this, this.getPackageName());
            if (isOriginIcon && (alias != null) && alias.contains("newYear")) {
                changeAppIcon(activity, name, this.getPackageManager());
            } else if (!isOriginIcon) {
                changeAppIcon(activity, name, this.getPackageManager());
            }

        } catch (Exception e) {
            Log.d("dynamic changeLogo=====",e.toString());
        }

    }

        private void changeAppIcon(Activity activity, String name, PackageManager manager) {
            Utils.Companion.saveAlias(this, name);
            manager.setComponentEnabledSetting(
                    activity.getComponentName(),
                    PackageManager.COMPONENT_ENABLED_STATE_DISABLED, PackageManager.DONT_KILL_APP
            );
            manager.setComponentEnabledSetting(
                    new ComponentName(activity.getApplication(), name),
                    PackageManager.COMPONENT_ENABLED_STATE_ENABLED, PackageManager.DONT_KILL_APP
            );
        }




    @Override
    public void onActivitySaveInstanceState(@NonNull Activity activity, @NonNull Bundle outState) {

    }

    @Override
    public void onActivityDestroyed(@NonNull Activity activity) {

    }
}
