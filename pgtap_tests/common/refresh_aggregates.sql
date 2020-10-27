-- Neither of these can be run inside a function

-- TimescaleDB 1.7.4 and earlier
REFRESH MATERIALIZED VIEW logs.connection_received_logs_1s;
REFRESH MATERIALIZED VIEW logs.connection_received_logs_1m;
REFRESH MATERIALIZED VIEW logs.connection_received_logs_1h;
REFRESH MATERIALIZED VIEW logs.connection_received_logs_1d;
REFRESH MATERIALIZED VIEW logs.connection_received_logs_1w;
REFRESH MATERIALIZED VIEW logs.connection_authorized_logs_1s;
REFRESH MATERIALIZED VIEW logs.connection_authorized_logs_1m;
REFRESH MATERIALIZED VIEW logs.connection_authorized_logs_1h;
REFRESH MATERIALIZED VIEW logs.connection_authorized_logs_1d;
REFRESH MATERIALIZED VIEW logs.connection_authorized_logs_1w;
REFRESH MATERIALIZED VIEW logs.connection_disconnection_logs_1s;
REFRESH MATERIALIZED VIEW logs.connection_disconnection_logs_1m;
REFRESH MATERIALIZED VIEW logs.connection_disconnection_logs_1h;
REFRESH MATERIALIZED VIEW logs.connection_disconnection_logs_1d;
REFRESH MATERIALIZED VIEW logs.connection_disconnection_logs_1w;
REFRESH MATERIALIZED VIEW logs.postgres_log_1s;
REFRESH MATERIALIZED VIEW logs.postgres_log_1m;
REFRESH MATERIALIZED VIEW logs.postgres_log_1h;
REFRESH MATERIALIZED VIEW logs.postgres_log_1d;
REFRESH MATERIALIZED VIEW logs.postgres_log_1w;
