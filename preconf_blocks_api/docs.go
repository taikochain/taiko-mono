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
        "/preconfBlocks": {
            "post": {
                "description": "Insert a preconfirmation block to the L2 execution engine, if the preconfirmation block creation\nbody in request are valid, it will insert the correspoinding the\npreconfirmation block to the backend L2 execution engine and return a success response.",
                "consumes": [
                    "application/json"
                ],
                "produces": [
                    "application/json"
                ],
                "summary": "Insert a preconfirmation block to the L2 execution engine.",
                "parameters": [
                    {
                        "description": "preconf block creation request body",
                        "name": "body",
                        "in": "body",
                        "required": true,
                        "schema": {
                            "$ref": "#/definitions/preconfblocks.BuildPreconfBlockRequestBody"
                        }
                    }
                ],
                "responses": {
                    "200": {
                        "description": "OK",
                        "schema": {
                            "$ref": "#/definitions/preconfblocks.BuildPreconfBlockResponseBody"
                        }
                    }
                }
            },
            "delete": {
                "description": "Remove all preconf blocks from the blockchain beyond the specified block height,\nensuring the latest block ID does not exceed the given height. This method will fail if\nthe block with an ID one greater than the specified height is not a preconf block. If the\nspecified block height is greater than the latest preconf block ID, the method will succeed\nwithout modifying the blockchain.",
                "consumes": [
                    "application/json"
                ],
                "produces": [
                    "application/json"
                ],
                "parameters": [
                    {
                        "description": "preconf blocks removing request body",
                        "name": "body",
                        "in": "body",
                        "required": true,
                        "schema": {
                            "$ref": "#/definitions/preconfblocks.RemovePreconfBlocksRequestBody"
                        }
                    }
                ],
                "responses": {
                    "200": {
                        "description": "OK",
                        "schema": {
                            "$ref": "#/definitions/preconfblocks.RemovePreconfBlocksResponseBody"
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
        "engine.ExecutableData": {
            "type": "object",
            "properties": {
                "baseFeePerGas": {
                    "$ref": "#/definitions/big.Int"
                },
                "blobGasUsed": {
                    "type": "integer"
                },
                "blockHash": {
                    "type": "string"
                },
                "blockNumber": {
                    "type": "integer"
                },
                "depositRequests": {
                    "type": "array",
                    "items": {
                        "$ref": "#/definitions/types.Deposit"
                    }
                },
                "excessBlobGas": {
                    "type": "integer"
                },
                "executionWitness": {
                    "$ref": "#/definitions/types.ExecutionWitness"
                },
                "extraData": {
                    "type": "array",
                    "items": {
                        "type": "integer"
                    }
                },
                "feeRecipient": {
                    "type": "string"
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
                "parentHash": {
                    "type": "string"
                },
                "prevRandao": {
                    "type": "string"
                },
                "receiptsRoot": {
                    "type": "string"
                },
                "stateRoot": {
                    "type": "string"
                },
                "taikoBlock": {
                    "description": "CHANGE(taiko): whether this is a Taiko L2 block, only used by ExecutableDataToBlock",
                    "type": "boolean"
                },
                "timestamp": {
                    "type": "integer"
                },
                "transactions": {
                    "type": "array",
                    "items": {
                        "type": "array",
                        "items": {
                            "type": "integer"
                        }
                    }
                },
                "txHash": {
                    "description": "CHANGE(taiko): allow passing txHash directly instead of transactions list",
                    "type": "string"
                },
                "withdrawals": {
                    "type": "array",
                    "items": {
                        "$ref": "#/definitions/types.Withdrawal"
                    }
                },
                "withdrawalsHash": {
                    "description": "CHANGE(taiko): allow passing WithdrawalsHash directly instead of withdrawals",
                    "type": "string"
                }
            }
        },
        "pacaya.LibSharedDataBaseFeeConfig": {
            "type": "object",
            "properties": {
                "adjustmentQuotient": {
                    "type": "integer"
                },
                "gasIssuancePerSecond": {
                    "type": "integer"
                },
                "maxGasIssuancePerBlock": {
                    "type": "integer"
                },
                "minGasExcess": {
                    "type": "integer"
                },
                "sharingPctg": {
                    "type": "integer"
                }
            }
        },
        "preconfblocks.BuildPreconfBlockRequestBody": {
            "type": "object",
            "properties": {
                "anchorBlockID": {
                    "description": "@param anchorBlockID uint64 ` + "`" + `_anchorBlockId` + "`" + ` parameter of the ` + "`" + `anchorV3` + "`" + ` transaction in the preconf block",
                    "type": "integer"
                },
                "anchorInput": {
                    "type": "array",
                    "items": {
                        "type": "integer"
                    }
                },
                "anchorStateRoot": {
                    "description": "@param anchorStateRoot string ` + "`" + `_anchorStateRoot` + "`" + ` parameter of the ` + "`" + `anchorV3` + "`" + ` transaction in the preconf block",
                    "type": "string"
                },
                "baseFeeConfig": {
                    "$ref": "#/definitions/pacaya.LibSharedDataBaseFeeConfig"
                },
                "executableData": {
                    "description": "@param ExecutableData engine.ExecutableData the data necessary to execute an EL payload.",
                    "allOf": [
                        {
                            "$ref": "#/definitions/engine.ExecutableData"
                        }
                    ]
                },
                "signalSlots": {
                    "type": "array",
                    "items": {
                        "type": "array",
                        "items": {
                            "type": "integer"
                        }
                    }
                },
                "signature": {
                    "description": "@param signature string Signature of this executable data payload.",
                    "type": "string"
                }
            }
        },
        "preconfblocks.BuildPreconfBlockResponseBody": {
            "type": "object",
            "properties": {
                "blockHeader": {
                    "description": "@param blockHeader types.Header of the soft block",
                    "allOf": [
                        {
                            "$ref": "#/definitions/types.Header"
                        }
                    ]
                }
            }
        },
        "preconfblocks.RemovePreconfBlocksRequestBody": {
            "type": "object",
            "properties": {
                "newLastBlockId": {
                    "description": "@param newLastBlockID uint64 New last block ID of the blockchain, it should\n@param not smaller than the canonical chain's highest block ID.",
                    "type": "integer"
                }
            }
        },
        "preconfblocks.RemovePreconfBlocksResponseBody": {
            "type": "object",
            "properties": {
                "headsRemoved": {
                    "description": "@param headsRemoved uint64 Number of preconf heads removed",
                    "type": "integer"
                },
                "lastBlockId": {
                    "description": "@param lastBlockID uint64 Current highest block ID of the blockchain (including preconf blocks)",
                    "type": "integer"
                },
                "lastProposedBlockID": {
                    "description": "@param lastProposedBlockID uint64 Highest block ID of the cnonical chain",
                    "type": "integer"
                }
            }
        },
        "types.Deposit": {
            "type": "object",
            "properties": {
                "amount": {
                    "description": "deposit size in Gwei",
                    "type": "integer"
                },
                "index": {
                    "description": "deposit count value",
                    "type": "integer"
                },
                "pubkey": {
                    "description": "public key of validator",
                    "type": "array",
                    "items": {
                        "type": "integer"
                    }
                },
                "signature": {
                    "description": "signature over deposit msg",
                    "type": "array",
                    "items": {
                        "type": "integer"
                    }
                },
                "withdrawalCredentials": {
                    "description": "beneficiary of the validator funds",
                    "type": "string"
                }
            }
        },
        "types.ExecutionWitness": {
            "type": "object",
            "properties": {
                "stateDiff": {
                    "type": "array",
                    "items": {
                        "$ref": "#/definitions/verkle.StemStateDiff"
                    }
                },
                "verkleProof": {
                    "$ref": "#/definitions/verkle.VerkleProof"
                }
            }
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
                    "type": "string"
                },
                "mixHash": {
                    "type": "string"
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
                    "type": "string"
                },
                "parentHash": {
                    "type": "string"
                },
                "receiptsRoot": {
                    "type": "string"
                },
                "requestsRoot": {
                    "description": "RequestsHash was added by EIP-7685 and is ignored in legacy headers.",
                    "type": "string"
                },
                "sha3Uncles": {
                    "type": "string"
                },
                "stateRoot": {
                    "type": "string"
                },
                "timestamp": {
                    "type": "integer"
                },
                "transactionsRoot": {
                    "type": "string"
                },
                "withdrawalsRoot": {
                    "description": "WithdrawalsHash was added by EIP-4895 and is ignored in legacy headers.",
                    "type": "string"
                }
            }
        },
        "types.Withdrawal": {
            "type": "object",
            "properties": {
                "address": {
                    "description": "target address for withdrawn ether",
                    "type": "string"
                },
                "amount": {
                    "description": "value of withdrawal in Gwei",
                    "type": "integer"
                },
                "index": {
                    "description": "monotonically increasing identifier issued by consensus layer",
                    "type": "integer"
                },
                "validatorIndex": {
                    "description": "index of validator associated with withdrawal",
                    "type": "integer"
                }
            }
        },
        "verkle.IPAProof": {
            "type": "object",
            "properties": {
                "cl": {
                    "type": "array",
                    "items": {
                        "type": "array",
                        "items": {
                            "type": "integer"
                        }
                    }
                },
                "cr": {
                    "type": "array",
                    "items": {
                        "type": "array",
                        "items": {
                            "type": "integer"
                        }
                    }
                },
                "finalEvaluation": {
                    "type": "array",
                    "items": {
                        "type": "integer"
                    }
                }
            }
        },
        "verkle.StemStateDiff": {
            "type": "object",
            "properties": {
                "stem": {
                    "type": "array",
                    "items": {
                        "type": "integer"
                    }
                },
                "suffixDiffs": {
                    "type": "array",
                    "items": {
                        "$ref": "#/definitions/verkle.SuffixStateDiff"
                    }
                }
            }
        },
        "verkle.SuffixStateDiff": {
            "type": "object",
            "properties": {
                "currentValue": {
                    "type": "array",
                    "items": {
                        "type": "integer"
                    }
                },
                "newValue": {
                    "type": "array",
                    "items": {
                        "type": "integer"
                    }
                },
                "suffix": {
                    "type": "integer"
                }
            }
        },
        "verkle.VerkleProof": {
            "type": "object",
            "properties": {
                "commitmentsByPath": {
                    "type": "array",
                    "items": {
                        "type": "array",
                        "items": {
                            "type": "integer"
                        }
                    }
                },
                "d": {
                    "type": "array",
                    "items": {
                        "type": "integer"
                    }
                },
                "depthExtensionPresent": {
                    "type": "array",
                    "items": {
                        "type": "integer"
                    }
                },
                "ipa_proof": {
                    "$ref": "#/definitions/verkle.IPAProof"
                },
                "otherStems": {
                    "type": "array",
                    "items": {
                        "type": "array",
                        "items": {
                            "type": "integer"
                        }
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
	Title:            "Taiko Preconfirmation Block Server API",
	Description:      "",
	InfoInstanceName: "swagger",
	SwaggerTemplate:  docTemplate,
	LeftDelim:        "{{",
	RightDelim:       "}}",
}

func init() {
	swag.Register(SwaggerInfo.InstanceName(), SwaggerInfo)
}
