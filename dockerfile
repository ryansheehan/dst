FROM tianon/steamos

MAINTAINER Ryan Sheehan <rsheehan@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN echo 'deb [arch=amd64,i386] http://repo.steampowered.com/steam precise steam' > /etc/apt/sources.list.d/steam.list && dpkg --add-architecture i386

# install dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-gnutls-dev:i386 \
    libc6:i386 \
    # libgl1-mesa-dri:i386 \
    # libgl1-mesa-glx:i386 \
    lib32gcc1 \
    lib32stdc++6 \
    tar \
    adduser \
    sudo \
    && apt-get clean

# setup steam user
RUN echo 'steam ALL = NOPASSWD: ALL' > /etc/sudoers.d/steam && chmod 0440 /etc/sudoers.d/steam
RUN adduser --disabled-password --gecos 'Steam' steam && adduser steam video
ENV HOME /home/steam

# get steamcmd tar.gz
ADD ["http://media.steampowered.com/installer/steamcmd_linux.tar.gz", "/home/steam/"]
RUN tar -xvzf /home/steam/steamcmd_linux.tar.gz -C /home/steam/ && rm /home/steam/steamcmd_linux.tar.gz

# switch to steam user
USER steam

# expose the slave port
EXPOSE 10888

# install dst
RUN $HOME/steamcmd.sh +@ShutdownOnFailedCommand 1 +@NoPromptForPassword 1 +login anonymous +force_install_dir /home/steam/steamapps/DST +app_update 343050 validate +quit

# copy scripts
COPY ["run", "/home/steam/"]

# create the data volume
VOLUME ["/home/steam/.klei/DoNotStarveTogether", "/mods"]

# default run the server
ENTRYPOINT ["/home/steam/run"]

