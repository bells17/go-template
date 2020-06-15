FROM alpine:3.6

RUN apk add --no-cache ca-certificates

ADD bin/myapp /bin/

CMD ["/bin/myapp"]
