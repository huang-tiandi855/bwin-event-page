package com.jyfls.shell   

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.NativePlugin
import kotlinx.coroutines.CoroutineName
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import android.app.ActivityManager
import android.content.ComponentName
import android.content.pm.PackageManager
import android.content.Intent
import android.annotation.SuppressLint
import android.util.Log
import com.jyfls.shell.Utils.Companion.saveAlias
import com.fm.openinstall.OpenInstall

//import io.flutter.plugins.NativePlugin

class MainActivity: FlutterActivity() {

    //这个跟flutter的通道名称保持一直
    private val CHANNEL = "samples.flutter.io/requestApi"

    //定义flutter端调用Android原生方法的channelMethod
    private val channelMethod = "requestApi"

    //flutter对Android端的传参
    private val hostArgument = "host"
    private val pathArgument = "path"
    private val methodArgument = "method"
    private val queryParametersArgument = "queryParameters"
    private val headersArgument = "headers"
    private val extraArgument="extra"
    private val parametersArgument="parameters"
    private val bodyParametersArgumentsKey = "bodyParameters"
    private val dnsIpArgument="dnsIp"




    private val changeIcon = "changeIcon"
    private val dynamicChangeIcon = "dynamicChangeIcon"
    private val iconIndex = "iconIndex"
    private val isOriginIcon = "isOriginIcon"


    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        OpenInstall.clipBoardEnabled(true)
        OpenInstall.init(this)
        NativePlugin.registerWith(this, flutterEngine)




        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { methodCall, result ->
            //这里是判断是不是调getIP方法，因为所有的方法都走这里
            if (methodCall.method.equals(channelMethod)) {
                var path = ""
                var params = HashMap<String,Object>()
                var headersParams = HashMap<String,Object>()
                var bodyParams = HashMap<String,Object>()
                if (methodCall.hasArgument(hostArgument) && methodCall.hasArgument(pathArgument) && methodCall.hasArgument(queryParametersArgument) ) {
                    try {
                        //取出从flutter端传递的host参数
                        val hostArgument: String? = methodCall.argument(hostArgument)
                        val pathArgument: String? = methodCall.argument(pathArgument)
                        val methodArgument: String? = methodCall.argument(methodArgument)
                        val queryParametersArgument: HashMap<String, Object>? = methodCall.argument(queryParametersArgument)
                        var headersArgument: HashMap<String, Object>? = methodCall.argument(headersArgument)
                        var extraArgument: HashMap<String, Object>? = methodCall.argument(extraArgument)
                        var parametersArgument: HashMap<String, Object>? = methodCall.argument(parametersArgument)
                        var bodyParametersArgument: HashMap<String, Object>? = methodCall.argument(bodyParametersArgumentsKey)
                        var dnsValue:String? = methodCall.argument(dnsIpArgument)

                        if(queryParametersArgument!=null){
                            params = queryParametersArgument
                        }
                        if(pathArgument!=null){
                            path = pathArgument
                        }
                        if(headersArgument!=null){
                            headersParams = headersArgument
                        }
                        if (hostArgument != null) {
                            RequestManager.HOST = hostArgument
                        }
                        if(bodyParametersArgument!=null){
                            bodyParams = bodyParametersArgument
                        }
                        GlobalScope.launch (CoroutineName("网络请求")){
                            var value = ""
                            when(methodArgument){
                                "POST" ->{
                                    value = RequestManager.getInstance(this@MainActivity,dnsValue)?.requestSyn(path,
                                        RequestManager.TYPE_POST_JSON,bodyParams,headersParams).toString()
                                }
                                "GET" ->{
                                    value =  RequestManager.getInstance(this@MainActivity,dnsValue)?.requestSyn(path,
                                        RequestManager.TYPE_GET,params,headersParams).toString()
                                }
                            }
                            runOnUiThread {
                                result.success(value)
                            }
                        }
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }
                }
            }







            if(methodCall.method.equals(changeIcon)){
                //取出从flutter端传递的host参数
                val application = applicationContext as CustomApplication
                if(application.isNeedChangIcon){
                    application.isNeedChangIcon = false;
                }
                val iconPosition: Int? = methodCall.argument(iconIndex)
                val packageName:kotlin.String? = this.packageName
                when (iconPosition){

                    0->{
                        changeLogo("$packageName.MainActivity")
                    }
                    1->{
                        changeLogo("$packageName.baidu")
                    }
                    2->{
                        changeLogo("$packageName.instagram")
                    }
                    3->{
                        changeLogo("$packageName.jindong")
                    }
                    4->{
                        changeLogo("$packageName.tingshu")
                    }
                    5->{
                        changeLogo("$packageName.weibo")
                    }
                    6->{
                        changeLogo("$packageName.xianyu")
                    }
                }
            }else if (methodCall.method.equals(dynamicChangeIcon)) {
                val application = applicationContext as CustomApplication
                val isOriginIcon: Boolean? = methodCall.argument(isOriginIcon)
                Log.i("isOriginIcon = ", isOriginIcon.toString())
                isOriginIcon?.apply {
                    application.isOriginIcon = this
                }
                application.isNeedChangIcon = true
            }



        }

    }



    fun changeLogo(name: String) {
        val pm = packageManager
        saveAlias(this.applicationContext,name)
        pm.setComponentEnabledSetting(
            componentName,
            PackageManager.COMPONENT_ENABLED_STATE_DISABLED, PackageManager.DONT_KILL_APP
        )
        pm.setComponentEnabledSetting(
            ComponentName(this, name),
            PackageManager.COMPONENT_ENABLED_STATE_ENABLED, PackageManager.DONT_KILL_APP
        )
        reStartApp(pm)
    }


    @SuppressLint("ServiceCast")
    fun reStartApp(pm: PackageManager) {
        val am = getSystemService(ACTIVITY_SERVICE) as ActivityManager
        val intent = Intent(Intent.ACTION_MAIN)
        intent.addCategory(Intent.CATEGORY_HOME)
        intent.addCategory(Intent.CATEGORY_DEFAULT)
        val resolveInfos = pm.queryIntentActivities(intent, 0)
        for (resolveInfo in resolveInfos) {
            if (resolveInfo.activityInfo != null) {
                am.killBackgroundProcesses(resolveInfo.activityInfo.packageName)
            }
        }
    }




}
