package main

import (
	"fmt"
	"github.com/kataras/iris/v12"
	"github.com/kataras/iris/v12/context"
)

func main() {
	app := iris.New()
	app.Use(iris.Compression)
	app.Post("/tags", func(c *context.Context) {
		var tags = make(map[string]string, 0)
		err := c.ReadBody(&tags)
		if err != nil {
			fmt.Errorf(err.Error())
			return
		}
		for n, v := range tags {
			fmt.Printf("%s:%s\n", n, v)
		}
		c.JSON(tags)
	})
	app.Listen(":8080")
}
