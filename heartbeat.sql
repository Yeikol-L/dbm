CREATE DATABASE IF NOT EXISTS heartbeat;
USE heartbeat;

CREATE TABLE IF NOT EXISTS heartbeat (
    id INT NOT NULL PRIMARY KEY,
    ts TIMESTAMP NOT NULL
);

INSERT INTO heartbeat (id, ts) VALUES (1, NOW())
ON DUPLICATE KEY UPDATE ts=VALUES(ts);