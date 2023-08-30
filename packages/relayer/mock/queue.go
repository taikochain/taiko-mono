package mock

import (
	"context"

	"github.com/taikoxyz/taiko-mono/packages/relayer/queue"
)

type Queue struct {
}

func (r *Queue) Start(ctx context.Context, queueName string) error {
	return nil
}

func (r *Queue) Close(ctx context.Context) {

}

func (r *Queue) Publish(ctx context.Context, msg []byte) error {
	return nil
}

func (r *Queue) Ack(ctx context.Context, msg queue.Message) error {
	return nil
}

func (r *Queue) Nack(ctx context.Context, msg queue.Message) error {
	return nil
}

func (r *Queue) Subscribe(ctx context.Context, msgChan chan<- queue.Message) error {
	return nil
}
