```
    1、官方地址
        https://github.com/kataras/iris
        
        示例代码
        https://iris-go.com/v10/recipe
        安装iris
        go get -u -v  github.com/kataras/iris
    
    2、xorm地址
        https://github.com/go-xorm/xorm
        
        安装xorm
        go get -u -v  github.com/go-xorm/cmd/xorm

        crypto拓展安装        
        cd /usr/local/Cellar/go/1.11.2/libexec/src
        git clone https://github.com/golang/crypto.git
        go install crypto/md4

        civil拓展安装       
        cd /usr/local/Cellar/go/1.11.2/libexec/src  
        mkdir  cloud.google.com
        git clone https://github.com/googleapis/google-cloud-go.git
        mv google-cloud-go go
        go install cloud.google.com/go/civil
        
        ps：无法安装golang.org/x/***/之类的错误
        到https://github.com/golang/***去下载
        放到${GOROOT}/src/golang/x/**目录下
```
