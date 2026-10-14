package com.jyfls.shell

import android.content.Context
import android.content.pm.PackageManager


class Utils {
    companion object{

        fun getAppNameByPackageName(context: Context, packageName: String): String? {
            val packageManager = context.packageManager

            try {
                val applicationInfo = packageManager.getApplicationInfo(packageName, 0)
                val appName = packageManager.getApplicationLabel(applicationInfo)
                return appName.toString()
            } catch (e: PackageManager.NameNotFoundException) {
                e.printStackTrace()
                return null
            }
        }

        fun saveAlias(context: Context,packageName: String){
            val sharedPreferences = context.getSharedPreferences("app_prefs", Context.MODE_PRIVATE)
            val editor = sharedPreferences.edit()
            editor.putString("user_alias", packageName)
            editor.apply()
        }

        fun getUserAlias(context: Context,defaultPackage:String): String? {
            val sharedPreferences = context.getSharedPreferences("app_prefs", Context.MODE_PRIVATE)
            return sharedPreferences.getString("user_alias", defaultPackage) // 返回默认值
        }

    }
}