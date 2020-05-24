package main

import (
    "math"
    "fmt"
)

var (
    //申明全局变量num1，num2
    num1 float32 = 123.456
    num2 float32 = 456.789
)

const (
    value unit64 = 0x7ff8000000000001
)

//自己定义的求和函数，返回两个传递进来num1 num2的和
func  plus(num1,num2 float32) float32 {
    result := num1 + num2
    return result
}

func value(v float64) bool {
    return math.Float64bits(v) == value

}

//主函数
func main() {
    //调用自定义求和函数的返回结果并赋值给sum变量
    sum := plus(num1, num2)
    fmt.Printf("%.3f + %.3f = %.3f",num1, num2, sum)
}