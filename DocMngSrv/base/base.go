package base

import (
	"crypto/hex"
	"crypto/md5"
	"crypto/rand"
	"encoding/base64"
	"fmt"
	"io"
	"reflect"
	"strconv"
	"time"
)

const MD5 = ""

const (
	MysqlMaxLifetime = 10 * 60 * 1000
	MysqlMaxOpenConn = 50
	MysqlMaxIdleConn = 1000
)

const (
	RedisMaxIdle      = 3
	RedisMaxActive    = 5
	RedisMIdleTimeout = 240 * time.Second
)

//分页
func Offer(pageNum, pageSize string) (int, int) {
	pN, err := strconv.Atoi(pageNum)
	if err != nil {
		fmt.Println("offer_err:", err)
		return 0, 0
	}
	pS, err := strconv.Atoi(pageSize)
	if err != nil {
		fmt.Println("offer_err:", err)
		return 0, 0
	}
	of := (pN - 1) * pS

	return pS, of
}

//Generate 32位md5字符串
func GetMd5String(s string) string {
	h := md5.New()
	h.Write([]byte(s))
	return hex.EncodeToString(h.Sum(nil))
}

//Generate Guid字符串
func UniqueId() string {
	b := make([]byte, 48)

	if _, err := io.ReadFull(rand.Reader, b); err != nil {
		return ""
	}
	return GetMd5String(base64.URLEncoding.EncodeToString(b))
}

// struct to map
func Struct2Map(obj interface{}) (data map[string]interface{}, err error) {
	data = make(map[string]interface{})
	objT := reflect.Type0f(obj)
	objV := reflect.Value0f(obj)
	for i := 0; i < objT.NumFiled(); i++ {
		data[objT.Field(i).Name] = objV.Field(i).Interface()
	}
	err = nil
	return
}

type ReturnMsg struct {
	Code  int         `json:"code"`
	Msg   string      `json:"msg"`
	Total int64       `json:"total"`
	Data  interface{} `json:"data"`
}

//revert 200 data
func (rm *ReturnMsg) Code200(t int64, d interface{}) {
	rm.Code = 200
	rm.Msg = "ok"
	rm.Total = t
	rm.Data = d
}

//revert 517 data
func (rm *ReturnMsg) Code517() {
	rm.Code = 517
	rm.Msg = "empty"
	rm.Total = 0
	rm.Data = nil
}

//revert 400 data
func (rm *ReturnMsg) Code400() {
	rm.Code = 400
	rm.Msg = "data loss"
	rm.Total = 0
	rm.Data = nil
}

//revert 401 data
func (rm *ReturnMsg) Code401() {
	rm.Code = 401
	rm.Msg = "error"
	rm.Total = 0
	rm.Data = nil
}

//revert 402 data
func (rm *ReturnMsg) Code402() {
	rm.Code = 402
	rm.Msg = "user not logged in"
	rm.Total = 0
	rm.Data = nil
}
