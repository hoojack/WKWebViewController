## WKWebViewController
对iOS WKWebView的二次封装，更方便的使用WkWebView。

特性
==============
- 增强的Javascript和Native代码交互
- 简单的Cookie设置方法
- 支持加载进度条和前进后退操作
- 支持Web页面错误信息和Log输出
- 可清理WebView缓存

构成和使用方法
==============
<table>
<tr>
<th>功能</th>
<th>WKWebViewController</th>
<th>WKWebViewControllerEx</th>
</tr>
<tr>
<td>JS交互</td>
<td><font color=#00ff00>✔</font></td>
<td><font color=#00ff00>✔</font></td>
</tr>
<tr>
<td>错误/Log输出</td>
<td><font color=#00ff00>✔</font></td>
<td><font color=#00ff00>✔</font></td>
</tr>
<tr>
<td>Cookie设置</td>
<td><font color=#00ff00>✔</font></td>
<td><font color=#00ff00>✔</font></td>
</tr>
<tr>
<td>进度条</td>
<td><font color=#ff0000>✘</font></td>
<td><font color=#00ff00>✔</td>
</tr>
<tr>
<td>前进/后退</td>
<td><font color=#ff0000>✘</font></td>
<td><font color=#00ff00>✔</font></td>
</tr>
</table>

#### 运行Demo 
1. 将 Docs/html 下的文件复制到本机web服务器目录;
2. 在etc/host添加 127.0.0.1	www.test.com, 在浏览器能正常访问 http://www.test.com/wkwebview.html 即可;
3. 打开Example/testWKWebView.xcodeproj工程即可看到运行效果;
4. 相关代码请参考demo 和 html。

安装
==============
将WKWebViewController目录拖入工程，根据需要引用`WkWebViewController.h` 或`WKWebViewControllerEx.h`.

系统要求
==============
iOS 8.0及以上


