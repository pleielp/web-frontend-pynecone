FROM python:3.11-slim as base

RUN adduser --disabled-password pynecone


FROM base as build

WORKDIR /app
ENV VIRTUAL_ENV=/app/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

COPY . .

RUN pip install wheel \
    && pip install -r requirements.txt


FROM base as runtime

RUN apt-get update && apt-get install -y \
    curl \
    && curl -fsSL https://deb.nodesource.com/setup_19.x | bash - \
    && apt-get update && apt-get install -y \
    nodejs \
    unzip \
    && npm i -g next \
    # && npm i \
    && rm -rf /var/lib/apt/lists/*

ENV PATH="/app/venv/bin:$PATH"


FROM runtime as init

WORKDIR /app
ENV BUN_INSTALL="/app/.bun"
COPY --from=build /app/ /app/
RUN pc init


FROM runtime

COPY --chown=pynecone --from=init /app/ /app/
USER pynecone
WORKDIR /app

# CMD ["pc","run" , "--env", "prod"]
CMD ["pc","run"]
# RUN pc run

EXPOSE 3000
EXPOSE 8000