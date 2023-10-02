package main

import (
	"context"
	"net"
	"time"
)

func main() {
	r := &net.Resolver{
		PreferGo: true,
		Dial: func(ctx context.Context, network, address string) (net.Conn, error) {
			d := net.Dialer{
				Timeout: time.Millisecond * time.Duration(10000),
			}
			return d.DialContext(ctx, network, "8.8.1.8:53")
		},
	}
	ip, _ := r.LookupHost(context.Background(), "google.com")

	print(ip[0])
}
