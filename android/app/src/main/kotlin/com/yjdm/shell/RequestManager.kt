package com.jyfls.shell
import android.annotation.SuppressLint
import android.content.Context
import android.os.Handler
import android.util.Log
import okhttp3.*
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import org.json.JSONObject
import java.io.IOException
import java.net.URLEncoder
import java.util.concurrent.TimeUnit

 class RequestManager(context: Context,dnsIp:String?) {
    private val MEDIA_TYPE_FORM =
        "application/x-www-form-urlencoded; charset=utf-8".toMediaTypeOrNull() //mdiatype 这个需要和服务端保持一致
     private val MEDIA_TYPE_JSON =
         "application/json; charset=utf-8".toMediaTypeOrNull() //mdiatype 这个需要和服务端保持一致

    private val MEDIA_TYPE_MARKDOWN = "text/x-markdown; charset=utf-8".toMediaTypeOrNull() //mdiatype 这个需要和服务端保持一致

    private val TAG = RequestManager::class.java.simpleName
    private val BASE_URL = "https:$HOST" //请求接口根地址
    private var dnsIp = ""
    @Volatile
    private var mInstance //单利引用
            : RequestManager? = null


    private var mOkHttpClient //okHttpClient 实例
            : OkHttpClient? = null
    private var okHttpHandler //全局处理子线程和M主线程通信
            : Handler? = null

    init {
        //初始化OkHttpClient
        mOkHttpClient = OkHttpClient().newBuilder()
            .connectTimeout(10, TimeUnit.SECONDS) //设置超时时间
            .readTimeout(10, TimeUnit.SECONDS) //设置读取超时时间
            .writeTimeout(10, TimeUnit.SECONDS) //设置写入超时时间
            .dns(HttpDns(dnsIp))
            .build()
        //初始化Handler
        okHttpHandler = Handler(context.mainLooper)
    }
    /**
     * 获取单例引用
     *
     * @return
     */
    companion object {
        val TYPE_GET = 0 //get请求

        val TYPE_POST_JSON = 1 //post请求参数为json

        val TYPE_POST_FORM = 2 //post请求参数为表单

        var sInstance: RequestManager? = null

        var HOST  = "" //post请求参数为表单
        @Synchronized
        fun getInstance(context: Context,dnsIp:String?): RequestManager? {
            if (sInstance == null) {
                if (dnsIp != null) {
                    sInstance?.dnsIp = dnsIp
                }
                sInstance = RequestManager(context,dnsIp)
            }else{ //DNS有变更时，需要重新实例化请求对象
                if(!dnsIp.equals(sInstance!!.dnsIp)){
                    sInstance = RequestManager(context,dnsIp)
                    if (dnsIp != null) {
                        sInstance!!.dnsIp = dnsIp
                    }
                }
            }
            return sInstance
        }
    }

    /**
     * okHttp同步请求统一入口
     * @param actionUrl  接口地址
     * @param requestType 请求类型
     * @param paramsMap   请求参数
     */
    fun requestSyn(actionUrl: String, requestType: Int, paramsMap: HashMap<String, Object>, headersMap: HashMap<String, Object>):String? {
        when (requestType) {
            TYPE_GET -> return requestGetBySyn(actionUrl, paramsMap,headersMap)
            TYPE_POST_JSON -> return requestPostBySyn(actionUrl, paramsMap,headersMap)
            TYPE_POST_FORM -> return requestPostBySynWithForm(actionUrl, paramsMap,headersMap)
        }
        return ""
    }

    /**
     * okHttp get同步请求
     * @param actionUrl  接口地址
     * @param paramsMap   请求参数
     */
    @SuppressLint("SuspiciousIndentation")
    private fun requestGetBySyn(actionUrl: String, paramsMap: HashMap<String, Object>, headersMap: HashMap<String, Object>) :String?{
        val tempParams = StringBuilder()
        try {
            //处理参数
            var pos = 0
            for((key, value) in paramsMap){
                if (pos > 0) {
                    tempParams.append("&")
                }
                //对参数进行URLEncoder
                tempParams.append(
                    java.lang.String.format(
                        "%s=%s",
                        key,
                        URLEncoder.encode(paramsMap?.get(key).toString(), "utf-8")
                    )
                )
                pos++
            }
            //补全请求地址
//            val requestUrl = String.format("%s/%s?%s", BASE_URL, actionUrl, tempParams.toString())
            val requestUrl = "$BASE_URL$actionUrl?$tempParams"
               Log.i("requestUrl=====",requestUrl);
            //创建一个请求
            val request: Request = addHeaders(headersMap).url(requestUrl).build()
            //创建一个Call
            val call: Call = mOkHttpClient!!.newCall(request)
            //执行请求
            val response: Response = call.execute()
           return  response.body?.string()
        } catch (e: Exception) {
            Log.e(TAG, e.toString())
        }
        return  ""
    }


    /**
     * okHttp post同步请求
     * @param actionUrl  接口地址
     * @param paramsMap   请求参数
     */
    private fun requestPostBySyn(actionUrl: String, paramsMap: HashMap<String, Object>, headersMap: HashMap<String, Object>) :String?{
        try {
            //处理参数
            var jsonObject:JSONObject = JSONObject()
            for ((key,value ) in paramsMap) {
                jsonObject.put(key,value)
            }
            //补全请求地址
            val requestUrl = "$BASE_URL$actionUrl"
            //创建一个请求实体对象 RequestBody
            val body: RequestBody = RequestBody.create(MEDIA_TYPE_JSON, jsonObject.toString())
            //创建一个请求
            val request: Request = addHeaders(headersMap).url(requestUrl).post(body).build()
            //创建一个Call
            val call: Call = mOkHttpClient!!.newCall(request)
            //执行请求
            val response: Response = call.execute()
            var stringValue = response.body?.string();
            //请求执行成功
            if (response.isSuccessful) {
                //获取返回数据 可以是String，bytes ,byteStream
            }
            return stringValue
        } catch (e: Exception) {
            Log.e(TAG, e.toString())
        }
        return  ""
    }

    /**
     * okHttp post同步请求表单提交
     * @param actionUrl 接口地址
     * @param paramsMap 请求参数
     */
    private fun requestPostBySynWithForm(actionUrl: String, paramsMap: HashMap<String, Object>, headersMap: HashMap<String, Object>) :String?{
        try {
            //创建一个FormBody.Builder
            val builder: FormBody.Builder = FormBody.Builder()
            for ((key) in paramsMap) {
                //追加表单信息
                paramsMap[key]?.let { builder.add(key, it.toString()) }
            }
            //生成表单实体对象
            val formBody: RequestBody = builder.build()
            //补全请求地址
            val requestUrl = String.format("%s/%s", BASE_URL, actionUrl)
            //创建一个请求
            val request: Request = addHeaders(headersMap).url(requestUrl).post(formBody).build()
            //创建一个Call
            val call: Call = mOkHttpClient!!.newCall(request)
            //执行请求
            val response: Response = call.execute()
            if (response.isSuccessful) {
//                Log.e(TAG, "response ----->" + response.body?.string())
                return response.body?.string()
            }
        } catch (e: Exception) {
            Log.e(TAG, e.toString())
        }
        return ""
    }

    /**
     * okHttp异步请求统一入口
     * @param actionUrl   接口地址
     * @param requestType 请求类型
     * @param paramsMap   请求参数
     * @param callBack 请求返回数据回调
     * @param <T> 数据泛型
    </T> */
    fun <T> requestAsyn(
        actionUrl: String,
        requestType: Int,
        paramsMap: HashMap<String, Object>,
        headersMap: HashMap<String, Object>,
        callBack: ReqCallBack<T>
    ): Call? {
        var call: Call? = null
        when (requestType) {
            TYPE_GET -> call = requestGetByAsyn(actionUrl, paramsMap, callBack,headersMap)
            TYPE_POST_JSON -> call = requestPostByAsyn(actionUrl, paramsMap, callBack,headersMap)
            TYPE_POST_FORM -> call = requestPostByAsynWithForm(actionUrl, paramsMap, callBack,headersMap)
        }
        return call
    }


    /**
     * okHttp get异步请求
     * @param actionUrl 接口地址
     * @param paramsMap 请求参数
     * @param callBack 请求返回数据回调
     * @param <T> 数据泛型
     * @return
    </T> */
    private fun <T> requestGetByAsyn(
        actionUrl: String,
        paramsMap: HashMap<String, Object>,
        callBack: ReqCallBack<T>,
        headersMap: HashMap<String, Object>
    ): Call? {
        val tempParams = StringBuilder()
        try {
            var pos = 0
            for ((key) in paramsMap) {
                if (pos > 0) {
                    tempParams.append("&")
                }
                tempParams.append(
                    java.lang.String.format(
                        "%s=%s",
                        key,
                        URLEncoder.encode(paramsMap[key].toString(), "utf-8")
                    )
                )
                pos++
            }
            val requestUrl = String.format("%s/%s?%s", BASE_URL, actionUrl, tempParams.toString())
            val request: Request = addHeaders(headersMap).url(requestUrl).build()
            val call: Call = mOkHttpClient!!.newCall(request)
            call.enqueue(object : Callback {

                override fun onFailure(call: Call, e: IOException) {
                    failedCallBack("访问失败", callBack)
                    Log.e(TAG, e.toString())
                }

                override fun onResponse(call: Call, response: Response) {
                    if (response.isSuccessful) {
                        val string: String? = response.body?.string()
                        Log.e(TAG, "response ----->$string")
                        successCallBack(string as T, callBack)
                    } else {
                        failedCallBack("服务器错误", callBack)
                    }
                }
            })
            return call
        } catch (e: Exception) {
            Log.e(TAG, e.toString())
        }
        return null
    }

    /**
     * okHttp post异步请求
     * @param actionUrl 接口地址
     * @param paramsMap 请求参数
     * @param callBack 请求返回数据回调
     * @param <T> 数据泛型
     * @return
    </T> */
    private fun <T> requestPostByAsyn(
        actionUrl: String,
        paramsMap: HashMap<String, Object>,
        callBack: ReqCallBack<T>,
        headersMap: HashMap<String, Object>
    ): Call? {
        try {
            val tempParams = StringBuilder()
            var pos = 0
            for ((key) in paramsMap) {
                if (pos > 0) {
                    tempParams.append("&")
                }
                tempParams.append(
                    java.lang.String.format(
                        "%s=%s",
                        key,
                        URLEncoder.encode(paramsMap[key].toString(), "utf-8")
                    )
                )
                pos++
            }
            val params = tempParams.toString()
            val body: RequestBody = RequestBody.create(MEDIA_TYPE_JSON, params)
            val requestUrl = String.format("%s/%s", BASE_URL, actionUrl)
            val request: Request = addHeaders(headersMap).url(requestUrl).post(body).build()
            val call: Call = mOkHttpClient!!.newCall(request)
            call.enqueue(object : Callback {

                override fun onFailure(call: Call, e: IOException) {
                    failedCallBack("访问失败", callBack)
                    Log.e(TAG, e.toString())
                }

                override fun onResponse(call: Call, response: Response) {
                    if (response.isSuccessful) {
                        val string: String? = response.body?.string()
                        Log.e(TAG, "response ----->$string")
                        successCallBack(string as T, callBack)
                    } else {
                        failedCallBack("服务器错误", callBack)
                    }
                }
            })
            return call
        } catch (e: Exception) {
            Log.e(TAG, e.toString())
        }
        return null
    }


    /**
     * okHttp post异步请求表单提交
     * @param actionUrl 接口地址
     * @param paramsMap 请求参数
     * @param callBack 请求返回数据回调
     * @param <T> 数据泛型
     * @return
    </T> */
    private fun <T> requestPostByAsynWithForm(
        actionUrl: String,
        paramsMap: HashMap<String, Object>,
        callBack: ReqCallBack<T>,
        headersMap: HashMap<String, Object>
    ): Call? {
        try {
            val builder: FormBody.Builder = FormBody.Builder()
            for ((key) in paramsMap) {
                paramsMap[key]?.let { builder.add(key, it.toString()) }
            }
            val formBody: RequestBody = builder.build()
            val requestUrl = String.format("%s/%s", BASE_URL, actionUrl)
            val request: Request = addHeaders(headersMap).url(requestUrl).post(formBody).build()
            val call: Call = mOkHttpClient!!.newCall(request)
            call.enqueue(object : Callback {

                override fun onFailure(call: Call, e: IOException) {
                    failedCallBack("访问失败", callBack)
                    Log.e(TAG, e.toString())
                }

                override fun onResponse(call: Call, response: Response) {
                    if (response.isSuccessful) {
                        val string: String? = response.body?.string()
                        Log.e(TAG, "response ----->$string")
                        successCallBack(string as T, callBack)
                    } else {
                        failedCallBack("服务器错误", callBack)
                    }
                }

            })
            return call
        } catch (e: Exception) {
            Log.e(TAG, e.toString())
        }
        return null
    }

    interface ReqCallBack<T> {
        /**
         * 响应成功
         */
        fun onReqSuccess(result: T)

        /**
         * 响应失败
         */
        fun onReqFailed(errorMsg: String?)
    }


    /**
     * 统一为请求添加头信息
     * @return
     */
    private fun addHeaders( headersMap: HashMap<String, Object>): Request.Builder {
        var build = Request.Builder()
        for((key,value) in headersMap){
            build.addHeader(key, value.toString())
        }
        return build
    }

    /**
     * 统一同意处理成功信息
     * @param result
     * @param callBack
     * @param <T>
    </T> */
    private fun <T> successCallBack(result: T, callBack: ReqCallBack<T>?) {
        okHttpHandler!!.post { callBack?.onReqSuccess(result) }
    }

    /**
     * 统一处理失败信息
     * @param errorMsg
     * @param callBack
     * @param <T>
    </T> */
    private fun <T> failedCallBack(errorMsg: String, callBack: ReqCallBack<T>?) {
        okHttpHandler!!.post { callBack?.onReqFailed(errorMsg) }
    }

}