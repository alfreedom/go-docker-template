package main

import (
	"fmt"
	"os"
	"strings"
	"github.com/pkg/errors"
)


func echo(args []string) error {
	if len(args) < 2 {
		return errors.New("no messge to echo")
	}
	_, err := fmt.Println(strings.Join(args[1:], " "))
	return err

}

func main() {
	err := echo(os.Args)
	if err != nil {
		fmt.Fprintf(os.Stderr, "%+v\n", err)
		os.Exit(1)
	}
}