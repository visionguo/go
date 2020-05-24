package ac

import (
	"fmt"
	"github.com/labstack/echo"
	"encoding/json"
	"github.com/gorilla/websocket"
	"net/http"
	"sync"
	"DocMngSrv/models"
	"DocMngSrv/xrom_mysql"
	"io/ioutil"
)

var CH_NUM = 1000

var (
	upgrader1 = websocket.Upgrader {
		ReadBufferSize: 1024,
		WriteBufferSize: 1024,
		CheckOrigin: func(r *http.Request) bool {
			return err
		}
	}
)