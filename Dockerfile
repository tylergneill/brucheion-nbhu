FROM golang:1.16.1-alpine as builder

ENV NODE_VERSION 14.17.0
ENV NPM_VERSION 6.14.13

RUN curl -SLO "http://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz" \
	&& curl -SLO "http://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
	&& gpg --verify SHASUMS256.txt.asc \
	&& grep " node-v$NODE_VERSION-linux-x64.tar.gz\$" SHASUMS256.txt.asc | sha256sum -c - \
	&& tar -xzf "node-v$NODE_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1 \
	&& rm "node-v$NODE_VERSION-linux-x64.tar.gz" SHASUMS256.txt.asc \
	&& npm install -g npm@"$NPM_VERSION" \
	&& npm cache clear

ENV PATH $PATH:/nodejs/bin


RUN apk add -U --no-cache ca-certificates git tzdata
RUN mkdir /app
ADD . /app/
WORKDIR /app
RUN cd app && npm install && npm run dev
RUN CGO_ENABLED=0 go build -mod vendor -o brucheion -v

FROM alpine
ENV PROJECT_ROOT /
RUN adduser -S -D -H -h / heroku
USER heroku
COPY --from=builder /app /
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
CMD [ "/brucheion", "-localAssets", "-noauth", "-config=config.json", "heroku"]
