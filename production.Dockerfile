# Use Ruby version from your .ruby-version
ARG RUBY_VERSION=3.4.2
FROM docker.io/library/ruby:$RUBY_VERSION-slim

# Rails app lives here
WORKDIR /rails

# Install system dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    bash \
    bash-completion \
    libffi-dev \
    tzdata \
    nodejs \
    npm \
    yarn \    
    curl \
    git \
    libjemalloc2 \
    libpq-dev \
    libvips \
    pkg-config \
    postgresql-client \
    libyaml-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man
    

# Set production environment
ENV RAILS_LOG_TO_STDOUT="1"\
    RAILS_SERVE_STATIC_FILES="true" \
    BUNDLE_WITHOUT="development" 

# Install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy application code
COPY . . 

RUN bundle exec bootsnap precompile --gemfile app/ lib/

RUN SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile 



# No COPY of application code here! It will come from the volume mount

ENTRYPOINT ["./bin/docker-production-entrypoint"]

# Start server
EXPOSE 3000
CMD ["./bin/rails", "server", "-b", "0.0.0.0"]