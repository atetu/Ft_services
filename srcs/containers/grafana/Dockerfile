FROM	alpine:3.11

RUN	wget -P /tmp/  https://dl.grafana.com/oss/release/grafana-6.7.1.linux-amd64.tar.gz ; \
	tar -zxvf /tmp/grafana-6.7.1.linux-amd64.tar.gz 

RUN	set -ex ; \
	addgroup -S grafana ; \
	adduser -S -G grafana grafana ; \
	apk add --no-cache libc6-compat ca-certificates su-exec bash ; \
	apk add openrc

COPY	grafana.db /grafana-6.7.1/data/

EXPOSE	3000

COPY	start.sh .

RUN	chmod 775 start.sh

CMD	./start.sh
