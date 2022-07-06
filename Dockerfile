# Dockerfile with Poetry - largely inspired by https://github.com/python-poetry/poetry/discussions/1879#discussioncomment-216865

# `python-base` sets up all our shared environment variables
FROM python:3.10-slim as python-base


# PYTHON
# prevents python creating .pyc files
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# PIP
ENV PIP_NO_CACHE_DIR=off
ENV PIP_DISABLE_PIP_VERSION_CHECK=on
ENV PIP_DEFAULT_TIMEOUT=1000

# POETRY
# https://python-poetry.org/docs/configuration/#using-environment-variables
ENV POETRY_VERSION=1.1.13
# make poetry install to this location
ENV POETRY_HOME="/opt/poetry"
# make poetry create the virtual environment in the project's root, it gets named `.venv`
ENV POETRY_VIRTUALENVS_IN_PROJECT=true
# do not ask any interactive questions
ENV POETRY_NO_INTERACTION=1

# PATHS
# this is where our requirements + virtual environment will live
ENV PYSETUP_PATH="/opt/pysetup"
ENV VENV_PATH="/opt/pysetup/.venv"
# prepend poetry and venv to path
ENV PATH="$POETRY_HOME/bin:$VENV_PATH/bin:$PATH"


# `builder-base` stage is used to build deps + create our virtual environment
FROM python-base as builder-base
RUN apt-get update && apt-get install --no-install-recommends -y \
        # deps for installing poetry
        curl \
        # deps for building python deps
        build-essential

# install poetry - respects $POETRY_VERSION & $POETRY_HOME
RUN curl -sSL https://install.python-poetry.org | python3 -

# copy project requirement files here to ensure they will be cached.
WORKDIR $PYSETUP_PATH
COPY . ./

# install runtime deps - uses $POETRY_VIRTUALENVS_IN_PROJECT internally
RUN poetry install --no-dev

# `development` image is used during development / testing
FROM python-base as development
WORKDIR $PYSETUP_PATH

# quicker install as runtime deps are already installed
# copy in our built poetry + venv
COPY --from=builder-base $POETRY_HOME $POETRY_HOME
COPY --from=builder-base $PYSETUP_PATH $PYSETUP_PATH
RUN poetry install

EXPOSE 8000

ENTRYPOINT [ "uvicorn" ]
CMD [ "main:app", "--host", "0.0.0.0" ]
