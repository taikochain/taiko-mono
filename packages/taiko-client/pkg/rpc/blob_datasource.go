package rpc

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"net/url"

	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/log"
	"github.com/go-resty/resty/v2"
	"github.com/prysmaticlabs/prysm/v5/api/server/structs"

	"github.com/taikoxyz/taiko-mono/packages/taiko-client/pkg"
)

type BlobDataSource struct {
	ctx                context.Context
	client             *Client
	blobServerEndpoint *url.URL
	socialScanEndpoint *url.URL
}

type BlobData struct {
	BlobHash      string `json:"blob_hash"`
	KzgCommitment string `json:"kzg_commitment"`
	Blob          string `json:"blob"`
}

type BlobDataSeq struct {
	Data []*BlobData `json:"data"`
}

type BlobServerResponse struct {
	Commitment    string `json:"commitment"`
	Data          string `json:"data"`
	VersionedHash string `json:"versionedHash"`
}

func NewBlobDataSource(
	ctx context.Context,
	client *Client,
	blobServerEndpoint *url.URL,
	socialScanEndpoint *url.URL,
) *BlobDataSource {
	return &BlobDataSource{
		ctx:                ctx,
		client:             client,
		blobServerEndpoint: blobServerEndpoint,
		socialScanEndpoint: socialScanEndpoint,
	}
}

// UnmarshalJSON overwrites to parse data based on different json keys
func (p *BlobServerResponse) UnmarshalJSON(data []byte) error {
	var tempMap map[string]interface{}
	if err := json.Unmarshal(data, &tempMap); err != nil {
		return err
	}

	// Parsing data based on different keys
	if versionedHash, ok := tempMap["versionedHash"]; ok {
		p.VersionedHash = versionedHash.(string)
	} else if versionedHash, ok := tempMap["versioned_hash"]; ok {
		p.VersionedHash = versionedHash.(string)
	}

	p.Commitment = tempMap["commitment"].(string)
	p.Data = tempMap["data"].(string)

	return nil
}

// GetBlobs get blob sidecar by meta
func (ds *BlobDataSource) GetBlobs(
	ctx context.Context,
	timestamp uint64,
	blobHash common.Hash,
) ([]*structs.Sidecar, error) {
	var (
		sidecars []*structs.Sidecar
		err      error
	)
	if ds.client.L1Beacon == nil {
		sidecars, err = nil, pkg.ErrBeaconNotFound
	} else {
		sidecars, err = ds.client.L1Beacon.GetBlobs(ctx, timestamp)
	}
	if err != nil {
		if !errors.Is(err, pkg.ErrBeaconNotFound) {
			log.Info("Failed to get blobs from beacon, try to use blob server.", "error", err.Error(), "timestamp", timestamp)
		}
		if ds.blobServerEndpoint == nil && ds.socialScanEndpoint == nil {
			log.Info("No blob server endpoint set")
			return nil, err
		}
		blobs, err := ds.getBlobFromServer(ctx, blobHash)
		if err != nil {
			return nil, err
		}
		sidecars = make([]*structs.Sidecar, len(blobs.Data))
		for index, value := range blobs.Data {
			sidecars[index] = &structs.Sidecar{
				KzgCommitment: value.KzgCommitment,
				Blob:          value.Blob,
			}
		}
	}
	return sidecars, nil
}

// getBlobFromServer get blob data from server path `/blob` or `/blobs`.
func (ds *BlobDataSource) getBlobFromServer(ctx context.Context, blobHash common.Hash) (*BlobDataSeq, error) {
	var (
		route      string
		requestURL string
		err        error
	)
	if ds.socialScanEndpoint != nil {
		route = "/blob/" + blobHash.String()
		requestURL, err = url.JoinPath(ds.socialScanEndpoint.String(), route)
	} else {
		route = "/blobs/" + blobHash.String()
		requestURL, err = url.JoinPath(ds.blobServerEndpoint.String(), route)
	}
	if err != nil {
		return nil, err
	}
	resp, err := resty.New().R().
		SetResult(BlobServerResponse{}).
		SetContext(ctx).
		SetHeader("Content-Type", "application/json").
		SetHeader("Accept", "application/json").
		Get(requestURL)
	if err != nil {
		return nil, fmt.Errorf("failed to get blob from server, request URL: %s, err: %w", requestURL, err)
	}
	if !resp.IsSuccess() {
		return nil, fmt.Errorf(
			"unable to connect blobscan endpoint, status code: %v",
			resp.StatusCode(),
		)
	}
	response := resp.Result().(*BlobServerResponse)

	return &BlobDataSeq{
		Data: []*BlobData{
			{
				BlobHash:      response.VersionedHash,
				KzgCommitment: response.Commitment,
				Blob:          response.Data,
			},
		}}, nil
}
