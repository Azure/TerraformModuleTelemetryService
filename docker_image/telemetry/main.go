package main

import (
	"fmt"
	"os"
	"regexp"
	"strconv"
	"time"

	"github.com/kataras/iris/v12"
	"github.com/kataras/iris/v12/context"
	"github.com/microsoft/ApplicationInsights-Go/appinsights"
)

type telemetryClient interface {
	Track(telemetry appinsights.Telemetry)
}

func main() {
	diagnostics()
	_ = newApp(newTelemetryClient()).Listen(fmt.Sprintf(":%d", port()))
}

func diagnostics() {
	if diagEnabledEnv := os.Getenv("DIAG"); diagEnabledEnv != "" {
		appinsights.NewDiagnosticsMessageListener(func(msg string) error {
			fmt.Printf("[%s] %s\n", time.Now().Format(time.DateTime), msg)
			return nil
		})
	}
}

func newTelemetryClient() appinsights.TelemetryClient {
	c := appinsights.NewTelemetryConfiguration(os.Getenv("INSTRUMENTATION_KEY"))
	c.MaxBatchSize = 100
	c.MaxBatchInterval = time.Second
	return appinsights.NewTelemetryClientFromConfig(c)
}

func port() int {
	port := 8080
	portEnv := os.Getenv("PORT")
	if p, err := strconv.Atoi(portEnv); portEnv != "" && err != nil {
		port = p
	}
	return port
}

func newApp(client telemetryClient) *iris.Application {
	app := iris.New()
	app.Use(iris.Compression)
	endpoint := "/telemetry"
	sourceRegexs := filterSources()
	if len(sourceRegexs) == 0 {
		panic("AT LEAST SOURCE_REGEX_0 ENVIRONMENT VARIABLE IS REQUIRED")
	}
	app.Post(endpoint, func(c *context.Context) {
		var tags map[string]string
		err := c.ReadBody(&tags)
		if err != nil {
			c.StatusCode(iris.StatusBadRequest)
			_, _ = c.WriteString("incorrect tags")
			return
		}
		var source string
		var ok bool
		if source, ok = tags["module_source"]; !ok {
			c.StatusCode(iris.StatusBadRequest)
			_, _ = c.WriteString("module_source required")
			return
		}
		match := false
		for _, r := range sourceRegexs {
			if r.MatchString(source) {
				match = true
				break
			}
		}
		if !match {
			c.StatusCode(iris.StatusForbidden)
			_, _ = c.WriteString("source not allowed")
			return
		}
		var event, resourceId string
		if event, ok = tags["event"]; !ok {
			c.StatusCode(iris.StatusBadRequest)
			_, _ = c.WriteString("event required")
			return
		}
		if resourceId, ok = tags["resource_id"]; !ok {
			c.StatusCode(iris.StatusBadRequest)
			_, _ = c.WriteString("resource_id required")
		}
		telemetry := appinsights.NewEventTelemetry(event)
		telemetry.Properties = tags
		telemetry.Tags.User().SetAccountId(resourceId)
		client.Track(telemetry)
		c.StatusCode(iris.StatusOK)
	})
	// For health check
	app.Get(endpoint, func(c *context.Context) {
		c.StatusCode(iris.StatusOK)
		_, _ = c.WriteString("ok")
	})
	return app
}

func filterSources() []*regexp.Regexp {
	var sources []*regexp.Regexp
	for i := 0; true; i++ {
		regex := os.Getenv(fmt.Sprintf("SOURCE_REGEX_%d", i))
		if regex == "" {
			break
		}
		compile := regexp.MustCompile(regex)
		sources = append(sources, compile)
	}
	return sources
}
