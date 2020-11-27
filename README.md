# Barcode Workflow Manager

A web framework to assemble, analyze and manage DNA barcode data and metadata.

- Example usage: https://gbol5.de

### Setup
- Install Docker
- Install Docker Compose
- Clone BWM repository from GitHub
- Find file .env-example, copy it to .env in the main bwm directory and modify to your needs
    - Make sure the ports used by redis and postgres are not already in use (redis: 6379, pg: 5432)
    - After setting up all other env vars generate secret keys for SECRET_KEY_BASE und DEVISE_KEY by running make secret (two times)
       - The first time you run the command, this will install all dependencies inside the app container. This can take some time. 
       - Stop the container afterwards by running make stop
- Run make install (an internet connection is needed)
- You should be able to see the about page of your new app on your domain now
- Use the admin credentials you added to the env file to initially log in and create records



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
