FROM golang:1.16.1-alpine as builder

RUN apk add -U --no-cache ca-certificates git tzdata
RUN mkdir /app
ADD . /app/
WORKDIR /app
RUN CGO_ENABLED=0 go build -mod vendor -o brucheion -v

FROM alpine
ENV PROJECT_ROOT /
RUN adduser -S -D -H -h / heroku
USER heroku
COPY --from=builder /app /
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
CMD [ "/brucheion", "-localAssets", "-noauth", "-config=config.json", "heroku"]
