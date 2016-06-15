#!/bin/bash

export PATH="/home/builder/.rbenv/bin:/home/builder/.rbenv/plugins/ruby-build/bin:$PATH" && \
export RUBY_CFLAGS='-O2' && \
export CONFIGURE_OPTS="--disable-install-doc" && \
eval "$(rbenv init -)"
