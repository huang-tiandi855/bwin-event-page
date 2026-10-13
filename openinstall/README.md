# openinstall Android 集成补丁

此目录包含从 `91fls_flutter` 工程提取的 openinstall 集成文件。

- AppKey：`xjsxqe`
- Scheme：`xjsxqe`
- 安装渠道通过 `appData.getChannel()` 获取
- 回调最多等待 5 秒，超时继续原登录流程
- 剪切板增强已开启

将对应文件合并回 Flutter 工程；`OpenInstall_v3.0.0.jar` 放入 `android/app/libs/`。
