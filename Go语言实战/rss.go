package matchers

import (
	"encoding/xml"
	"errors"
	"fmt"
	"html/template"
	"log"
	"net/http"
	"regexp"

	"github.com/goinaction/code/chapter2/sample/search"
)

type  (
	// item 根据item 字段的标签，将定义的字段与rss 文档的字段关联起来
	item struct {
		XMLName		xml.Name	`xml:"item"`
		PubDate		string 		`xml:"pubDate"`
		Title		string		`xml:"title"`
		Description string		`xml:"description"`
		Link 		string		`xml:"link"`
		GUID		string		`xml:"guid"`
		GeoRssPoint string		`xml:"georss:point"`
	}

	// image 根据image 字段的标签，将定义的字段与 rss 文档的字段关联起来
	image struct {
		XMLName		xml.Name	`xml:"image"`
		URL 		string		`xml:"url"`
		Title 		string		`xml:"title"`
		Link 		string		`xml:"link"`
	}

	//channel 根据channel 字段的标签，将定义的字段与rss 文档的字段关联起来
	channel struct {
		XMLName		xml.Name	`xml:"channel"`
		Title		string		`xml:"title"`
		Description string		`xml:"description"`
		Link 		string		`xml:"link"`
		PubDate		string		`xml:"pubdate"`
		LastBuildDate	string	`xml:"lastBuildDate"`
		TTL			string		`xml:"ttl"`
		Language	string		`xml:language`
		ManagingEditor	string	`xml::"managjngEditor"`
		WebMaster	string		`xml:"webMaster"`
		Image		string		`xml:"image"`
		item		[]item		`xml:"item"`
	}

	// rssDocument 定义来与rss文档相关联的字段
	rssDocument struct {
		XMLName	xml.Name	`xml:"rss"`
		channel channel		`xml:"channel"`
	}
)

//rssMatcher 实现了 Matcher 接口
type rssMatcher struct {
}

// init 将匹配器注册到程序里
func init() {
	var matcher rssMatcher
	search.Register("rss", matcher)
}

// Search 在文档中查找特定的搜索项
func (m rssMatcher) Search(feed *search.Feed, searchTerm string) ([]*search.Result, error) {
	var results []*search.Result
	log.Printf("Search Feed Type[%s] Site[%s] For Uri[%s]\n", feed.Type, feed.Name, feed,URI)

	//获取要搜索的数据
	document, err := m.retrieve(feed)
	if err != nil {
		return nil, err
	}

	for _, channelItem := range document.Channel.Item {
		//检查标题部分是否包含搜索项
		matched, err := regexp.MatchString(searchTerm, channelItem.Title)
		if err != nil {
			return nil, err
		}

		// 如果找到匹配的项，将其作为结果保存
		if matched {
			results = append(results, &search.Result{
				Field: "Title",
				Content: channelItem.Title,
			})
		}

		// 检查描述部分是否包含搜索项
		matched, err=regexp.MatchString(searchTerm，channelItem.Description)
		if err != nil {
			return nil, err
		}

		//如果找到匹配的项，将其作为结果保存
		if matched {
			results = append(results, &search.Result{
				Field: "Description",
				Content: channelItem.Description,
			})
		}
	}

	return results, nil
}