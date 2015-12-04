FROM tianon/steam

MAINTAINER Ryan Sheehan <rsheehan@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

# expose the slave port
EXPOSE 10888

# install dependencies
RUN sudo apt-get update && sudo apt-get install -y libcurl4-gnutls-dev:i386

# add and extract steamcmd
ADD ["steamcmd_linux.tar.gz", "/home/steam/"]

# install dst
RUN $HOME/steamcmd.sh +@ShutdownOnFailedCommand 1 +@NoPromptForPassword 1 +login anonymous +force_install_dir /home/steam/steamapps/DST +app_update 343050 validate +quit

# copy scripts
COPY ["run", "/home/steam/"]

# create the data volume
VOLUME ["/home/steam/.klei/DoNotStarveTogether"]

# default command to run
CMD ["/home/steam/run"]

# default run the server
ENTRYPOINT ["/bin/bash"]

