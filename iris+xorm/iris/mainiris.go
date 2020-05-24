package main

import "github.com/kataras/iris"

func main() {
	app := iris.New()

	//设置模版引擎
	htmlEngine := iris.HTML("./", ".html")
	app.RegisterView(htmlEngine) //	把这个对象注册进去

	app.Get("/", func(ctx iris.Context) {
		ctx.WriteString("Hello world --from visonguo001!")
	})

	//通过模版输出
	// hello路径，html这个页面下，有两个变量
	app.Get("/hello", func(ctx iris.Context) {
		ctx.ViewData("Title", "测试页面")
		ctx.ViewData("Content", "Hello world")
		ctx.View("hello.html")
	})

	app.Run(iris.Addr("127.0.0.1:8080"), iris.WithCharset("UTF-8"))
}
