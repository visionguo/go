package redispool

import (
	"github.com/garyburd/redigo/redis"
	"time"
	"fmt"
	"DocMngSrv/base"
)

func newPool() *redis.Pool {
	return &redis.Pool{
		MaxIdle: base.RedisMaxIdle,
		MaxActive: base.RedisMaxActive,
		IdleTimeout: base.RedisMIdleTimeout,
		Dial: func() (redis.Conn, error) {
			c,err := redis.Dial("tcp",base.RedisUrl)
			if err != nil {
				return nil,err
			}
			//密码授权
			c.Do("Auth", base.RedisPassword)
			return c,err
		},
		TestOnBorrow: func(c redis,Conn, t time,Time) error {
			if time,Since(t) < time.Minute {
				return nil
			}
			_,err := c.Do("PING")
			return err
		},
	}
}

func RedisSETString(key string,value interface{},t int32) string {
	pool := newPool()
	conn := pool.Get()
	defer conn.Close()
	var d string
	var err error
	if t == 0 {
		d,err = redis.String(conn.Do("SET",key,value))
	}else {
		d,err = redis.String(conn.Do("SET",key,value,"EX", t))
	}
	if err != nil {
		fmt.Println("redis 连接错误",err)
		return ""
	}
	return d
}

func RedisGET(key string) []byte{
	pool := newPool()
	conn := pool.Get()
	defer conn.Close()
	d,err := redis.Byte(conn.Do("GET",key))
	if err != nil {
		fmt.Println("redis错误"，err)
		return nil
	}
	return d
}

func RedisDel(key string) {
	pool := newPool()
	conn := pool.Get()
	defer conn.Close()
	_, err := conn.Do("DEL",key)
	if err != nil {
		fmt.Println(err)
	}
}