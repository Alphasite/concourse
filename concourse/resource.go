package concourse

import (
	"github.com/concourse/atc"
	"github.com/tedsuo/rata"
)

func (client *client) Resource(pipelineName string, resourceName string) (atc.Resource, bool, error) {
	params := rata.Params{
		"pipeline_name": pipelineName,
		"resource_name": resourceName,
	}

	var resource atc.Resource
	err := client.connection.Send(Request{
		RequestName: atc.GetResource,
		Params:      params,
	}, &Response{
		Result: &resource,
	})
	switch err.(type) {
	case nil:
		return resource, true, nil
	case ResourceNotFoundError:
		return resource, false, nil
	default:
		return resource, false, err
	}
}
