FROM ruby:3.3-slim

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential \
      git \
      libpq-dev \
      libyaml-dev \
      pkg-config \
      curl \
    && rm -rf /var/lib/apt/lists /var/cache/apt/archives

ARG USER_ID=1000
ARG GROUP_ID=1000

RUN groupadd -f -g ${GROUP_ID} app && \
    useradd -u ${USER_ID} -g ${GROUP_ID} -m -s /bin/bash app

USER app

ENV GEM_HOME=/home/app/gems \
    BUNDLE_PATH=/home/app/gems \
    BUNDLE_BIN=/home/app/gems/bin \
    PATH="/home/app/gems/bin:${PATH}"

RUN gem install bundler -N

WORKDIR /rails

COPY --chown=app:app Gemfile Gemfile.lock ./
RUN bundle install

COPY --chown=app:app . .

# Genera los assets de Propshaft en build para que producción no dependa
# de compilarlos en runtime ni devuelva 404 para application.css.
RUN SECRET_KEY_BASE_DUMMY=1 \
    RAILS_ENV=production \
    RAILS_SERVE_STATIC_FILES=true \
    DATABASE_URL=postgresql://postgres:postgres@127.0.0.1:5432/gol_ahora_production \
    CACHE_DATABASE_URL=postgresql://postgres:postgres@127.0.0.1:5432/gol_ahora_production_cache \
    QUEUE_DATABASE_URL=postgresql://postgres:postgres@127.0.0.1:5432/gol_ahora_production_queue \
    CABLE_DATABASE_URL=postgresql://postgres:postgres@127.0.0.1:5432/gol_ahora_production_cable \
    bundle exec rails assets:precompile

EXPOSE 3000

ENTRYPOINT ["/rails/entrypoint.sh"]
CMD ["rails", "server", "-b", "0.0.0.0"]
