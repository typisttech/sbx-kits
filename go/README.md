# go

Taken from https://docs.docker.com/learn/content/add-tools-and-runtimes-to-a-sandbox/?path=build-and-customize-docker-sandbox-environments



docker buildx build --builder kit-builder \
    go -f go/go.yaml \
    --build-arg version=1.27.2 \
    -t tt-sbx-kit/go:1.27.2 \
    --output type=oci,dest=/tmp/tt-sbx-kit-layout-go,tar=false

kit-tck inspect -layout /tmp/tt-sbx-kit-layout-go 1.27.2
