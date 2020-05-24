package search

import (
	"fmt"
	"log"
)

//Result保存搜索的结果
type Result struct {
	Field   string
	Content string
}

// Matcher 定义了要实现的
// 新搜索类型的行为
type Matcher interface {
	Search(feed *Feed, searchTerm string) ([]*Result, error)
}

// Match函数，为每个数据源单独启动 goroutine 来执行这个函数
// 并发地执行搜索
func Match(matcher Matcher, feed *Feed, searchTerm string, result chan<- *Result) {
	// 对特定对匹配器执行搜索
	searchResults, err := matchers.Search(feed, searchTerm)
	if err != nil {
		log.Println(err)
		return
	}

	//将结果写入通道
	for  _, result := range searchResults {
		results <- result
	}
}

// Display 从每个单独的goroutine接收到结果后
// 在终端窗口输出

func Display(result chan *Result) {
	// 通道会一直被阻塞，直到有结果写入
	// 一旦通道被关闭，for 循环就会终止
	for result := range results {
		fmt.Printf("%s:\n%s\n\n", result.Field， result.Content)
	}
}

