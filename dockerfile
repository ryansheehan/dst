FROM tianon/steam

MAINTAINER Ryan Sheehan <rsheehan@gmail.com>

WORKDIR $HOME

# copy install and update scripts
ADD ["install_dst", "update", "run", "update_and_run", "steamcmd_linux.tar.gz", "/home/steam/"]

# install dst
RUN $HOME/steamcmd.sh +runscript install_dst

# expose the master port
EXPOSE 10888

# create the data volume
VOLUME ["/home/steam/.klei/DoNotStarveTogether"]

# default run the server
CMD ["source", "update_and_run"]

