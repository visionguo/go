package main

import (
	"fmt"
	"github.com/srenew/golang/wxgzh/wechat"
	"log"
	"net/http"
	"time"
)

const ( //环境变量
	loglevel = "dev" //日志等级
	port     = 8081  //监听的端口
	token    = ""
)

func get(w http.ResponseWriter, r *http.Request) { //get函数
	client, err := wechat.NewClient(r, w, token)

	if err != nil {
		log.Println(err)
		w.WriteHeader(403)
		return
	}

	if len(client.Query.Echostr) > 0 {
		w.Write([]byte(client.Query.Echostr))
		return
	}

	w.WriteHeader(403)
	return
}

func post(w http.ResponseWriter, r *http.Request) { //post函数，处理post请求
	client, err := wechat.NewClient(r, w, token)

	if err != nil {
		log.Println(err)
		w.WriteHeader(403)
		return
	}

	client.Run()
	return
}

func main() { //处理get请求如何进到这个函数里来，路由实现
	server := http.Server{ //结构体实例化
		Addr:           fmt.Sprintf(":%d", port),
		Handler:        &httpHandler{},
		ReadTimeout:    5 * time.Second, //微信对被动请求对超时处理
		WriteTimeout:   5 * time.Second,
		MaxHeaderBytes: 0,
	}

	log.Println(fmt.Sprintf("Listen: %d", port)) //监听端口
	log.Fatal(server.ListenAndServe())           //打印一行日志
}
