package main

import (
	"log"
	"os"

	_ "github.com/goinaction/code/chapter2/sample/matchers"
	"github.com/goinaction/code/chapter2/sample/search"
)

fun init() {
	log.SetOutput(os.Stdout)
}

func main() {
	search.Run("president")
}

