# --- STAGE 1: Builder ---
FROM python:3.11-slim as builder

ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
WORKDIR /app

# install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# build wheels for requirements
COPY requirements.txt .
RUN pip install --upgrade pip
RUN pip wheel --no-cache-dir --wheel-dir /usr/src/app/wheels -r requirements.txt

# --- STAGE 2: Production ---
FROM python:3.11-slim

ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
WORKDIR /app

# install dependencies
RUN apt-get update && apt-get install -y ffmpeg nginx \
    && rm -rf /var/lib/apt/lists/*

# terminal settings
RUN echo 'export PS1="\[$(tput bold)\]\[$(tput setaf 6)\]\\t \\d\\n\[$(tput setaf 2)\][\[$(tput setaf 3)\]\u\[$(tput setaf 1)\]@\[$(tput setaf 3)\]\h \[$(tput setaf 6)\]\w\[$(tput setaf 2)\]]\[$(tput setaf 4)\\]\\$ \[$(tput sgr0)\]"' >> /root/.bashrc \
    && echo "alias grep='grep --color=auto'" >> /root/.bashrc

# timezone
RUN ln -snf /usr/share/zoneinfo/Asia/Kuala_Lumpur /etc/localtime && \
    echo Asia/Kuala_Lumpur > /etc/timezone

# install packages from wheels
COPY --from=builder /usr/src/app/wheels /usr/src/app/wheels
COPY --from=builder /app/requirements.txt .
RUN pip install --upgrade pip
RUN pip install --no-cache-dir --no-index --find-links=/usr/src/app/wheels -r requirements.txt

# copy files
COPY . /app

# nginx config
COPY nginx.conf /etc/nginx/conf.d

# entrypoinscript
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]
