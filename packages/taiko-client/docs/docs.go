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
            "name": "MIT",
            "url": "https://github.com/taikoxyz/taiko-mono/blob/main/LICENSE.md"
        },
        "version": "{{.Version}}"
    },
    "host": "{{.Host}}",
    "basePath": "{{.BasePath}}",
    "paths": {
        "/healthz": {
            "get": {
                "consumes": [
                    "application/json"
                ],
                "produces": [
                    "application/json"
                ],
                "summary": "Get current server health status",
                "operationId": "health-check",
                "responses": {
                    "200": {
                        "description": "OK",
                        "schema": {
                            "type": "string"
                        }
                    }
                }
            }
        },
        "/softBlocks": {
            "post": {
                "description": "Insert a group of transactions into a soft block for preconfirmation. If the group is the\nfirst for a block, a new soft block will be created. Otherwise, the transactions will\nbe appended to the existing soft block. The API will fail if:\n1) the block is not soft\n2) block-level parameters are invalid or do not match the current soft block’s parameters\n3) the group ID is not exactly 1 greater than the previous one\n4) the last group of the block indicates no further transactions are allowed",
                "consumes": [
                    "application/json"
                ],
                "produces": [
                    "application/json"
                ],
                "parameters": [
                    {
                        "description": "soft block creation request body",
                        "name": "body",
                        "in": "body",
                        "required": true,
                        "schema": {
                            "$ref": "#/definitions/softblocks.BuildSoftBlockRequestBody"
                        }
                    }
                ],
                "responses": {
                    "200": {
                        "description": "OK",
                        "schema": {
                            "$ref": "#/definitions/softblocks.BuildSoftBlockResponseBody"
                        }
                    }
                }
            },
            "delete": {
                "description": "Remove all soft blocks from the blockchain beyond the specified block height,\nensuring the latest block ID does not exceed the given height. This method will fail if\nthe block with an ID one greater than the specified height is not a soft block. If the\nspecified block height is greater than the latest soft block ID, the method will succeed\nwithout modifying the blockchain.",
                "consumes": [
                    "application/json"
                ],
                "produces": [
                    "application/json"
                ],
                "parameters": [
                    {
                        "description": "soft blocks removing request body",
                        "name": "body",
                        "in": "body",
                        "required": true,
                        "schema": {
                            "$ref": "#/definitions/softblocks.RemoveSoftBlocksRequestBody"
                        }
                    }
                ],
                "responses": {
                    "200": {
                        "description": "OK",
                        "schema": {
                            "$ref": "#/definitions/softblocks.RemoveSoftBlocksResponseBody"
                        }
                    }
                }
            }
        }
    },
    "definitions": {
        "big.Int": {
            "type": "object"
        },
        "softblocks.BuildSoftBlockRequestBody": {
            "type": "object",
            "properties": {
                "transactionBatch": {
                    "$ref": "#/definitions/softblocks.TransactionBatch"
                }
            }
        },
        "softblocks.BuildSoftBlockResponseBody": {
            "type": "object",
            "properties": {
                "blockHeader": {
                    "$ref": "#/definitions/types.Header"
                }
            }
        },
        "softblocks.RemoveSoftBlocksRequestBody": {
            "type": "object",
            "properties": {
                "newHead": {
                    "type": "integer"
                }
            }
        },
        "softblocks.RemoveSoftBlocksResponseBody": {
            "type": "object",
            "properties": {
                "currentHead": {
                    "$ref": "#/definitions/types.Header"
                },
                "headsRemoved": {
                    "type": "integer"
                }
            }
        },
        "softblocks.TransactionBatch": {
            "type": "object",
            "properties": {
                "anchorBlockID": {
                    "description": "AnchorV2 parameters",
                    "type": "integer"
                },
                "anchorStateRoot": {
                    "type": "string"
                },
                "batchId": {
                    "type": "integer"
                },
                "batchType": {
                    "$ref": "#/definitions/softblocks.TransactionBatchMarker"
                },
                "blockId": {
                    "type": "integer"
                },
                "coinbase": {
                    "type": "string"
                },
                "signature": {
                    "type": "string"
                },
                "timestamp": {
                    "description": "Block parameters",
                    "type": "integer"
                },
                "transactions": {
                    "type": "string"
                }
            }
        },
        "softblocks.TransactionBatchMarker": {
            "type": "string",
            "enum": [
                "end_of_block",
                "end_of_preconf"
            ],
            "x-enum-varnames": [
                "BatchMarkerEOB",
                "BatchMarkerEOP"
            ]
        },
        "types.Header": {
            "type": "object",
            "properties": {
                "baseFeePerGas": {
                    "description": "BaseFee was added by EIP-1559 and is ignored in legacy headers.",
                    "allOf": [
                        {
                            "$ref": "#/definitions/big.Int"
                        }
                    ]
                },
                "blobGasUsed": {
                    "description": "BlobGasUsed was added by EIP-4844 and is ignored in legacy headers.",
                    "type": "integer"
                },
                "difficulty": {
                    "$ref": "#/definitions/big.Int"
                },
                "excessBlobGas": {
                    "description": "ExcessBlobGas was added by EIP-4844 and is ignored in legacy headers.",
                    "type": "integer"
                },
                "extraData": {
                    "type": "array",
                    "items": {
                        "type": "integer"
                    }
                },
                "gasLimit": {
                    "type": "integer"
                },
                "gasUsed": {
                    "type": "integer"
                },
                "logsBloom": {
                    "type": "array",
                    "items": {
                        "type": "integer"
                    }
                },
                "miner": {
                    "type": "array",
                    "items": {
                        "type": "integer"
                    }
                },
                "mixHash": {
                    "type": "array",
                    "items": {
                        "type": "integer"
                    }
                },
                "nonce": {
                    "type": "array",
                    "items": {
                        "type": "integer"
                    }
                },
                "number": {
                    "$ref": "#/definitions/big.Int"
                },
                "parentBeaconBlockRoot": {
                    "description": "ParentBeaconRoot was added by EIP-4788 and is ignored in legacy headers.",
                    "type": "array",
                    "items": {
                        "type": "integer"
                    }
                },
                "parentHash": {
                    "type": "array",
                    "items": {
                        "type": "integer"
                    }
                },
                "receiptsRoot": {
                    "type": "array",
                    "items": {
                        "type": "integer"
                    }
                },
                "requestsRoot": {
                    "description": "RequestsHash was added by EIP-7685 and is ignored in legacy headers.",
                    "type": "array",
                    "items": {
                        "type": "integer"
                    }
                },
                "sha3Uncles": {
                    "type": "array",
                    "items": {
                        "type": "integer"
                    }
                },
                "stateRoot": {
                    "type": "array",
                    "items": {
                        "type": "integer"
                    }
                },
                "timestamp": {
                    "type": "integer"
                },
                "transactionsRoot": {
                    "type": "array",
                    "items": {
                        "type": "integer"
                    }
                },
                "withdrawalsRoot": {
                    "description": "WithdrawalsHash was added by EIP-4895 and is ignored in legacy headers.",
                    "type": "array",
                    "items": {
                        "type": "integer"
                    }
                }
            }
        }
    }
}`

// SwaggerInfo holds exported Swagger Info so clients can modify it
var SwaggerInfo = &swag.Spec{
	Version:          "1.0",
	Host:             "",
	BasePath:         "",
	Schemes:          []string{},
	Title:            "Taiko Soft Block Server API",
	Description:      "",
	InfoInstanceName: "swagger",
	SwaggerTemplate:  docTemplate,
	LeftDelim:        "{{",
	RightDelim:       "}}",
}

func init() {
	swag.Register(SwaggerInfo.InstanceName(), SwaggerInfo)
}
