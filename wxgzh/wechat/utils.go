package wechat

func value2CDATA(v string) CDATAText {
	return CDATAText{"<! [CDATA[" + v + "]]"}
}
