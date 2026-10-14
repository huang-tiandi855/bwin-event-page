package com.jyfls.shell;

import static java.net.InetAddress.getAllByName;
import static java.net.InetAddress.getByName;

import android.util.Log;

import androidx.annotation.NonNull;

import com.qiniu.android.dns.DnsManager;
import com.qiniu.android.dns.IResolver;
import com.qiniu.android.dns.NetworkInfo;
import com.qiniu.android.dns.Record;
import com.qiniu.android.dns.dns.DnsUdpResolver;

import java.io.IOException;
import java.net.InetAddress;
import java.net.UnknownHostException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.TreeSet;

import okhttp3.Dns;

public class HttpDns implements Dns {

    private static HttpDns httpDns;

    private DnsManager dnsManager;

    private  final TreeSet<String> HOST_SET = new TreeSet<String>();

    public HttpDns(String ip) {
        IResolver[] resolvers = new IResolver[1];
        resolvers[0] =  new DnsUdpResolver(ip); //自定义 DNS 服务器地址
        dnsManager = new DnsManager(NetworkInfo.normal, resolvers);
    }
    public static HttpDns getInstance(String ip){
        if(httpDns==null){
            httpDns = new HttpDns(ip);
        }
        return  httpDns;
    }
    public DnsManager getDnsManager() {
        return dnsManager;
    }

    @NonNull
    @Override
    public List<InetAddress> lookup(@NonNull String hostname) throws UnknownHostException {
        if (dnsManager == null)                 //当构造失败时使用默认解析方式
            return Dns.SYSTEM.lookup(hostname);
        try {
            Record[] ips = dnsManager.queryRecords(hostname);  //获取HttpDNS解析结果
            if (ips == null || ips.length == 0) {
                return Dns.SYSTEM.lookup(hostname);
            }
            List<InetAddress> result = new ArrayList<>();
            for (Record ip : ips) {  //将ip地址数组转换成所需要的对象列表
                result.addAll(Arrays.asList(getAllByName(ip.value)));
            }
            HOST_SET.add(hostname);
            updateDnsCache();
            return result;
        } catch (IOException e) {
            e.printStackTrace();
        }
        //当有异常发生时，使用默认解析
        return Dns.SYSTEM.lookup(hostname);
    }

    public void updateDnsCache() {
        try{
            TreeSet<String> hostSet = getHostSet();
            List<String> hosts = new ArrayList<>();
            hosts.addAll(hostSet);
            prefetchDns(hosts);
        }catch (Exception e){
            Log.e("Exception===",e.getMessage());
            e.printStackTrace();
            return;
        }
    }

    public synchronized void prefetchDns(List<String> hosts) {
        if(hosts==null && hosts.size()==0) return;
        for (String hostname:hosts ) {
            prefetchDns(hostname);
        }
    }

    /**
     * 获取主机集合
     * @return
     */
    public synchronized  TreeSet<String> getHostSet() {
        Log.i("HOST_SET",HOST_SET.first());
        return HOST_SET;
    }

    /**
     * 预加载DNS
     * @param hostname
     */
    public synchronized void prefetchDns(String hostname) {
        try{
            InetAddress.getAllByName(hostname);
        }catch (Exception e){
            e.printStackTrace();
            return;
        }
    }
}
