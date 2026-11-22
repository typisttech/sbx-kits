## Go

Modules come from proxy.golang.org only: GOPROXY has no `direct`
fallback, so a module that isn't on the proxy fails to download
instead of being fetched from its Git host. GOTOOLCHAIN is `local`,
so Go never downloads a different toolchain.
