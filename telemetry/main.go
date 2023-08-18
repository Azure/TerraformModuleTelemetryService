package main

import (
	"fmt"
	"github.com/kataras/iris/v12"
	"github.com/kataras/iris/v12/context"
	"github.com/microsoft/ApplicationInsights-Go/appinsights"
	"os"
	"strconv"
	"time"
)

func main() {
	port := 8080
	portEnv := os.Getenv("PORT")
	if p, err := strconv.Atoi(portEnv); err != nil {
		port = p
	}
	iKey := os.Getenv("INSTRUMENTATION_KEY")
	telemetryConfig := appinsights.NewTelemetryConfiguration(iKey)
	telemetryConfig.MaxBatchSize = 100
	telemetryConfig.MaxBatchInterval = time.Second
	client := appinsights.NewTelemetryClientFromConfig(telemetryConfig)

	if diagEnabledEnv := os.Getenv("DIAG"); diagEnabledEnv != "" {
		appinsights.NewDiagnosticsMessageListener(func(msg string) error {
			fmt.Printf("[%s] %s\n", time.Now().Format(time.DateTime), msg)
			return nil
		})
	}

	app := iris.New()
	app.Use(iris.Compression)
	app.Post("/telemetry", func(c *context.Context) {
		var tags = make(map[string]string, 0)
		err := c.ReadBody(&tags)
		if err != nil {
			c.StatusCode(iris.StatusBadRequest)
			c.WriteString("incorrect tags")
			return
		}
		var event string
		var ok bool
		if event, ok = tags["event"]; !ok {
			c.StatusCode(iris.StatusBadRequest)
			c.WriteString("event required")
			return
		}
		telemetry := appinsights.NewEventTelemetry(event)
		telemetry.Properties = tags
		client.Track(telemetry)
	})
	app.Listen(fmt.Sprintf(":%d", port))
}
