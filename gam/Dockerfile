FROM python:3.12-slim

RUN apt-get update && apt-get install -y curl bash tar xz-utils
RUN curl -s -S -L https://git.io/gam-install | bash -s -- -l

ENV PATH="/root/bin/gam7:${PATH}"

WORKDIR /workspace

# ENTRYPOINT ["gam"]
