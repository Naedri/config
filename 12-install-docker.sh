# -----------------
# Install using the apt repository
# https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository
# -----------------

# Add Docker's official GPG key:
sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update

# Install the docker package
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Verify that Docker is running:
sudo systemctl status docker

# Verify that the installation is successful
sudo docker run hello-world

# -----------------
# Add your user to the docker group
# https://docs.docker.com/engine/install/linux-postinstall/#add-your-user-to-the-docker-group
# -----------------

# Create the docker group.
sudo groupadd docker

# Add your user to the docker group.
sudo usermod -aG docker $USER

# activate the changes to gropus
newgrp docker

# Verify that you can run docker commands without sudo.
docker run hello-world

# -----------------
# Install the Docker Compose plugin
# https://docs.docker.com/compose/install/linux/
# -----------------

# Install using the repository
sudo apt-get update
sudo apt-get install docker-compose-plugin

# Verify that Docker Compose is installed correctly by checking the version.
docker compose version
