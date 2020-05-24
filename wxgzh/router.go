package main

import (
	"io"
	"net/http"
	"regexp"
	"time"
)

type WebController struct {
	Function func(http.ResponseWriter, *http.Request) //属性1
	Method   string                                   //属性2 get post
	Pattern  string                                   //属性3 正则匹配，匹配路由
}

var mux []WebController //初始化mux数据

func init() {
	mux = append(mux, WebController{post, "POST", "^/"}) //塞进，小写private，大写public
	mux = append(mux, WebController{get, "GET", "^/"})
}

type httpHandler struct{} //结构体

func (*httpHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) { //http输出和输入，所有的http请求进到这个函数
	t := time.Now()
	for _, WebController := range mux { //遍历数组
		if m, _ := regexp.MatchString(WebController.Pattern, r.URL.Path); m { //
			if r.Method == WebController.Method {
				WebController.Function(w, r)                      //
				go writeLog(r, t, "match", WebController.Pattern) //写日志
				return
			}
		}
	}
	go writeLog(r, t, "unmatch", "")
	io.WriteString(w, "") //io包写空字符串，微信要求：无法返回就返回空
	return
}
