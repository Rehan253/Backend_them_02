# build stage
FROM hexpm/elixir:1.15.7-erlang-26.2.1-debian-bookworm-20240130 AS build

# Install build tools & dependencies
RUN apt-get update && apt-get install -y \
  git build-essential npm postgresql-client curl

# Set working directory
WORKDIR /app

# Install Hex and Rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Copy project files required to fetch deps
COPY mix.exs mix.lock ./ 
COPY config config

# Fetch and compile dependencies
RUN mix deps.get --only prod
RUN mix deps.compile

# copy all source files
COPY . .

# Compile the app
RUN MIX_ENV=prod mix compile

# (Optional) build frontend assets
# RUN npm install --prefix assets && npm run deploy --prefix assets && mix phx.digest

# Build release
RUN MIX_ENV=prod mix release

# STEP 2 — Release stage
FROM debian:bookworm-slim AS app
RUN apt-get update && apt-get install -y \
  openssl libncurses5 libstdc++6 postgresql-client curl && apt-get clean

WORKDIR /app

# Copy release from build stage
COPY --from=build /app/_build/prod/rel/as_backend_theme2 ./

# Copy entrypoint script
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

ENV LANG=C.UTF-8
ENV MIX_ENV=prod
ENV PORT=4000

# Use entrypoint
ENTRYPOINT ["/app/entrypoint.sh"]
