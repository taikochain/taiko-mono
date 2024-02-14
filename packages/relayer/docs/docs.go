// Package docs Code generated by swaggo/swag. DO NOT EDIT
package docs

import "github.com/swaggo/swag"

const docTemplate = `{
    "schemes": {{ marshal .Schemes }},
    "swagger": "2.0",
    "info": {
        "description": "{{escape .Description}}",
        "title": "{{.Title}}",
        "termsOfService": "http://swagger.io/terms/",
        "contact": {
            "name": "API Support",
            "url": "https://community.taiko.xyz/",
            "email": "info@taiko.xyz"
        },
        "license": {
            "name": "MIT"
        },
        "version": "{{.Version}}"
    },
    "host": "{{.Host}}",
    "basePath": "{{.BasePath}}",
    "paths": {
        "/blockInfo": {
            "get": {
                "consumes": [
                    "application/json"
                ],
                "produces": [
                    "application/json"
                ],
                "summary": "Get block info",
                "operationId": "get-block-info",
                "responses": {
                    "200": {
                        "description": "OK",
                        "schema": {
                            "$ref": "#/definitions/http.getBlockInfoResponse"
                        }
                    }
                }
            }
        },
        "/events": {
            "get": {
                "consumes": [
                    "application/json"
                ],
                "produces": [
                    "application/json"
                ],
                "summary": "Get events by address",
                "operationId": "get-events-by-address",
                "parameters": [
                    {
                        "type": "string",
                        "description": "address to query",
                        "name": "address",
                        "in": "query",
                        "required": true
                    },
                    {
                        "type": "string",
                        "description": "msgHash to query",
                        "name": "msgHash",
                        "in": "query"
                    },
                    {
                        "type": "string",
                        "description": "chainID to query",
                        "name": "chainID",
                        "in": "query"
                    },
                    {
                        "type": "string",
                        "description": "eventType to query",
                        "name": "eventType",
                        "in": "query"
                    },
                    {
                        "type": "string",
                        "description": "event to query",
                        "name": "event",
                        "in": "query"
                    }
                ],
                "responses": {
                    "200": {
                        "description": "OK",
                        "schema": {
                            "$ref": "#/definitions/paginate.Page"
                        }
                    }
                }
            }
        }
    },
    "definitions": {
        "http.blockInfo": {
            "type": "object",
            "properties": {
                "chainID": {
                    "type": "integer"
                },
                "latestBlock": {
                    "type": "integer"
                },
                "latestProcessedBlock": {
                    "type": "integer"
                }
            }
        },
        "http.getBlockInfoResponse": {
            "type": "object",
            "properties": {
                "data": {
                    "type": "array",
                    "items": {
                        "$ref": "#/definitions/http.blockInfo"
                    }
                }
            }
        },
        "paginate.Page": {
            "type": "object",
            "properties": {
                "first": {
                    "type": "boolean"
                },
                "items": {},
                "last": {
                    "type": "boolean"
                },
                "max_page": {
                    "type": "integer"
                },
                "page": {
                    "type": "integer"
                },
                "size": {
                    "type": "integer"
                },
                "total": {
                    "type": "integer"
                },
                "total_pages": {
                    "type": "integer"
                },
                "visible": {
                    "type": "integer"
                }
            }
        }
    }
}`

// SwaggerInfo holds exported Swagger Info so clients can modify it
var SwaggerInfo = &swag.Spec{
	Version:          "1.0",
	Host:             "relayer.katla.taiko.xyz",
	BasePath:         "",
	Schemes:          []string{},
	Title:            "Taiko Relayer API",
	Description:      "",
	InfoInstanceName: "swagger",
	SwaggerTemplate:  docTemplate,
	LeftDelim:        "{{",
	RightDelim:       "}}",
}

func init() {
	swag.Register(SwaggerInfo.InstanceName(), SwaggerInfo)
}
