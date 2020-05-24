```
1、GOPATH路径
    /usr/local/Cellar/go/1.11.2
2、安装beego
    cd  /usr/local/Cellar/go/1.11.2
    go get -v  -u github.com/astaxie/beego
3、安装bee
    go get -v  -u github.com/beego/bee
4、验证安装是否正确
    bee version
5、创建bee项目 -> vision
    bee new vision
6、运行bee
    bee run 
7、浏览器端访问
    127.0.0.1:8080
    
8、创建完数据库，利用脚手架去拉取数据库数据，一键生成代码
    bee generate scaffold user -fields="id:int64,name:string,gender:int,age:int" -driver=mysql -conn="root:@tcp(127.0.0.1:3306)/vision"
```