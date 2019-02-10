FROM node:10-alpine

WORKDIR /opt/app

ENV PORT=80

RUN touch /boot.sh # this is the script which will run on start

RUN apk add mariadb mariadb-client
ENV DB_DATA_PATH=/opt/app/db/
ENV DB_NAME=mydb

RUN echo "echo starting mysql with datadir $DB_DATA_PATH..." >> /boot.sh
RUN echo "killall mysqld" >> /boot.sh
RUN echo "mysql_install_db --user=mysql --datadir=$DB_DATA_PATH" >> /boot.sh
RUN echo "mysqld_safe --datadir=$DB_DATA_PATH --skip-grant-tables &" >> /boot.sh
RUN echo "sleep 3" >> /boot.sh
RUN echo "echo 'create database $DB_NAME' | mysql -u root" >> /boot.sh

# if you need redis, uncomment the lines below
# RUN apk --update add redis
# RUN echo 'redis-server &' >> /boot.sh

# daemon for cron jobs
RUN echo 'echo will install crond...' >> /boot.sh
RUN echo 'crond' >> /boot.sh

# Basic npm start verification
RUN echo 'nb=`cat package.json | grep start | wc -l` && if test "$nb" = "0" ; then echo "*** Boot issue: No start command found in your package.json in the scripts. See https://docs.npmjs.com/cli/start" ; exit 1 ; fi' >> /usr/bin/start.sh

RUN echo 'npm install --production' >> /boot.sh

# npm start, make sure to have a start attribute in "scripts" in package.json
CMD sh /boot.sh && npm start
