docker stop mysql mysqlexporter prometheus grafana pt-heartbeat
docker rm mysql mysqlexporter prometheus grafana pt-heartbeat
docker network rm monitoring-network

docker network create monitoring-network
docker pull prom/mysqld-exporter
docker run --name mysql \
           --network-alias mysql \
           --network monitoring-network \
           -v ./heartbeat.sql:/tmp/heartbeat.sql \
           -p 3306:3306 \
           -d sakiladb/mysql:8
docker run --name mysqlexporter \
           --network-alias mysqlexporter \
           --network monitoring-network \
           -e DATA_SOURCE_NAME="sakila:p_ssW0rd@(mysql:3306)/" \
           -v ./.my.cnf:/etc/.my.cnf \
           -p 9104:9104 \
           -d prom/mysqld-exporter \
           --config.my-cnf=/etc/.my.cnf \
            --collect.auto_increment.columns \
            --collect.binlog_size \
            --collect.engine_innodb_status \
            --collect.global_status \
            --collect.global_variables \
            --collect.heartbeat \
            --collect.heartbeat.database heartbeat \
            --collect.info_schema.clientstats \
            --collect.info_schema.innodb_metrics \
            --collect.info_schema.innodb_tablespaces \
            --collect.info_schema.innodb_cmp \
            --collect.info_schema.innodb_cmpmem \
            --collect.info_schema.processlist \
            --collect.info_schema.query_response_time \
            --collect.info_schema.replica_host \
            --collect.info_schema.tables \
            --collect.info_schema.tablestats \
            --collect.info_schema.schemastats \
            --collect.info_schema.userstats \
            --collect.mysql.user \
            --collect.perf_schema.eventsstatements \
            --collect.perf_schema.eventsstatementssum \
            --collect.perf_schema.eventswaits \
            --collect.perf_schema.file_events \
            --collect.perf_schema.file_instances \
            --collect.perf_schema.indexiowaits \
            --collect.perf_schema.memory_events \
            --collect.perf_schema.tableiowaits \
            --collect.perf_schema.tablelocks \
            --collect.perf_schema.replication_group_members \
            --collect.perf_schema.replication_group_member_stats \
            --collect.perf_schema.replication_applier_status_by_worker \
            --collect.slave_status \
            --collect.slave_hosts \
            --collect.sys.user_summary

docker run --name prometheus \
           -d \
           --name prometheus \
           --network-alias prometheus \
           --network monitoring-network \
           -p 9090:9090 \
           -v ./prometheus.yml:/etc/prometheus/prometheus.yml \
           prom/prometheus 

docker run --name grafana \
           -d \
           --name=grafana \
           --network monitoring-network \
           -p 3000:3000 grafana/grafana
docker exec -i mysql bash -c 'export MYSQLPASS="p_ssW0rd" && mysql -u sakila -p"$MYSQLPASS" < /tmp/heartbeat.sql'


docker build -t pt-heartbeat .

docker run -d --name pt-heartbeat --network monitoring-network \
  pt-heartbeat pt-heartbeat \
  --update --interval=1 \
  --host=mysql \
  --user=sakila \
  --password=p_ssW0rd \
  --database=heartbeat \
  --table=heartbeat




