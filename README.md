# dst
Docker setup for Dont Starve Together dedicated server *including caves!*

**To play caves please make sure you opt-in to the Don't Starve Together beta via steam**

## Setup docker on server
*These instructions assume a debian based server, please skip to the volume instructions if you already have docker installed on your machine.*

For [ubuntu installation click here](https://docs.docker.com/engine/installation/ubuntulinux/)

For [anything else](https://docs.docker.com/engine/installation/)

## Setup data volume on server
1. ##### Create a volume directory
   
   ```
   $HOME/
       dstvolumes/
          master/
          slave/
   ```
2. ##### Add server token
   [Copy server_token.txt](#generate-server-token) into `dstvolumes/master` and `dstvolumes/slave`

   ```
   $HOME/
       dstvolumes/
          master/
              server_token.txt
          slave/
              server_token.txt
   ```
3. ##### Add master settings
   [Create settings.ini](#master-settings) for `dstvolumes/master`
   
   *NOTE: settings file is different than the slave's settings.ini*

   ```
   $HOME/
       dstvolumes/
          master/
              server_token.txt
              settings.ini
          slave/
              server_token.txt
   ```
4. ##### Add slave settings
   [Create settings.ini](#slave-settings) for `dstvolumes/slave`
   
   *NOTE: settings file is different than the master's settings.ini*   

   ```
   $HOME/
       dstvolumes/
          master/
              server_token.txt
              settings.ini
          slave/
              server_token.txt
              settings.ini
   ```
5. ##### Configure caves world
   [Create worldgenoverride.lua](#create-caves-world) in `dstvolumes/slave`

   ```
   $HOME/
       dstvolumes/
          master/
              server_token.txt
              settings.ini
          slave/
              server_token.txt
              settings.ini
              worldgenoverride.lua
   ```
6. [Create docker-compose.yml](#create-docker-compose) in `dstvolumes/`
   *NOTE: only needed if intending to use docker-compose to launch servers*

   ```
   $HOME/
       dstvolumes/
          docker-compose.yml
          master/
              server_token.txt
              settings.ini
          slave/
              server_token.txt
              settings.ini
              worldgenoverride.lua
   ```
   
7. Launch dst dedicated servers
   ### with docker-compose
   
   1. [Install docker-compose on your server](https://docs.docker.com/compose/install/)
   2. Navigate to volumes folder and run docker-compose
      
      ```shell
      cd $HOME/dstvolumes
      sudo docker-compose up
      ```
   
   ### with docker-engine
   1. Start the master server
      
      ```shell
      sudo docker run -it --name="dst" -p 10999:10999/udp -v $HOME/dstvolumes/master:/home/steam/.klei/DoNotStarveTogether ryshe/dst
      ```
   2. After the master server is done booting up, detatch from master server by pressing `ctrl+p ctrl+q`
   3. Start the slave server linked to the master server
   
      ```shell
      sudo docker run -it --name="dstslave" -p 10998:10998/udp -v $HOME/dstvolumes/slave:/home/steam/.klei/DoNotStarveTogether --link dst:master ryshe/dst
      ```
   4. After the slave server is done booting up, detatch from slave server by pressing `ctrl+p ctrl+q`
8. Find the container name running the master
   
   ```shell
   sudo docker ps -a
   ```
   It will look something like:
   
   -if running from docker-compose: `dstvolumes_dst_1`
   -if running from docker-engine: `dst`
   
9. Attach back on to the master server so that we can regenerate the world
   
   **In order to generate cave entrances we need to regenerate the world**

   ```shell
   sudo docker attach <container_name_from_last_step>
   ```
   
10. Invoke the world to regenerate in order to get caves entrances

   *NOTE: you should be connected to the server and able to see output when you type*

   ```
   c_regenerateworld()
   ```
   
11. Detatch from your server with `ctrl+p ctrl+q`
12. Enjoy your dedicated server!  Do not forget to opt into the beta on your DST client in steam, or you wont see your server!
   
## Getting latest updates from steam; just restart the servers
   - with docker-compose 
    
     ```shell
     shell sudo docker-compose restart
     ```
   - with docker-engine
    
     ```shell
     sudo docker restart dst
     sudo docker restart dstslave
     ```
    
## Mods support
   *NOTE: This is experimental*

   1. Create a new folder to act as a volume for the mods
      ```shell
      cd $HOME
      mkdir dstmods
      cd dstmods
      touch mods.txt
      ```
   2. Edit `dstmods/mods.txt`
      - each line in mods.txt should contain the id of the mod you wish to install
      - you can get the id of the mod from the url in community hub workshop
      - example: http://steamcommunity.com/sharedfiles/filedetails/?id=`522117250`
   3. Add the additional volume to the containers
      - with docker-compose
        1. Edit docker-compose.yml
        2. Under both `volumes:` blocks add `$HOME/dstmods:/mods`
      - with docker-engine add an additional `-v $HOME/dstmods:/mods` to both `docker run` commands
      
## Generate server token
1. Run the Don't Starve Together client located in your steam library
2. Press `~` key to open the console in game
3. Enter `TheNet:GenerateServerToken()` which will generate a server_token.txt file
   * Linux: located in ~/.klei/DoNotStarveTogether
   * Windows: located in C:\Users\<your name>\Documents\Klei\DoNotStarveTogether
[Go back](#add-server-token)    


## Master settings
Use your favorite text editor and create a file "settings.ini".  Fill it with the following contents.

[Go back](#add-master-settings)

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

## Slave settings
Use your favorite text editor and create a file "settings.ini".  Fill it with the following contents.

[Go back](#add-slave-settings)

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

## Create caves world
*save as `worldgenoverride.lua`*

[Go back](#configure-caves-world)

```lua
return {
override_enabled = true,
preset="DST_CAVE",
}
```

## Create docker-compose
[Go back](#with-docker-compose)

```yml
dstslave:
  image: ryshe/dst:latest
  ports:
    - 10998:10998/udp
  restart: always
  links:
    - dst:master
  volumes:
    - ./slave:/home/steam/.klei/DoNotStarveTogether

dst:
  image: ryshe/dst:latest  
  ports:
    - 10999:10999/udp
  restart: always
  volumes:
    - ./master:/home/steam/.klei/DoNotStarveTogether
```

## Build server container from Dockerfile
```shell
sudo apt-get install -y git
cd ~
git clone https://github.com/ryansheehan/dst.git
cd dst
sudo docker build -t <container_name_here> .
```

## Additional Help/Links/Sources
- [Docker](https://docs.docker.com/)
- [DST Dedicated Servers](http://dont-starve-game.wikia.com/wiki/Guides/Don%E2%80%99t_Starve_Together_Dedicated_Servers)
- [DST Console Commands](http://dont-starve-game.wikia.com/wiki/Console/Don't_Starve_Together_Commands)
- [DST Caves Setup](http://forums.kleientertainment.com/topic/57890-playing-caves-beta/)
- [Understanding DST Shards](http://forums.kleientertainment.com/topic/59174-understanding-shards-and-migration-portals/)
