# Barcode Workflow Manager

A web framework to assemble, analyze and manage DNA barcode data and metadata.

- Example usage: https://gbol5.de

## Using BWM for your own project
You can set up your own project with the Barcode Workflow Manager Web Framework easily by running it via Docker. 
If you don't know what Docker is, read their excellent [Get Started with Docker guide](https://docs.docker.com/get-started/).

### Prerequisites
Here's what you need to prepare before you can start the setup process:
- Create an [Amazon Web Storage](https://aws.amazon.com/de/products/storage/) bucket and have your credentials for it ready.
- Make sure that you have a stable internet connection during all steps of the setup process.
- Have a server set up with a user with sudo rights and suitable server security measures like a firewall established.
- Install Docker (see the abovementioned guide for installation instructions).
- Install Docker Compose. You can find detailed instructions [here](https://docs.docker.com/compose/gettingstarted/).
- Clone the code from this repository to a suitable location on your server.
- Make sure the ports used by redis and postgres are not already in use on your machine (redis: 6379, Postgres: 5432).

### Setup
- Find the file *.env-example* and copy it to a new file *.env* in the main directory of the repository you just cloned.
- Modify the *.env* file to your project's needs. Values that you need to change are described as such in the file. 
The same goes for variables that generally should not (or don't need to) be changed.
You do not need to add values for `SECRET_KEY_BASE` and `DEVISE_KEY` yet!
    - After setting up **all other** environment variables and saving the file, generate secret keys for Rails and Devise
     by running `make secret` two times and copying the generated random keys from your command line. 
     Add the first key as the value for `SECRET_KEY_BASE` 
     and the second as the value of `DEVISE_KEY` in your *.env* file and save it.
       - The first time you run the `make secret` command, this will install all dependencies inside the app docker 
       container. This can take some time! The following invocation should run much quicker then.
- Now you can install the whole app by running `make install`.
- You should be able to see the about page of your project's new app on your domain now.
    - HTTPS is not enabled yet. If you want to configure this, you will have to change the *nginx.conf* file manually 
    and install a certificate. You can find more information [here](http://nginx.org/en/docs/http/configuring_https_servers.html).
- Use the admin credentials you added to the *.env* file to initially log in and create new records for your project.
    - You can start by going to the **Admin area > Home configuration** page and change the About page background and 
    add a description of your project.
- You are done! Now you and your team can use the new app and start uploading data!

### License

Copyright (C) 2020 Kai Müller <kaimueller@uni-muenster.de>, Sarah Wiechers <sarah.wiechers@uni-muenster.de>

Barcode Workflow Manager is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

Barcode Workflow Manager is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with Barcode Workflow Manager.  If not, see
<http://www.gnu.org/licenses/>.
