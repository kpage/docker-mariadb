#!/bin/sh
# Changes the credentials of the tomcat user on startup.
set -u
set -e

rand_pass() {
    < /dev/urandom tr -dc _A-Za-z0-9 | head -c${1:-32}; echo;
}

# Enviroment Variables
readonly MYSQL_ROOT_USER="${MYSQL_ROOT_USER:-root}"
readonly MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD}"
export MYSQL_ROOT_USER
export MYSQL_ROOT_PASSWORD

display_access_information() {
    cat <<EOF
################################################################################
# MySQL Root User: $MYSQL_ROOT_USER
# MySQL Root Password: $MYSQL_ROOT_PASSWORD
################################################################################
EOF
}

main() {
    display_access_information
    if [ ! -d "/var/lib/mysql/mysql" ]; then
        # Apply our cnf file.
        dockerize -template /entrypoint/my.cnf.tmpl:/etc/mysql/my.cnf
        # Install the database
		    mysql_install_db --datadir="/var/lib/mysql" --user=mysql
        # Set the MySQL root Password
		   	tempSqlFile='/tmp/mysql-first-time.sql'
		    cat > "$tempSqlFile" <<-EOSQL
			DELETE FROM mysql.user ;
			CREATE USER 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}' ;
			GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION ;
			DROP DATABASE IF EXISTS test ;
		EOSQL
		    echo 'FLUSH PRIVILEGES ;' >> "$tempSqlFile"
		    set -- "$@" --init-file="$tempSqlFile"
	  fi
    exec "$@"
}
main "$@"
