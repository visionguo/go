package ac

import (
	"github.com/labstack/echo"
	"DocMngSrv/dao"
	"DocMngSrv/base"
)

//api list
func Apilist(c echo.Context) error {
	projectId := c.FormValue("project_id")
	rm := new(base.ReturnMsg)
	if project == "" {
		rm.Code400()
		return c.JSON(200,rm)
	}
	api := dao.ApiContentList(projectId)
	if api == nil {
		rm.Code401()
	}else {
		rm.Code200(0,api)
	}
	return c.JSON(200,rm)
}

//api content
func ApiContent(c echo.Context) error {
	apiId := c.FormValue("api_id")
	rm := new(base.ReturnMsg)
	if apiId == "" {
		rm.Code400()
		return c.JSON(200,rm)
	}
	api := dao.ApiContent(apiId)
	rm.Code200(1,api)
	return c.JSON(200,rm)
}

//api save
func ApiSave(c echo.Context) error {
	apiId 			:= c.FormValue("api_id")
	projectId   	:= c.FormValue("project_id")
	sortId			:= c.FormValue("sort_id")
	apiName			:= c.FormValue("api_name")
	apiEditContent	:= c.FormValue("api_edit_content")
	apiShowContent	:= c.FormValue("api_show_content")
	rm := new(base.ReturnMsg)
	if projectId == "" ||sortId =="" ||apiName == "" ||apiEditContent =="" ||apiShowContent==""{
		rm.Code400()
		return c.JSON(200,rm)
	}
	r :=dao.ApiSave(apiId,projectId,sortId,apiName,apiEditContent,apiShowContent)

	if r == "error" {
		rm.Code401()
	}else {
		rm.Code200(1,r)
	}
	return c.JSON(200，rm)
}

//api delete
func ApiDelete(c echo.Context) error {
	apiId := c.FormValue("api_id")
	rm := new(base.ReturnMsg)
	if apiId == "" {
		rm.Code400()
		return c.JSON(200,rm)
	}
	r := dao.ApiDelete(apiId)
	if r == "error" {
		rm.Code401()
	}else {
		rm.Code200(0,nil)
	}
	return c.JSON(200,rm)
}