package search

import (
	"encoding/json"
	"os"
)

const dateFile  = "data/data.json"

//Feed 结构类型，对外暴露，定义3个字段
type Feed struct {
	Name string `json:"site"`
	URI  string `json:"link"`
	Type string `json:"type"`
}

// RetrieveFeeds 读取并反序列化源数据文件
func RetrieveFeeds() ([]*Feed, error) {
	file, err := os.Open(dataFile)
	if err != nil {
		return nil, err
	}

	//当函数返回时，关闭文件
	defer file.Close()

	//将文件解码到一个切片里，这个切片当每一项是一个指向一个Feed类型值的指针
	var feeds []*Feed
	err = json.NewDecoder(file).Decodez(&feeds)

	//这个函数无需检查错误，调用者会做这件事
	return feeds, err
}