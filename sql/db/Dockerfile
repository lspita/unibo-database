FROM mysql/mysql-server:8.0

# all .sql and .sh files inside /docker-entrypoint-initdb.d will be executed
# https://hub.docker.com/_/mysql
COPY init /docker-entrypoint-initdb.d
