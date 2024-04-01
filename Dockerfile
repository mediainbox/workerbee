FROM nvidia/cuda:12.3.2-devel-ubuntu22.04 as build

ENV PYTHON_VERSION 3.11

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get install -y curl git-core gcc make zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev libssl-dev
RUN apt-get install -y build-essential libncursesw5-dev libgdbm-dev libc6-dev tk-dev
RUN apt-get install -y libffi-dev liblzma-dev

ENV PYENV_ROOT $HOME/.pyenv
ENV PATH $PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH

# Install pyenv
RUN set -ex \
    && curl https://pyenv.run | bash \
    && pyenv update \
    && pyenv install $PYTHON_VERSION \
    && pyenv global $PYTHON_VERSION \
    && pyenv rehash

ENV POETRY_HOME='/usr/local'
RUN python -mpip install --upgrade pip
RUN curl -sSL https://install.python-poetry.org | python3 -
COPY . /app
WORKDIR /app
RUN python -mpip install toml
RUN poetry
RUN ./build-bin.sh cuda linux-64 "-DLLAMA_CUBLAS=1"

ENTRYPOINT /app/dist/gputopia-worker-cuda-linux-64 --queen_url $QUEEN_URL
