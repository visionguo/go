package ac

import (
	"DocMngSrv/base"
	"DocMngSrv/dao"
	"DocMngSrv/redispool"
	"crypto/md5"
	"encoding/hex"
	"fmt"
	"github.com/labstack/echo"
)

func Login(c echo.Context) error {
	username := c.FormValue("username")
	password := c.FormValue("password")
	rm := new(base.ReturnMsg)
	if username == "" || password == "" {
		rm.Code400()
		return c.JSON(200, rm)
	}
	password = password + base.MD5
	pass := md5.New()
	pass.Write([]byte(password)) //需要加密的字符串为buf.String()
	user := dao.FindUser(username, hex.EncodeToString(pass.Sum(nil)))
	if user.UserUsername != "" {
		uuid := base.UniqueId()
		fmt.Println(uuid)
		userMap, _ := base.Struct2Map(user)
		userMap["Token"] = uuid
		redispool.RedisSETString(user.UserId+"_ticket", uuid, 0)
		rm.Code200(1, userMap)
		return c.JSON(200, rm)
	}
	rm.Code517()
	return c.JSON(200, rm)
}

func Logout(c echo.Context) error {
	userId := c.FormValue("user_id")
	rm := new(base.ReturnMng)
	if userId == "" {
		rm.Code200(0, nil)
		return c.JSON(200, rm)
	}
	redispool.RedisDel(userId + "token")
	rm.Code200(0, nil)
	return c.JSON(200, rm)
}
