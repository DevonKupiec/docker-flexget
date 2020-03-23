FROM		python:3.8-slim

RUN		pip install --no-cache-dir \
			flexget \
			cloudscraper \
			cryptography \
			deluge-client \
			irc_bot \
			pysocks \
			python-telegram-bot \
			transmissionrpc

COPY		files/ /

# copy libtorrent libs
COPY		--from=emmercm/libtorrent:1.2.5-alpine /usr/lib/libtorrent-rasterbar.a /usr/lib/
COPY		--from=emmercm/libtorrent:1.2.5-alpine /usr/lib/libtorrent-rasterbar.la /usr/lib/
COPY		--from=emmercm/libtorrent:1.2.5-alpine /usr/lib/libtorrent-rasterbar.so.10.0.0 /usr/lib/
COPY		--from=emmercm/libtorrent:1.2.5-alpine /usr/lib/python3.8/site-packages/libtorrent.cpython-38-x86_64-linux-gnu.so /usr/lib/python3.8/site-packages/
COPY		--from=emmercm/libtorrent:1.2.5-alpine /usr/lib/python3.8/site-packages/python_libtorrent-1.2.5-py3.8.egg-info /usr/lib/python3.8/site-packages/

# symlink libtorretn libs
RUN \
		cd /usr/lib && \
		ln -s libtorrent-rasterbar.so.10.0.0 libtorrent-rasterbar.so && \
		ln -s libtorrent-rasterbar.so.10.0.0 libtorrent-rasterbar.so.10

# add default volumes
VOLUME		/config /data
WORKDIR		/config

# expose port for flexget webui
EXPOSE		3539 3539/tcp

# run init.sh to set uid, gid, permissions and to launch flexget
RUN		chmod +x /scripts/init.sh
CMD		["/scripts/init.sh"]
