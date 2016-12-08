# weweChatAssitant
微信自动抢红包,微信修改经纬度


使用方式

1. cd 到 build_dylib.sh 目录下， 运行脚本build_dylib.sh就可以生成用来嵌入微信二进制的通用的动态链接库TestTweak.dylib

2. 解压微信ipa，将 TestTweak.dylib 拷贝其到微信的二进制包中

3. 安装 [optool](https://github.com/alexzielenski/optool) ，这个项目包含了另外的子项目，[ArgumentParser](https://github.com/mysteriouspants/ArgumentParser.git)，ArgumentParser又包含子项目 [CoreParse](https://github.com/beelsebob/CoreParse.git)，记得修改ArgumentParser中CoreParse的代码地址（ArgumentParser配置的有问题）
4. 修改微信二进制,使其能够加载我们的动态库,这一步需要使用[optool](https://github.com/alexzielenski/optool)来实现  optool install -c load -p "@executable_path/TestTweak.dylib" -t Payload/WeChat.app/WeChat


5. 接下来把我们生成的dylib(libautoGetRedEnv.dylib)、刚刚注入dylib的WeChat、以及embedded.mobileprovision文件(可以在之前打包过的App中找到)拷贝到WeChat.app中  
一定要记得 需要这个embedded.mobileprovision文件,如果没有这个文件,重签名后是安装不了的


6. 重签名
这一步可以使用图形化工具[ios-app-signer](https://github.com/DanTheMan827/ios-app-signer)


> 重签名后使用iTools Pro来安装,出现错误提示  WatchKitAppBundleDNotPrefixed
 这个是由于这个app中不止一个可运行的程序,还有watch os的,由于我们这里不需要watch os,所以可以直接将文件夹 watch删掉 (其中有WeChatWatchNative.app)
> 再重新签名,就可以了

