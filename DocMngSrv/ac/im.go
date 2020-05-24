package ac

import (
	"DocMngSrv/base"
	"DocMngSrv/dao"
	"fmt"
	"github.com/labstack/echo"
)

func MngList(c echo.Context) error {
	userFromId := c.FormValue("msg_from_id")
	userToId := c.FormValue("msg_to_id")
	startTime := c.FormValue("start_time")
	endTime := c.FormValue("end_time")
	msgType := c.FormValue("msg_type")
	pageNum := c.FormValue("page_num")
	pageSize := c.FormValue("page_size")
	rm := new(base.ReturnMsg)
	if userFromId == "" || userToId == "" {
		rm.Code400()
		return c.JSON(200, rm)
	}
	fmt.Println("userFromId:", userFromId)
	fmt.Println("userToId:", userToId)
	fmt.Println("startTime:", startTime)
	fmt.Println("endtime:", endTime)
	msg, count, err := dao.MsgList(userFromId, userToId, startTime, endTime, msgType, pageNum, pageSize)
	if err != nil {
		fmt.Println("数据查询错误：", err)
		rm.Code401()
	} else {
		rm.Code200(count, msg)
	}
	return c.JSON(200, rm)
}
