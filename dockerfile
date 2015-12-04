FROM tianon/steam

MAINTAINER Ryan Sheehan <rsheehan@gmail.com>

WORKDIR $HOME

# copy install and update scripts
ADD ["install_dst", "steamcmd_linux.tar.gz", "/home/steam/"]

# install dst
RUN $HOME/steamcmd.sh +runscript install_dst

# install dependencies
RUN sudo apt-get update && sudo apt-get install -y libcurl4-gnutls-dev:i386

# expose the master port
EXPOSE 10888

ADD ["update", "run", "update_and_run", "/home/steam/"]

# create the data volume
VOLUME ["/home/steam/.klei/DoNotStarveTogether"]

# default run the server
CMD ["./update_and_run"]

