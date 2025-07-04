# Use Ruby version from your .ruby-version
ARG RUBY_VERSION=3.4.2
FROM docker.io/library/ruby:$RUBY_VERSION-slim

# Rails app lives here
WORKDIR /app

# Install system dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    curl \
    git \
    libjemalloc2 \
    libpq-dev \
    libvips \
    pkg-config \
    postgresql-client \
    libyaml-dev && \
    rm -rf /var/lib/apt/lists/*

# Set development environment
ENV BUNDLE_WITHOUT="" \
    PATH="${PATH}:/app/bin"

# Install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy application code
COPY bin/docker-dev-entrypoint /app/bin/
RUN chmod +x /app/bin/docker-dev-entrypoint


# Create required directories
RUN mkdir -p tmp/pids db log storage

# Create non-root user and change ownership
RUN groupadd --gid 1000 rails && \
    useradd --uid 1000 --gid rails --shell /bin/bash --create-home rails && \
    chown -R rails:rails /app

# Switch to non-root user
USER rails

# No COPY of application code here! It will come from the volume mount

ENTRYPOINT ["docker-dev-entrypoint"]

# Start server
EXPOSE 3000
CMD ["./bin/rails", "server", "-b", "0.0.0.0"]
