package main

import (
	"encoding/json"
	"fmt"
	"os/exec"
)

//define struct
type Acloud struct {
	Requested string
	Limits    string
}

//define struct
type Acloudslice struct {
	Aclouds []Acloud
}

func main() {
	var s Acloudslice
	//json data
	//command := `/home/work/opdir/vision/acop-2/access-op/k8s_cost/scripts/Resource_utilization.sh namespaces -o json`
	//cmd := exec.Command("/bin/bash", "-c", command)

	str := `{
                "aclouds": [
                    {
                        "request": "vision",
                        "limit": "9"
                    }, {
                        "request": "guo",
                        "limit": "10"
                    }
                ]
            }`
	//parse string to json
	json.Unmarshal([]byte(cmd), &s)

	//Traverse json
	for key, val := range s.Aclouds {
		//printf
		print(`key: `, key, "\t")
		print(`request: `, val.Requested, "\t")
		print(`limit: `, val.Limits)
	}

	//output, err := cmd.Output()
	//if err != nil {
	//	fmt.Printf("Execute Shell:%s failed with error:%s", command, err.Error())
	//	return
	//}
	//fmt.Printf("Execute Shell:%s finished with output:\n%s", command, string(output))
}
