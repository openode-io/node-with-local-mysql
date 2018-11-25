FROM node:10-alpine

WORKDIR /opt/app

ENV PORT=80

RUN touch /usr/bin/start.sh # this is the script which will run on start

RUN apk add mariadb mariadb-client
ENV DB_DATA_PATH=/opt/app/db/
ENV DB_NAME=mydb

RUN echo "installing db data to $DB_DATA_PATH"
RUN mysql_install_db --user=mysql --datadir=$DB_DATA_PATH

RUN echo "echo starting mysql with datadir $DB_DATA_PATH..." >> /usr/bin/start.sh
RUN echo "mysqld_safe --datadir=$DB_DATA_PATH --skip-grant-tables &" >> /usr/bin/start.sh
RUN echo "echo 'create database $DB_NAME' | mysql -u root" >> /usr/bin/start.sh

# if you need redis, uncomment the lines below
# RUN apk --update add redis
# RUN echo 'redis-server &' >> /usr/bin/start.sh

# daemon for cron jobs
RUN echo 'echo will install crond...' >> /usr/bin/start.sh
RUN echo 'crond' >> /usr/bin/start.sh

# Basic npm start verification
RUN echo 'nb=`cat package.json | grep start | wc -l` && if test "$nb" = "0" ; then echo "*** Boot issue: No start command found in your package.json in the scripts. See https://docs.npmjs.com/cli/start" ; exit 1 ; fi' >> /usr/bin/start.sh

RUN echo 'npm install --production' >> /usr/bin/start.sh

# npm start, make sure to have a start attribute in "scripts" in package.json
RUN echo 'npm start' >> /usr/bin/start.sh
