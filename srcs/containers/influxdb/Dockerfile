FROM	alpine:3.11

RUN 	apk add influxdb ; \
	apk add openrc ; \
 	apk add ca-certificates

EXPOSE	8086

CMD 	influxd run -config /etc/influxdb.conf
