# BarKeeper

A versatile web framework to assemble, analyze and manage DNA barcode data and metadata.

- Example implementation: barkeeper.uni-muenster.de (credentials: user@example.com - barkeeper2022)

## Using BarKeeper for your own project
You can set up your own project with BarKeeper Web Framework easily by running it via Docker. 
If you don't know what Docker is, read their excellent [Get Started with Docker guide](https://docs.docker.com/get-started/).

For testing purposes BarKeeper can be set up on any server or personal computer with an OS capable of running Docker. 
However, for running BarKeeper in a production environment we strongly recommend setting up a server with a current 
version of Ubuntu and sufficient hardware to handle your project's needs. Remember that this needs to be done only once 
per project. Every other member will be able to use BarKeeper simply from their web browser without the need of 
installing anything else.

### Prerequisites
Here's what you need to prepare before you can start the setup process:
- Make sure that you have a stable internet connection during all steps of the setup process.
- Have a server or Desktop computer running any OS capable of supporting Docker. Setup was tested on machines running 
Ubuntu 16.04 up to 22.04 and Windows 10 with [WSL enabled](https://docs.microsoft.com/en-us/windows/wsl/install-win10). 
  - Windows: We recommend running all commands to install BarKeeper from within a WSL Ubuntu instance after installing 
  Docker Desktop via the executable file provided by Docker. 
  - Ubuntu versions: Older versions of Ubuntu will likely work as well but are not getting security updates any longer 
  (this is also true for Ubuntu 16.04 by now) so using those cannot be recommended in a production environment.
- You will also need a user with superuser or administrative rights during the installation process. 
- It is highly recommended that you establish suitable server security measures like a properly configured firewall in 
case you want to make BarKeeper accessible from the internet.
- Install Docker Engine or Desktop (choose the appropriate tutorial for your OS [here](https://docs.docker.com/install/)). 
The setup was tested with Docker version 18.06 and higher. Older versions may work but this cannot be guaranteed.
- Install Docker Compose (for newer versions of Docker this is already a part of the Docker installation). You can find detailed instructions 
  [here](https://docs.docker.com/compose/gettingstarted/).
  The setup was tested with Docker-Compose version 1.27 and higher. Older versions may work but this cannot be guaranteed.
- Clone the code from this repository to a suitable location on your computer or server via [Git](https://git-scm.com)
(you may need to download and install Git first).
- Make sure the ports used by redis and postgres are not already in use on your machine (redis: 6379, Postgres: 5432).
- If you want to run mislabel analyses on the sequences stored in your database on a remote server (SSH address can be 
specified in .env file) make sure that the SATIVA files are available and the alignment tool MAFFT is installed there. 
More information about SATIVA can be found [here](https://github.com/amkozlov/sativa).
- Optional: You can install [GNU Make](https://www.gnu.org/software/make/) for an easier setup and running BarKeeper 
with simple commands.

### Setup
- Find the file *.env-example* and copy it to a new file *.env* in the main directory of the repository you just cloned.
- Modify the *.env* file to your project's needs. Values that you need to change are described as such in the file. 
The same goes for variables that generally should not (or don't need to) be changed.
You do not need to add values for `SECRET_KEY_BASE` and `DEVISE_KEY` yet!
If you want the app to run on a port different to the standard port 80, please specify your desired port number in the 
environment variable `PORT`. The value of the variable `PUMA_PORT` should generally not be changed.
    - After setting up **all other** environment variables and saving the file, generate secret keys for Rails and Devise
     by running `make secret` two times and copying the generated random keys from your command line. 
     Add the first key as the value for `SECRET_KEY_BASE` 
     and the second as the value of `DEVISE_KEY` in your *.env* file and save it.
       - The first time you run the `make secret` command, this will install all dependencies inside the app docker 
       container. This can take some time! The following invocation should run much quicker then.
       - If you cannot or do not want to use make, you can run the command `docker-compose run app rails secret` instead.
- Now you can install the whole app by running `make install`.
  - If you can not or do not want to use make, run these commands instead in this order:
    - `docker-compose run app rails db:reset`
    - `docker-compose run app rails assets:precompile`
    - `docker-compose up -d`
- You should be able to see the about page of your project's new app on your domain now. Even if you did not specify any 
domain, you can always find BarKeeper running on "localhost".
    - HTTPS is not enabled yet. If you want to configure this, you will have to change the *nginx.conf* file manually 
    and install a certificate. You can find more information [here](http://nginx.org/en/docs/http/configuring_https_servers.html)
    or contact the developers of BarKeeper for help on this.
- Use the admin credentials you added to the *.env* file to initially log in and create new records for your project.
    - You can start by going to the **Admin area > Home configuration** page and change the About page background and 
    add a description of your project.
- You are done! Now you and your team can use the new app and start uploading data!

- To stop and restart the app use the commands `make stop` followed by `make start` or just `make restart`.
  - Instead you can run `docker-compose down` and `docker-compose up -d`
- To remove unused BarKeeper containers created on your system use `make remove`.
  - Instead you can use `docker-compose rm -s -v -f`


### Further notes
- BarKeeper uses location data maps with map tiles from the Open Street Map Foundation. Please check if your 
implementation might need to use a different provider of map tiles as per their 
[Tile Usage Policy](https://operations.osmfoundation.org/policies/tiles/) to avoid being blocked from their services. 
You can change the map tile layer in the app/assets/individuals.js file.

### License

Copyright (C) 2022 Kai Müller <kaimueller@uni-muenster.de>, Sarah Wiechers <sarah.wiechers@uni-muenster.de>

BarKeeper is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

BarKeeper is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with BarKeeper.  If not, see
<http://www.gnu.org/licenses/>.
