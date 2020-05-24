```
1、源代码：https://github.com/itsmikej/imooc_logprocess
2、启动influxdb
    docker pull tutum/influxdb
    docker run -d  -p8086:8086 --name influxsrv tutum/influxdb
    启动http端口
    docker run -d  -p8086:8086 -p8083:8083 --name influx tutum/influxdb 
    
    再次启动执行：
    docker restart "CONTAINER ID"  
3、启动grafana
    docker run -d --name=grafana -p 3000:3000 grafana/grafana
    创建持久化volume
    docker run -d -v /var/lib/grafana --name grafana-storage busybox:latest
    
    再次启动执行：
    docker start grafana
    
    进入grafana容器：docker exec -it grafana -u root bash
4、生成log_process
    go build log_process.go
5、生成mock_data
    go build mock_data.go 
6、touch access.log
7、influxdb配置
    1.进入docker镜像：docker exec -it influxsrv bash
    2.查看influxdb的工具：find /usr/bin/ |grep influx
    3.查看influxdb版本：/usr/bin/influx -version
    4.进入influxdb客户端命令行：/usr/bin/influx
    5.创建数据库：create database vision;
    6.创建用户：create user "username" with password 'password'
    创建管理员权限用户：create user "username" with password 'password' with all privileges
    7.vision数据库的权限赋给root用户: grant all on vision to root
    8.dashboard: http://127.0.0.1:8083
    
    influxdb概念：
    1.database: 数据库
    2.measurement: 数据库中的表
    3.points: 表里面的一行数据
        1）、tags: 各种有索引的属性
        2）、fields: 各种记录的值
        3）、time: 数据记录的时间戳，也是自动生成的主索引
        
    4.示例：
        1）、写入:curl -i -XPOST 'http://localhost:8086/write?db=mydb' 
        --data-binary 'cpu_usage,host=server01,region=us-west value=0.64 1434055562000000000'
        2）、读取:curl -G 'http://localhost:8086/query?pretty=true' 
        --data-urlencode "db=mydb" 
        --data-urlencode "q=SELECT \"value\" FROM \"cpu_load_short\" WHERE \"region\"='us-west'"
8、测试
    一边执行 ./mock_data 模拟往access.log写数据
    一边 tail -f access.log
    
    一边执行 ./mock_data
    一边执行 ./log_process -path ./access.log -influxDsn http://127.0.0.1:8086@username@password@databases@s
    
    mock 自身的监控：curl 127.0.0.1:9193/monitor
9、浏览器配置grafana
    登录：http://127.0.0.1:3000
    grafana配置：http://www.cnblogs.com/LUA123/p/9507029.html
    
10、日志监控系统
    需求：某个协议下的某个请求在某个请求方法的QPS&响应时间&流量
    
11、influxdb client
    1、地址：https://github.com/influxdata/influxdb/tree/master/client
    
12、监控模块的实现
    1.总处理日志行数
    2.系统吞吐量
    3.read channel 长度
    4.write channel 长度
    5.运行总时间
    6.错误数  
    
    实现：
    1../log_process -path ./access.log 
    -influxDsn http://127.0.0.1:8086@root@romantic0615@vision@s
    2../mock_data
    3.curl 127.0.0.1:9193/monitor   //实时监控日志数据
```