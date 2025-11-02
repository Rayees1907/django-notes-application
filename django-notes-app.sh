#!/bin/bash

# Function to clone the Django app code
code_clone()  {
	echo "************* Process Started *************"
	if [ -d "django-notes-application" ]; then
		echo "The directory already exists, pulling the latest commits."
		cd django-notes-application || {
			echo "Failed to move into django-notes-application directory."
			return 1
		}
		git pull || {
			echo "Failed to pull the latest changes."
			return 1
		}
	else
		echo "Cloning the Repository."
		git clone "https://github.com/Rayees1907/django-notes-application.git" || {
			echo "Failed to clone the Repository."
			return 1
		}
	fi
}

# Function to install required dependencies
install_requirements() {
    echo "Checking the requirements..."

    # ✅ Corrected condition — use command -v or docker --version properly
    if docker --version &> /dev/null; then
        echo "✅ Docker is already installed."
    else
        echo "🐳 Docker not found — installing Docker and requirements..."

        sudo apt-get update -y
        sudo apt-get install -y ca-certificates curl gnupg
        sudo install -m 0755 -d /etc/apt/keyrings
        sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
        sudo chmod a+r /etc/apt/keyrings/docker.asc

        # Add Docker repository to APT sources
        echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
          https://download.docker.com/linux/ubuntu \
          $(. /etc/os-release && echo ${UBUNTU_CODENAME:-$VERSION_CODENAME}) stable" | \
          sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

        sudo apt-get update -y

        # Install Docker packages
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

        echo "✅ Docker installation completed successfully."
        DOCKER_INSTALLED=true
        export DOCKER_INSTALLED
    fi
	# Install Nginx
    echo "🌐 Checking Nginx..."
    if command -v nginx &> /dev/null; then
        echo "✅ Nginx is already installed."
    else
        echo "📦 Installing Nginx..."
        sudo apt-get install -y nginx
        echo "✅ Nginx installation completed successfully."
        NGINX_INSTALLED=true
        export NGINX_INSTALLED
    fi
}

#Permissions for the docker
permissions() {
    echo "🔄 Performing required restarts..."
	if id -nG "$USER" | grep -qw "docker"; then
		echo "✅ User $USER is in the docker group."
	else
		sudo usermod -aG docker $USER || {
			echo "Failed to the user to a group."
		}
		echo "User added to a docker group, please restart to effect the changes."
    fi
}
#Required Restarts
required_restarts() {
	if [ "$DOCKER_INSTALLED" = true ]; then
        echo "Enabling and Restarting the Docker Services..."
        sudo systemctl enable docker
        sudo systemctl start docker
        sudo systemctl restart docker || {
            echo "Failed to start, enable, restart Docker......."
        }
    fi
    if [ "$NGINX_INSTALLED" = true ]; then
        echo "Enabling and Restarting the Nginx Services..."
        sudo systemctl enable nginx
        sudo systemctl start nginx
        sudo systemctl restart nginx || {
            echo "Failed to start, enable, restart Nginx......."
        }
    fi
}
#deployment
deploy() {
    echo "Deployment Started....."
    cd django-notes-application 2>/dev/null || {
        echo "Already in the directory"
    }
    docker compose up -d || {
        echo "Failed to start the container....."
    }
    echo "************* Process Ended *************"
}
code_clone
install_requirements
permissions	
required_restarts
deploy
