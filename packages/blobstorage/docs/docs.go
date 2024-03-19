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
        "/getBlob": {
            "get": {
                "consumes": [
                    "application/json"
                ],
                "produces": [
                    "application/json"
                ],
                "summary": "Get blob and KZG commitment",
                "operationId": "get-blob",
                "parameters": [
                    {
                        "type": "string",
                        "description": "blobHash to query",
                        "name": "blobHash",
                        "in": "query",
                        "required": true
                    }
                ],
                "responses": {
                    "200": {
                        "description": "OK",
                        "schema": {
                            "$ref": "#/definitions/http.getBlobResponse"
                        }
                    }
                }
            }
        }
    },
    "definitions": {
        "http.blobData": {
            "type": "object",
            "properties": {
                "blob_hash": {
                    "type": "string"
                },
                "kzg_commitment": {
                    "type": "string"
                }
            }
        },
        "http.getBlobResponse": {
            "type": "object",
            "properties": {
                "data": {
                    "type": "array",
                    "items": {
                        "$ref": "#/definitions/http.blobData"
                    }
                }
            }
        }
    }
}`

// SwaggerInfo holds exported Swagger Info so clients can modify it
var SwaggerInfo = &swag.Spec{
	Version:          "1.0",
	Host:             "blobs.internal.taiko.xyz",
	BasePath:         "",
	Schemes:          []string{},
	Title:            "Taiko Blobstorage API",
	Description:      "",
	InfoInstanceName: "swagger",
	SwaggerTemplate:  docTemplate,
	LeftDelim:        "{{",
	RightDelim:       "}}",
}

func init() {
	swag.Register(SwaggerInfo.InstanceName(), SwaggerInfo)
}
