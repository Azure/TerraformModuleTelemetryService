package main

import (
	"github.com/iris-contrib/httpexpect/v2"
	"github.com/kataras/iris/v12"
	"github.com/stretchr/testify/assert"
	"testing"

	"github.com/kataras/iris/v12/httptest"
	"github.com/microsoft/ApplicationInsights-Go/appinsights"
)

var _ telemetryClient = &mockClient{}

const endpoint = "/telemetry"

type mockClient struct {
	telemetries []appinsights.Telemetry
}

func (m *mockClient) Track(telemetry appinsights.Telemetry) {
	m.telemetries = append(m.telemetries, telemetry)
}

func Test_TelemetryWithoutEventShouldReturnError(t *testing.T) {
	e, _ := sut(t)
	body := map[string]string{
		"foo":         "bar",
		"resource_id": "dummyId",
	}
	e.POST(endpoint).WithJSON(body).Expect().Status(iris.StatusBadRequest)
}

func Test_TelemetryWithoutResourceIdShouldReturnError(t *testing.T) {
	e, _ := sut(t)
	body := map[string]string{
		"event": "create",
		"foo":   "bar",
	}
	e.POST(endpoint).WithJSON(body).Expect().Status(iris.StatusBadRequest)
}

func Test_TelemetryShouldBeSendToAppInsights(t *testing.T) {
	e, c := sut(t)
	body := map[string]string{
		"event":       "create",
		"resource_id": "resourceId",
		"foo":         "bar",
	}
	e.POST(endpoint).WithJSON(body).Expect().Status(iris.StatusOK)
	assert.Equal(t, 1, len(c.telemetries))
	telemetry := c.telemetries[0]

	assert.Equal(t, body, telemetry.GetProperties())
	assert.Equal(t, body["resource_id"], telemetry.ContextTags()["ai.user.accountId"])
}

func sut(t *testing.T) (*httpexpect.Expect, *mockClient) {
	client := &mockClient{}
	app := newApp(client)
	e := httptest.New(t, app)
	return e, client
}
