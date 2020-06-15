package main

import (
	"fmt"
	"os"

	"github.com/bells17/go-template/pkg/myapp/cmd"
)

func main() {
	cmd := cmd.NewCommand()
	if err := cmd.Execute(); err != nil {
		fmt.Fprintf(os.Stderr, "%s", err.Error())
		os.Exit(1)
	}
	os.Exit(0)
}
