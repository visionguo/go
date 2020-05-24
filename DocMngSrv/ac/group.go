package ac

import (
	"DocMngSrv/base"
	"DocMngSrv/dao"
	"github.com/labstack/echo"
)

//get group list
func GroupList(c echo.Context) error {
	userId := c.FormValue("user_id")
	groupList := dao.GroupListByUserId(userId)
	rm := new(base.ReturnMng)
	if groupList == nil {
		rm.Code401()
	} else {
		rm.Code200(0, GroupList)
	}
	return c.JSON(200, rm)
}
