FROM java:openjdk-8-jre


ENV NEO4J_SHA256=dbbc65683d65018c48fc14d82ee7691ca75f8f6ea79823b21291970638de5d88 \
    NEO4J_TARBALL=neo4j-community-3.3.0-unix.tar.gz \
    NEO4J_EDITION=community
ARG NEO4J_URI=http://dist.neo4j.org/neo4j-community-3.3.0-unix.tar.gz


COPY ./neo4j-app/local-package/* /tmp/

RUN curl --fail --silent --show-error --location --remote-name ${NEO4J_URI} \
    && echo "${NEO4J_SHA256} ${NEO4J_TARBALL}" | sha256sum --check --quiet - \
    && tar --extract --file ${NEO4J_TARBALL} --directory /var/lib \
    && mv /var/lib/neo4j-* /var/lib/neo4j \
    && rm ${NEO4J_TARBALL}


WORKDIR /var/lib/neo4j

RUN mv data /data \
    && ln -s /data /var/lib/neo4j/data 


VOLUME /data
VOLUME /conf

COPY neo4j-app/docker-entrypoint.sh /docker-entrypoint.sh
COPY neo4j-app/import-data.sh /import-data.sh
COPY neo4j-app/create-index.sh /create-index.sh
COPY neo4j-app/index.cql /index.cql

EXPOSE 7474 7473 7687

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["neo4j"]
