#!/bin/bash

git clone --depth 1 https://github.com/sstephenson/rbenv.git /home/builder/.rbenv && \
git clone --depth 1 https://github.com/sstephenson/ruby-build.git /home/builder/.rbenv/plugins/ruby-build && \
rm -rfv /home/builder/.rbenv/plugins/ruby-build/.git && \
rm -rfv /home/builder/.rbenv/.git && \
mkdir -p /home/builder/.rbenv/versions && \
mkdir -p /home/builder/.rbenv/shims && \
chown -R builder:builder /home/builder/.rbenv/versions && \
chown -R builder:builder /home/builder/.rbenv/shims && \
export PATH="/home/builder/.rbenv/bin:/home/builder/.rbenv/plugins/ruby-build/bin:$PATH" && \
export RUBY_CFLAGS='-O2' && \
export CONFIGURE_OPTS="--disable-install-doc" && \
eval "$(rbenv init -)" && \
rbenv install $1 && \
rbenv global $1 && \
gem install bundler && \
rbenv rehash
