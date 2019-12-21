FROM alpine:3.11

# install base packages
RUN	apk add --no-cache \
		bash \
		curl \
		python3 \
		py3-cryptography \
		shadow \
		tzdata && \
	python3 -m ensurepip && \
	rm -r /usr/lib/python*/ensurepip && \
	pip3 install --upgrade pip setuptools && \
	if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi && \
	if [[ ! -e /usr/bin/python ]]; then ln -sf /usr/bin/python3 /usr/bin/python; fi && \
	sed -i 's/^CREATE_MAIL_SPOOL=yes/CREATE_MAIL_SPOOL=no/' /etc/default/useradd

# install build dependencies with pip packages
RUN	apk add --no-cache --virtual=build-deps \
		boost-python3 \
		g++ \
		gcc \
		libffi-dev \
		libstdc++ \
		openssl-dev \
		python3-dev \
		py3-cryptography && \
	pip install --upgrade --no-cache-dir \
		cloudscraper \
		cryptography \
		deluge_client \
		irc_bot \
		python-telegram-bot \
		transmissionrpc && \
	apk del --purge --no-cache build-deps  && \
	rm -rf \
		/tmp/* \
		/root/.cache

# Install/update flexget
RUN	pip install --upgrade --force-reinstall --no-cache-dir flexget

# copy local files
COPY files/ /

# copy libtorrent libs
COPY --from=emmercm/libtorrent:1.2.2-alpine /usr/lib/libtorrent-rasterbar.a /usr/lib/
COPY --from=emmercm/libtorrent:1.2.2-alpine /usr/lib/libtorrent-rasterbar.la /usr/lib/
COPY --from=emmercm/libtorrent:1.2.2-alpine /usr/lib/libtorrent-rasterbar.so.10.0.0 /usr/lib/
COPY --from=emmercm/libtorrent:1.2.2-alpine /usr/lib/python3.8/site-packages/libtorrent.cpython-38-x86_64-linux-gnu.so /usr/lib/python3.8/site-packages/
COPY --from=emmercm/libtorrent:1.2.2-alpine /usr/lib/python3.8/site-packages/python_libtorrent-1.2.2-py3.8.egg-info /usr/lib/python3.8/site-packages/

# symlink libtorretn libs
RUN \
	cd /usr/lib && \
	ln -s libtorrent-rasterbar.so.10.0.0 libtorrent-rasterbar.so && \
	ln -s libtorrent-rasterbar.so.10.0.0 libtorrent-rasterbar.so.10

# add default volumes
VOLUME /config /data
WORKDIR /config

# expose port for flexget webui
EXPOSE 3539 3539/tcp

# run init.sh to set uid, gid, permissions and to launch flexget
RUN chmod +x /scripts/init.sh
CMD ["/scripts/init.sh"]
