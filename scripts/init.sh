#!/bin/bash

export PATH="/home/builder/.rbenv/bin:$PATH" && \
export RUBY_CFLAGS='-O2' && \
export CONFIGURE_OPTS="--disable-install-doc" && \
eval "$(rbenv init -)"
