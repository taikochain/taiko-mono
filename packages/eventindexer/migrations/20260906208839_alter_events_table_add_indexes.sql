-- +goose Up
-- +goose StatementBegin
ALTER TABLE `events` ADD INDEX `event_transacted_at_tier_index` (`transacted_at`, `event`, `tier`);
ALTER TABLE `events` ADD INDEX `event_transacted_at_index` (`transacted_at`, `event`);
ALTER TABLE `events` ADD INDEX `event_block_id_index` (`event`, `block_id`);

-- +goose StatementEnd
-- +goose Down
-- +goose StatementBegin
DROP INDEX event_transacted_at_tier_index on events;
DROP INDEX event_transacted_at_index on events;
DROP INDEX event_block_id_index on events;
-- +goose StatementEnd
