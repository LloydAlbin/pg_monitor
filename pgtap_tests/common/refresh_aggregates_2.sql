-- Neither of these can be run inside a function

-- TimescaleDB 2.0.0 and greater
--CALL run_job(1001);
CALL refresh_continuous_aggregate('logs.connection_received_logs_1s', '0001-01-01 00:00:00', now());
CALL refresh_continuous_aggregate('logs.connection_received_logs_1m', '0001-01-01 00:00:00', now());
CALL refresh_continuous_aggregate('logs.connection_received_logs_1h', '0001-01-01 00:00:00', now());
CALL refresh_continuous_aggregate('logs.connection_received_logs_1d', '0001-01-01 00:00:00', now());
CALL refresh_continuous_aggregate('logs.connection_received_logs_1w', '0001-01-01 00:00:00', now());

CALL refresh_continuous_aggregate('logs.connection_authorized_logs_1s', '0001-01-01 00:00:00', now());
CALL refresh_continuous_aggregate('logs.connection_authorized_logs_1m', '0001-01-01 00:00:00', now());
CALL refresh_continuous_aggregate('logs.connection_authorized_logs_1h', '0001-01-01 00:00:00', now());
CALL refresh_continuous_aggregate('logs.connection_authorized_logs_1d', '0001-01-01 00:00:00', now());
CALL refresh_continuous_aggregate('logs.connection_authorized_logs_1w', '0001-01-01 00:00:00', now());

CALL refresh_continuous_aggregate('logs.connection_disconnection_logs_1s', '0001-01-01 00:00:00', now());
CALL refresh_continuous_aggregate('logs.connection_disconnection_logs_1m', '0001-01-01 00:00:00', now());
CALL refresh_continuous_aggregate('logs.connection_disconnection_logs_1h', '0001-01-01 00:00:00', now());
CALL refresh_continuous_aggregate('logs.connection_disconnection_logs_1d', '0001-01-01 00:00:00', now());
CALL refresh_continuous_aggregate('logs.connection_disconnection_logs_1w', '0001-01-01 00:00:00', now());

CALL refresh_continuous_aggregate('logs.postgres_log_1s', '0001-01-01 00:00:00', now());
CALL refresh_continuous_aggregate('logs.postgres_log_1m', '0001-01-01 00:00:00', now());
CALL refresh_continuous_aggregate('logs.postgres_log_1h', '0001-01-01 00:00:00', now());
CALL refresh_continuous_aggregate('logs.postgres_log_1d', '0001-01-01 00:00:00', now());
CALL refresh_continuous_aggregate('logs.postgres_log_1w', '0001-01-01 00:00:00', now());
