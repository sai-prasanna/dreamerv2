FROM pytorch/pytorch:1.12.1-cuda11.3-cudnn8-runtime

# System packages.
RUN apt-get update && apt-get install -y \
  ffmpeg \
  libgl1-mesa-dev \
  python3-pip \
  unrar \
  wget \
  && apt-get clean

# MuJoCo.
ENV MUJOCO_GL egl
RUN mkdir -p /root/.mujoco && \
  wget -nv https://www.roboti.us/download/mujoco200_linux.zip -O mujoco.zip && \
  unzip mujoco.zip -d /root/.mujoco && \
  rm mujoco.zip

# Python packages.
RUN pip3 install --no-cache-dir \
  'gym[atari]' \
  atari_py \
  crafter \
  dm_control \
  ruamel.yaml

# Atari ROMS.
RUN wget -L -nv http://www.atarimania.com/roms/Roms.rar && \
  unrar x Roms.rar && \
  unzip ROMS.zip && \
  python3 -m atari_py.import_roms ROMS && \
  rm -rf Roms.rar ROMS.zip ROMS

# MuJoCo key.
ARG MUJOCO_KEY=""
RUN echo "$MUJOCO_KEY" > /root/.mujoco/mjkey.txt
RUN cat /root/.mujoco/mjkey.txt

# DreamerV2.
COPY . /app
WORKDIR /app
CMD [ \
  "python3", "dreamerv2_torch/train.py", \
  "--logdir", "/logdir/$(date +%Y%m%d-%H%M%S)", \
  "--configs", "defaults", "atari", \
  "--task", "atari_pong" \
]
