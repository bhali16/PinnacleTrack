FROM python:3.12-slim
LABEL maintainer="bhali16"

# Ensure Python output is sent straight to terminal without buffering
ENV PYTHONUNBUFFERED 1

# Copy requirement files and app code
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app
WORKDIR /app
EXPOSE 8000

# Argument to specify if it's a dev environment
ARG DEV=false

# Install dependencies and set up virtual environment
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    apt-get update && apt-get install -y --no-install-recommends \
        postgresql-client build-essential libpq-dev gcc && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ "$DEV" = "true" ]; then \
        /py/bin/pip install -r /tmp/requirements.dev.txt; \
    fi && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

# Set the environment path to include the virtual environment
ENV PATH="/py/bin:$PATH"

# Run the app as the django-user (for security)
USER django-user
