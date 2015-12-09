# dst
Docker setup for Dont Starve Together dedicated server *including caves!*

**To play caves please make sure you opt-in to the Don't Starve Together beta via steam**

## Setup docker on server
*These instructions assume a debian based server, please skip to the volume instructions if you already have docker installed on your machine.*

For [ubuntu installation click here](https://docs.docker.com/engine/installation/ubuntulinux/)

For [anything else](https://docs.docker.com/engine/installation/)

## Setup docker-compose on server
*Use this for the super extra easy way to run your Don't Starve Together dedicated server with caves!*

For [ubuntu installation click here](http://docs.docker.com/engine/installation/ubuntulinux/)

For [anything else](https://docs.docker.com/compose/install/)

## Super easy dst dedicated server setup instructions
*Make sure docker-engine and docker-compose is installed*

1. Create folder with the following directory structure
   
   ```
    dstvolumes/
        master/
        slave/
   ```
2. Copy server_token.txt into master and slave

   You can follow the section on [generating server_token.txt](#Generate-server-token-and-copy-it-to-the-server)
   
   ```
    dstvolumes/
        master/
            server_token.txt
        slave/
            server_token.txt
   ```
3. Create settings.ini files for master and slave
   
   ```
    dstvolumes/
        master/
            server_token.txt
            settings.ini
        slave/
            server_token.txt
            settings.ini
   ```


## Build server container from Dockerfile
**You can skip this step and use the container I built on dockerhub ryshe/dst**

Get this repository and build the container
```shell
sudo apt-get install -y git
cd ~
git clone https://github.com/ryansheehan/dst.git
cd dst
sudo docker build -t dst .
```

-In future steps you can swap `ryshe/dst` with your `dst` container.
-You may use a different name than `dst`.  Look at the [Docker documentation for building](https://docs.docker.com/engine/reference/commandline/build/)

## Setup data volume
Open a shell and setup a place to store save data, server_token.txt, and settings.ini
```shell
mkdir -p $HOME/dst_data
cd dst_data
mkdir -p $HOME/master
```
If running caves create a place for its configuration data
```shell
mkdir -p $HOME/dst_data/slave
```

## Generate server token and copy it to the server
1. Run the Don't Starve Together client located in your steam library
2. Press `~` key to open the console in game
3. Enter `TheNet:GenerateServerToken()` which will generate a server_token.txt file
   * Linux: located in ~/.klei/DoNotStarveTogether
   * Windows: located in C:\Users\<your name>\Documents\Klei\DoNotStarveTogether
4. Copy server_token.txt onto your server into the folders $HOME/dst_data/master (and $HOME/dst_data/slave if running caves)

## Create *server* settings.ini
Use your favorite text editor and create a file "settings.ini".  Fill it with the following contents.

```ini
[network]

default_server_name = My DST Server with caves
default_server_description = We have caves!

;must be unique per server in cluster
server_port = 10999

;change this password
server_password = password123
max_players = 4
pvp = false
game_mode = survival
enable_snapshots = false
enable_autosaver = true
tick_rate = 30
connection_timeout = 10000
server_save_slot = 1
pause_when_empty = true
dedicated_lan_server = false
server_intention = cooperative


[shard]

;required true for shard features
shard_enable = true
is_master = true

;required for slave
master_ip = 127.0.0.1

;do not touch
master_port = 10888
bind_ip = 0.0.0.0

;change to whatever, helpful in logs
shard_name = master

;change the cluster key to something unique
cluster_key = secret_cluster_key


[MISC]
CONSOLE_ENABLED = true
autocompiler_enabled = true
```
Change to your preference:

1. `default_server_name`
2. `default_server_description`
3. `cluster_key`
4. `server_password` or remove it for public server
5. **do not change `master_port`**
6. any other configuration option that you wish

**copy this settings.ini file into `$HOME/dst_data/master`**


## Create *slave* settings.ini
*Skip if you're not setting up a slave server*

Use your favorite text editor and create a file "settings.ini".  Fill it with the following contents.
Change to your preference:

```ini
[network]

default_server_name = My DST Server with caves
default_server_description = We have caves!

;must be unique per server in cluster
server_port = 10998

;change this password
server_password = password123
max_players = 4
pvp = false
game_mode = survival
enable_snapshots = false
enable_autosaver = true
tick_rate = 30
connection_timeout = 10000
server_save_slot = 1
pause_when_empty = true
dedicated_lan_server = false
server_intention = cooperative


[shard]

;required true for shard features
shard_enable = true
is_master = false

;required for slave will get auto set by scripts
master_ip = 127.0.0.1

;do not touch
master_port = 10888
bind_ip = 0.0.0.0

;change to whatever, helpful in logs
shard_name = slave

;change the cluster key to something unique
cluster_key = secret_cluster_key


[MISC]
CONSOLE_ENABLED = true
autocompiler_enabled = true
```
1. `cluster_key` must match the server's settings.ini `cluster_key` value
2. **DO NOT CHANGE `master_port`** 

**copy this settings.ini file into `$HOME/dst_data/slave`**

## Setup slave server world gen to create caves
*Skip if not setting up a caves server*

In `$HOME/dst_data/slave` create a file `worldgenoverride.lua` and fill it with:

```lua
return {
override_enabled = true,
preset="DST_CAVE",
}
```

## Run dst server container
Time to launch the server container!  *You may run the container in the background if you do not plan to setup caves by swapping `-it` with `-dit`*

From a shell window on your server:
```shell
sudo docker run -it --name="dst" -p 10999:10999 -v $HOME/dst_data/master:/home/steam/.klei/DoNotStarveTogether ryshe/dst
```
[Docker run documentation](https://docs.docker.com/engine/reference/run/)

### If running caves
Create a new shell window and run the caves container
```shell
sudo docker run -it --name="dstslave0" -p 10998:10998 -v $HOME/dst_data/master:/home/steam/.klei/DoNotStarveTogether --link dst:master ryshe/dst
```

Once the caves server is connected we must regenerate the master world so that the caves entrances will show up.  So on the shell running the master type:
```
c_regenerateworld()
```

**Note:**
Other server commands can be found [here](http://dont-starve-game.wikia.com/wiki/Console/Don't_Starve_Together_Commands)
Sharding information can be found [here](http://forums.kleientertainment.com/topic/59174-understanding-shards-and-migration-portals/)

## Escape the docker-run shells
hit `ctrl p` followed by `ctrl q`

## Attach to a container already running
Attach to master
```shell
sudo docker attach dst
```

Attach to slave
```shell
sudo docker attach dstslave0
```

## Shutdown Server
attach to your server and run
```
c_shutdown()
```

## Restart container
Restart master
```shell
sudo docker restart dst
```

Restart slave
```shell
sudo docker restart dstslave0
```

## Mods
**Mods have received little testing**

Create another folder to store a file with mod information
```shell
mkdir -p $HOME/dst_data/mods
```

create a file in the `mods` folder called `mods.txt`
each line in the file should contain an id of the mod you wish to install.  IDs can be found on when looking at the url for a mod in the community hub workshop

e.g.: http://steamcommunity.com/sharedfiles/filedetails/?id=`522117250`

when running the containers for the master and slave attach the volume to the mods folder you created with an additional `-v $HOME/dst_data/mods:/mods`

## Notes
- Every time a container is started it will check for updates

## Additional Help/Links/Sources
[Docker](https://docs.docker.com/)
[DST Dedicated Servers](http://dont-starve-game.wikia.com/wiki/Guides/Don%E2%80%99t_Starve_Together_Dedicated_Servers)
[DST Console Commands](http://dont-starve-game.wikia.com/wiki/Console/Don't_Starve_Together_Commands)
[DST Caves Setup](http://forums.kleientertainment.com/topic/57890-playing-caves-beta/) *Check #2*
[Understanding DST Shards](http://forums.kleientertainment.com/topic/59174-understanding-shards-and-migration-portals/)

## ToDo
- Improve documentation
