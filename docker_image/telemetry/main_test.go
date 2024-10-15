package main

import (
	"testing"

	"github.com/iris-contrib/httpexpect/v2"
	"github.com/kataras/iris/v12"
	"github.com/kataras/iris/v12/httptest"
	"github.com/microsoft/ApplicationInsights-Go/appinsights"
	"github.com/stretchr/testify/assert"
)

var _ telemetryClient = &mockClient{}

const endpoint = "/telemetry"

type mockClient struct {
	telemetries []appinsights.Telemetry
}

func (m *mockClient) Track(telemetry appinsights.Telemetry) {
	m.telemetries = append(m.telemetries, telemetry)
}

func Test_TelemetryGetShouldReturnOk(t *testing.T) {
	e, _ := sut(t)
	body := e.GET(endpoint).Expect().Status(iris.StatusOK).Body()
	assert.NotNil(t, body)
	assert.Equal(t, "ok", body.Raw())
}

func Test_TelemetryWithoutEventShouldReturnError(t *testing.T) {
	e, _ := sut(t)
	body := map[string]string{
		"foo":           "bar",
		"resource_id":   "dummyId",
		"module_source": "registry.terraform.io/Azure/foo",
	}
	e.POST(endpoint).WithJSON(body).Expect().Status(iris.StatusBadRequest)
}

func Test_TelemetryWithoutResourceIdShouldReturnError(t *testing.T) {
	e, _ := sut(t)
	body := map[string]string{
		"event":         "create",
		"foo":           "bar",
		"module_source": "registry.terraform.io/Azure/foo",
	}
	e.POST(endpoint).WithJSON(body).Expect().Status(iris.StatusBadRequest)
}

func Test_TelemetryShouldBeSendToAppInsights(t *testing.T) {
	e, c := sut(t)
	body := map[string]string{
		"event":         "create",
		"resource_id":   "resourceId",
		"foo":           "bar",
		"module_source": "registry.terraform.io/Azure/foo",
	}
	e.POST(endpoint).WithJSON(body).Expect().Status(iris.StatusOK)
	assert.Equal(t, 1, len(c.telemetries))
	telemetry := c.telemetries[0]

	assert.Equal(t, body, telemetry.GetProperties())
	assert.Equal(t, body["resource_id"], telemetry.ContextTags()["ai.user.accountId"])
}

func sut(t *testing.T) (*httpexpect.Expect, *mockClient) {
	t.Setenv("SOURCE_REGEX_0", "registry.terraform.io/[A|a]zure/.+")
	t.Setenv("SOURCE_REGEX_1", "registry.opentofu.io/[A|a]zure/.+")
	t.Setenv("SOURCE_REGEX_2", "git::https://github\\.com/[A|a]zure/.+")
	t.Setenv("SOURCE_REGEX_3", "git::ssh:://git@github\\.com/[A|a]zure/.+")
	client := &mockClient{}
	app := newApp(client)
	e := httptest.New(t, app)
	return e, client
}

func Test_ShouldRetrieveFilteredSourceListFromMultipleEnvs(t *testing.T) {
	t.Setenv("SOURCE_REGEX_0", "source0")
	t.Setenv("SOURCE_REGEX_1", "source1")

	list := filterSources()
	assert.Len(t, list, 2)
}

func Test_EmptySourceList(t *testing.T) {
	list := filterSources()
	assert.Empty(t, list)
}

func Test_UnauthorizedSourceTelemetryShouldBeReject(t *testing.T) {
	e, c := sut(t)
	body := map[string]string{
		"event":         "create",
		"resource_id":   "resourceId",
		"foo":           "bar",
		"module_source": "registry.terraform.io/foo/bar",
	}
	e.POST(endpoint).WithJSON(body).Expect().Status(iris.StatusForbidden)
	assert.Empty(t, c.telemetries)
}
