#!/bin/bash

### SCRIPT INSTALL SCRIPT
### TESTED WITH DEBIAN ONLY

. /Legends-Of-Azeroth-548-Auto-Installer/configs/root-config

if [ ! -f ./configs/root-config ]; then
    echo "Config file not found! Add configs!"
    exit;
fi

if [ -z "$INSTALL_PATH" ]; then
    echo "Install path config option missing?!"
    exit;
fi

if [ "$1" = "" ]; then
echo ""
echo "## No option selected, see list below"
echo ""
echo "- [all] : Run Full Script"
echo ""
((NUM++)); echo "- [$NUM] : Install Prerequisites" 
((NUM++)); echo "- [$NUM] : Update Script permissions"
((NUM++)); echo "- [$NUM] : Update Script permissions"
((NUM++)); echo "- [$NUM] : Install Mysql Apt"
((NUM++)); echo "- [$NUM] : Randomize Passwords"
((NUM++)); echo "- [$NUM] : Setup Commands"
((NUM++)); echo "- [$NUM] : Final Message"
echo ""

else

### LETS START
echo ""
echo "##########################################################"
echo "## INIT SCRIPT STARTING...."
echo "##########################################################"
echo ""
export DEBIAN_FRONTEND=noninteractive


((NUM++))
if [ "$1" = "all" ] || [ "$1" = "$NUM" ]; then
echo ""
echo "##########################################################"
echo "## $NUM.Install Prerequisites"
echo "##########################################################"
echo ""
sudo apt install curl p7zip-full dos2unix gnupg screen --assume-yes
sudo apt autoremove --assume-yes
fi


((NUM++))
if [ "$1" = "all" ] || [ "$1" = "$NUM" ]; then
echo ""
echo "##########################################################"
echo "## $NUM.Update permissions"
echo "##########################################################"
echo ""
sudo find /Legends-Of-Azeroth-548-Auto-Installer/ -type d -name ".git" -prune -o -type f -exec dos2unix {} \;
sudo chmod -R 777 /Legends-Of-Azeroth-548-Auto-Installer/
cd /Legends-Of-Azeroth-548-Auto-Installer/scripts/Setup/
fi


((NUM++))
if [ "$1" = "all" ] || [ "$1" = "$NUM" ]; then
echo ""
echo "##########################################################"
echo "## $NUM. Install MySQL Apt"
echo "##########################################################"
echo ""

# Define the path for the MySQL APT configuration file
MYSQL_APT_CONFIG="/root/mysql-apt-config_all.deb"

# Check if the file already exists
if [ ! -f "$MYSQL_APT_CONFIG" ]; then
    echo "Downloading MySQL APT Config..."
    wget https://dev.mysql.com/get/mysql-apt-config_0.8.14-1_all.deb -O "$MYSQL_APT_CONFIG"
    
    # Install the downloaded package
    DEBIAN_FRONTEND=noninteractive dpkg -i "$MYSQL_APT_CONFIG"
    
    # Update package list
    sudo apt update -y
else
    echo "MySQL APT Config already downloaded at $MYSQL_APT_CONFIG. Skipping download."
fi
fi

((NUM++))
if [ "$1" = "all" ] || [ "$1" = "$NUM" ]; then
echo ""
echo "##########################################################"
echo "## $NUM.Randomize Passwords"
echo "##########################################################"
echo ""
replace_randomizepass() 
{
    local files="$1"         # File pattern to search for (e.g., *.txt)
    local min_length="${2:-12}"     # Minimum length of the password; default is 12
    local max_length="${3:-16}"     # Maximum length of the password; default is 16

    # Loop through the files matching the pattern
    for file in $files; do
        if [[ -f "$file" ]]; then   # Check if it's a file
            while IFS= read -r line; do
                # Replace "RANDOMIZEPASS" with a new random password
                echo "${line//password123/$(generate_random_password $min_length $max_length)}"
            done < "$file" > "$file.tmp"  # Write the output to a temp file
            mv "$file.tmp" "$file"        # Overwrite the original file
            echo "Processed: $file"
        fi
    done
}
generate_random_password() 
{
    local length=$((RANDOM % (max_length - min_length + 1) + min_length))
    # Use /dev/urandom for generating a random password
    tr -dc 'A-Za-z0-9' < /dev/urandom | head -c "$length"
}
if [ "$RANDOMIZE_PASSWORDS" = "true" ]; then
    replace_randomizepass "/Legends-Of-Azeroth-548-Auto-Installer/configs/*"  # Example: replace in all .txt files
else
    echo "Password randomiztion disabled, the default password is password123"
    echo ""
    if [ "$REMOTE_DB_SETUP" = "true" ]; then
        echo "Its highly recommended to change the remote MYSQL user password as it will be public."
        echo "YOU HAVE BEEN WARNED!"
        echo ""
        while true; do
            read -p "Do you want to change the password? (y/n): " yn
            if [[ "$yn" =~ ^[Yy]$ ]]; then
                read -sp "Enter the new password: " NEW_PASSWORD
                echo ""  # New line after password input
                CONFIG_FILE="/Legends-Of-Azeroth-548-Auto-Installer/configs/root-config"  # Define the config file path
                
                if [[ -f "$CONFIG_FILE" ]]; then
                    sed -i "s|REMOTE_DB_PASS=\"password123\"|REMOTE_DB_PASS=\"$NEW_PASSWORD\"|" "$CONFIG_FILE" && echo "Password updated successfully in $CONFIG_FILE."
                    remote_db_update="true"
                else
                    echo "Error: Configuration file does not exist."
                fi
                break  # Exit the loop after successful update
            elif [[ "$yn" =~ ^[Nn]$ ]]; then
                echo "Operation cancelled."
                break  # Exit the loop if the operation is cancelled
            else
                echo "Invalid input. Please enter 'y' for yes or 'n' for no."
            fi
        done
    fi
fi
fi


((NUM++))
if [ "$1" = "all" ] || [ "$1" = "$NUM" ]; then
echo ""
echo "##########################################################"
echo "## $NUM. Setup Commands"
echo "##########################################################"
echo ""

HEADER="#### CUSTOM ALIAS"
FOOTER="#### END CUSTOM ALIAS"

# Remove content between the header and footer, including the markers
sed -i "/$HEADER/,/$FOOTER/d" ~/.bashrc
if ! grep -Fxq "$HEADER" ~/.bashrc; then
    echo -e "\n$HEADER\n" >> ~/.bashrc
    echo "Custom command header added"
else
    echo "Custom command header already found."
fi

# Add new commands between the header and footer
echo -e "\n## CUSTOM COMMANDS LIST" >> ~/.bashrc

# Function to list all available commands
echo "commands() {" >> ~/.bashrc
echo "  echo -e '-------------------------------------------------------'" >> ~/.bashrc
echo "  echo -e '\n## Run Commands'" >> ~/.bashrc
echo "  echo -e '-------------------------------------------------------'" >> ~/.bashrc
echo "  echo -e 'runall: Run all installation steps'" >> ~/.bashrc
echo "  echo -e 'runinit: Run the initial installation script'" >> ~/.bashrc
echo "  echo -e 'runroot: Run the root installation script'" >> ~/.bashrc
echo "  echo -e 'runauth: Run the authentication installation script'" >> ~/.bashrc
echo "  echo -e 'rundev: Run the realm development installation script'" >> ~/.bashrc
echo "  echo -e '-------------------------------------------------------'" >> ~/.bashrc
echo "  echo -e '\n## Update Commands'" >> ~/.bashrc
echo "  echo -e '-------------------------------------------------------'" >> ~/.bashrc
echo "  echo -e 'updateall: Update all components'" >> ~/.bashrc
echo "  echo -e 'updateinstaller: Update the Legends installer'" >> ~/.bashrc
echo "  echo -e 'updateroot: Update the root installation'" >> ~/.bashrc
echo "  echo -e 'updateauth: Update the authentication installation'" >> ~/.bashrc
echo "  echo -e 'updatedev: Update the realm development installation'" >> ~/.bashrc
echo "  echo -e '-------------------------------------------------------'" >> ~/.bashrc
echo "  echo -e '\n## Screen Commands'" >> ~/.bashrc
echo "  echo -e '-------------------------------------------------------'" >> ~/.bashrc
echo "  echo -e 'screenauth: Attach to the authentication screen session'" >> ~/.bashrc
echo "  echo -e 'screendev: Attach to the realm development screen session'" >> ~/.bashrc
echo "  echo -e '-------------------------------------------------------'" >> ~/.bashrc
echo "  echo -e '\n## Start Commands'" >> ~/.bashrc
echo "  echo -e '-------------------------------------------------------'" >> ~/.bashrc
echo "  echo -e 'startall: Start all services'" >> ~/.bashrc
echo "  echo -e 'startauth: Start the authentication service'" >> ~/.bashrc
echo "  echo -e 'startdev: Start the realm development service'" >> ~/.bashrc
echo "  echo -e '-------------------------------------------------------'" >> ~/.bashrc
echo "  echo -e '\n## Stop Commands'" >> ~/.bashrc
echo "  echo -e '-------------------------------------------------------'" >> ~/.bashrc
echo "  echo -e 'stopall: Stop all services'" >> ~/.bashrc
echo "  echo -e 'stopauth: Stop the authentication service'" >> ~/.bashrc
echo "  echo -e 'stopdev: Stop the realm development service'" >> ~/.bashrc
echo "  echo -e '-------------------------------------------------------'" >> ~/.bashrc
echo "  echo -e '\n## Restart Commands'" >> ~/.bashrc
echo "  echo -e '-------------------------------------------------------'" >> ~/.bashrc
echo "  echo -e 'restartall: Restart all services'" >> ~/.bashrc
echo "  echo -e 'restartauth: Restart the authentication service'" >> ~/.bashrc
echo "  echo -e 'restartdev: Restart the realm development service'" >> ~/.bashrc
echo "  echo -e '-------------------------------------------------------'" >> ~/.bashrc
echo "  echo -e '\n## Config Commands'" >> ~/.bashrc
echo "  echo -e '-------------------------------------------------------'" >> ~/.bashrc
echo "  echo -e 'configroot: Edit the root configuration'" >> ~/.bashrc
echo "  echo -e 'configauth: Edit the authentication configuration'" >> ~/.bashrc
echo "  echo -e 'configdev: Edit the realm development configuration'" >> ~/.bashrc
echo "}" >> ~/.bashrc

# Function to list all run-related commands
echo "commandsrun() {" >> ~/.bashrc
echo "  echo -e '-------------------------------------------------------'" >> ~/.bashrc
echo "  echo -e '\n## Run Commands'" >> ~/.bashrc
echo "  echo -e '-------------------------------------------------------'" >> ~/.bashrc
echo "  echo -e 'runall: Run all installation steps'" >> ~/.bashrc
echo "  echo -e 'runinit: Run the initial installation script'" >> ~/.bashrc
echo "  echo -e 'runroot: Run the root installation script'" >> ~/.bashrc
echo "  echo -e 'runauth: Run the authentication installation script'" >> ~/.bashrc
echo "  echo -e 'rundev: Run the realm development installation script'" >> ~/.bashrc
echo "}" >> ~/.bashrc

# Function to list all update-related commands
echo "commandsupdate() {" >> ~/.bashrc
echo "  echo -e '-------------------------------------------------------'" >> ~/.bashrc
echo "  echo -e '\n## Update Commands'" >> ~/.bashrc
echo "  echo -e '-------------------------------------------------------'" >> ~/.bashrc
echo "  echo -e 'updateall: Update all components'" >> ~/.bashrc
echo "  echo -e 'updateinstaller: Update the Legends installer'" >> ~/.bashrc
echo "  echo -e 'updateroot: Update the root installation'" >> ~/.bashrc
echo "  echo -e 'updateauth: Update the authentication installation'" >> ~/.bashrc
echo "  echo -e 'updatedev: Update the realm development installation'" >> ~/.bashrc
echo "}" >> ~/.bashrc

# Function to list all screen-related commands
echo "commandscreen() {" >> ~/.bashrc
echo "  echo -e '-------------------------------------------------------'" >> ~/.bashrc
echo "  echo -e '\n## Screen Commands'" >> ~/.bashrc
echo "  echo -e '-------------------------------------------------------'" >> ~/.bashrc
echo "  echo -e 'screenauth: Attach to the authentication screen session'" >> ~/.bashrc
echo "  echo -e 'screendev: Attach to the realm development screen session'" >> ~/.bashrc
echo "}" >> ~/.bashrc

# Function to list all start-related commands
echo "commandsstart() {" >> ~/.bashrc
echo "  echo -e '-------------------------------------------------------'" >> ~/.bashrc
echo "  echo -e '\n## Start Commands'" >> ~/.bashrc
echo "  echo -e '-------------------------------------------------------'" >> ~/.bashrc
echo "  echo -e 'startall: Start all services'" >> ~/.bashrc
echo "  echo -e 'startauth: Start the authentication service'" >> ~/.bashrc
echo "  echo -e 'startdev: Start the realm development service'" >> ~/.bashrc
echo "}" >> ~/.bashrc

# Function to list all stop-related commands
echo "commandsstop() {" >> ~/.bashrc
echo "  echo -e '-------------------------------------------------------'" >> ~/.bashrc
echo "  echo -e '\n## Stop Commands'" >> ~/.bashrc
echo "  echo -e '-------------------------------------------------------'" >> ~/.bashrc
echo "  echo -e 'stopall: Stop all services'" >> ~/.bashrc
echo "  echo -e 'stopauth: Stop the authentication service'" >> ~/.bashrc
echo "  echo -e 'stopdev: Stop the realm development service'" >> ~/.bashrc
echo "}" >> ~/.bashrc

# Function to list all restart-related commands
echo "commandsrestart() {" >> ~/.bashrc
echo "  echo -e '-------------------------------------------------------'" >> ~/.bashrc
echo "  echo -e '\n## Restart Commands'" >> ~/.bashrc
echo "  echo -e '-------------------------------------------------------'" >> ~/.bashrc
echo "  echo -e 'restartall: Restart all services'" >> ~/.bashrc
echo "  echo -e 'restartauth: Restart the authentication service'" >> ~/.bashrc
echo "  echo -e 'restartdev: Restart the realm development service'" >> ~/.bashrc
echo "}" >> ~/.bashrc

# Function to list all config-related commands
echo "commandsconfig() {" >> ~/.bashrc
echo "  echo -e '-------------------------------------------------------'" >> ~/.bashrc
echo "  echo -e '\n## Config Commands'" >> ~/.bashrc
echo "  echo -e '-------------------------------------------------------'" >> ~/.bashrc
echo "  echo -e 'configroot: Edit the root configuration'" >> ~/.bashrc
echo "  echo -e 'configauth: Edit the authentication configuration'" >> ~/.bashrc
echo "  echo -e 'configdev: Edit the realm development configuration'" >> ~/.bashrc
echo "}" >> ~/.bashrc

echo -e "\n## RUN" >> ~/.bashrc
echo "alias runall='runinit && runroot && runauth && rundev'" >> ~/.bashrc
echo "alias runinit='cd /Legends-Of-Azeroth-548-Auto-Installer/ && ./Init.sh all && cd -'" >> ~/.bashrc
echo "alias runroot='cd /Legends-Of-Azeroth-548-Auto-Installer/scripts/Setup/ && ./Root-Install.sh all && cd -'" >> ~/.bashrc
echo "alias runauth='source /Legends-Of-Azeroth-548-Auto-Installer/configs/auth-config && su - \$SETUP_AUTH_USER -c \"cd /Legends-Of-Azeroth-548-Auto-Installer/scripts/Setup/ && ./Auth-Install.sh all && cd -\"'" >> ~/.bashrc
echo "alias rundev='source /Legends-Of-Azeroth-548-Auto-Installer/configs/realm-dev-config su - \$SETUP_REALM_USER -c \"cd /Legends-Of-Azeroth-548-Auto-Installer/scripts/Setup/ && ./Realm-Dev-Install.sh all && cd -\"'" >> ~/.bashrc

echo -e "\n## UPDATE" >> ~/.bashrc
echo "alias updateall='updateinstaller && updateroot && updateauth && updatedev'" >> ~/.bashrc
echo "updateinstaller() {" >> ~/.bashrc
echo "  cd /" >> ~/.bashrc
echo "  if [ -d /configs ]; then" >> ~/.bashrc
echo "    rm -rf /configs" >> ~/.bashrc
echo "  fi" >> ~/.bashrc
echo "  if [ -d /Legends-Of-Azeroth-548-Auto-Installer/configs ]; then" >> ~/.bashrc
echo "    mv -f /Legends-Of-Azeroth-548-Auto-Installer/configs /" >> ~/.bashrc
echo "  else" >> ~/.bashrc
echo "    echo 'Configs directory does not exist, skipping move.'" >> ~/.bashrc
echo "  fi" >> ~/.bashrc
echo "  rm -rf /Legends-Of-Azeroth-548-Auto-Installer" >> ~/.bashrc
echo "  apt-get install git sudo -y" >> ~/.bashrc
echo "  git clone https://github.com/CableguyWoW/Legends-Of-Azeroth-548-Auto-Installer /Legends-Of-Azeroth-548-Auto-Installer" >> ~/.bashrc
echo "  if [ -d /configs ]; then" >> ~/.bashrc
echo "    cp -rf /configs/* /Legends-Of-Azeroth-548-Auto-Installer/configs/" >> ~/.bashrc
echo "  fi" >> ~/.bashrc
echo "  chmod +x /Legends-Of-Azeroth-548-Auto-Installer/Init.sh" >> ~/.bashrc
echo "  /Legends-Of-Azeroth-548-Auto-Installer/Init.sh all" >> ~/.bashrc
echo "}" >> ~/.bashrc
echo "alias updateroot='cd /Legends-Of-Azeroth-548-Auto-Installer/scripts/Setup/ && ./Root-Install.sh update && cd -'" >> ~/.bashrc
echo "alias updateauth='source /Legends-Of-Azeroth-548-Auto-Installer/configs/auth-config && su - \$SETUP_AUTH_USER -c \"cd /Legends-Of-Azeroth-548-Auto-Installer/scripts/Setup/ && ./Auth-Install.sh update && cd -\"'" >> ~/.bashrc
echo "alias updatedev='source /Legends-Of-Azeroth-548-Auto-Installer/configs/realm-dev-config && su - \$SETUP_REALM_USER -c \"cd /Legends-Of-Azeroth-548-Auto-Installer/scripts/Setup/ && ./Realm-Dev-Install.sh update && cd -\"'" >> ~/.bashrc

echo -e "\n## SCREEN" >> ~/.bashrc
echo "alias screenauth='source /Legends-Of-Azeroth-548-Auto-Installer/configs/auth-config && su - \$SETUP_AUTH_USER -c \"screen -d -r \$SETUP_AUTH_USER\"'" >> ~/.bashrc
echo "alias screendev='source /Legends-Of-Azeroth-548-Auto-Installer/configs/realm-dev-config && su - \$SETUP_REALM_USER -c \"screen -d -r \$SETUP_REALM_USER\"'" >> ~/.bashrc

echo -e "\n## START" >> ~/.bashrc
echo "alias startall='startauth && startdev'" >> ~/.bashrc
echo "alias startauth='source /Legends-Of-Azeroth-548-Auto-Installer/configs/auth-config && su - \$SETUP_AUTH_USER -c \"cd /Legends-Of-Azeroth-548-Auto-Installer/scripts/Setup/ && ./Auth-Install.sh start && cd -\"'" >> ~/.bashrc
echo "alias startdev='source /Legends-Of-Azeroth-548-Auto-Installer/configs/realm-dev-config && su - \$SETUP_REALM_USER -c \"cd /Legends-Of-Azeroth-548-Auto-Installer/scripts/Setup/ && ./Realm-Dev-Install.sh start && cd -\"'" >> ~/.bashrc

echo -e "\n## STOP" >> ~/.bashrc
echo "alias stopall='stopauth && stopdev'" >> ~/.bashrc
echo "alias stopauth='source /Legends-Of-Azeroth-548-Auto-Installer/configs/auth-config && su - \$SETUP_AUTH_USER -c \"cd /Legends-Of-Azeroth-548-Auto-Installer/scripts/Setup/ && ./Auth-Install.sh stop && cd -\"'" >> ~/.bashrc
echo "alias stopdev='source /Legends-Of-Azeroth-548-Auto-Installer/configs/realm-dev-config && su - \$SETUP_REALM_USER -c \"cd /Legends-Of-Azeroth-548-Auto-Installer/scripts/Setup/ && ./Realm-Dev-Install.sh stop && cd -\"'" >> ~/.bashrc

echo -e "\n## RESTART" >> ~/.bashrc
echo "alias restartall='restartauth && restartdev'" >> ~/.bashrc
echo "alias restartauth='stopauth && startauth'" >> ~/.bashrc
echo "alias restartdev='stopdev && startdev'" >> ~/.bashrc

echo -e "\n## CONFIG" >> ~/.bashrc
echo "alias configroot='sudo nano /Legends-Of-Azeroth-548-Auto-Installer/configs/root-config'" >> ~/.bashrc
echo "alias configauth='sudo nano /Legends-Of-Azeroth-548-Auto-Installer/configs/auth-config'" >> ~/.bashrc
echo "alias configdev='sudo nano /Legends-Of-Azeroth-548-Auto-Installer/configs/realm-dev-config'" >> ~/.bashrc

echo "Added script alias to bashrc"

if ! grep -Fxq "$FOOTER" ~/.bashrc; then
    echo -e "\n$FOOTER\n" >> ~/.bashrc
    echo "Script footer added."
fi

# Source .bashrc to apply changes
dos2unix ~/.bashrc > /dev/null 2>&1
. ~/.bashrc > /dev/null 2>&1
source ~/.bashrc > /dev/null 2>&1

# Setup Crontab
crontab -r > /dev/null 2>&1
crontab -l | { cat; echo "############## MISC SCRIPTS ##############"; } | crontab -
crontab -l | { cat; echo "@reboot screen -dmS bashrc /Legends-Of-Azeroth-548-Auto-Installer/scripts/Restarter/bashrc.sh"; } | crontab -
screen -S bashrc -X quit
screen -dmS bashrc /Legends-Of-Azeroth-548-Auto-Installer/scripts/Restarter/bashrc.sh
echo "Root Crontab has been setup"
fi


((NUM++))
if [ "$1" = "all" ] || [ "$1" = "$NUM" ]; then
echo ""
echo "##########################################################"
echo "## $NUM.Final Message"
echo "##########################################################"
echo ""
echo "All passwords are stored in - /Legends-Of-Azeroth-548-Auto-Installer/configs/"
if [ "$RANDOMIZE_PASSWORDS" = "true" ]; then
    echo "The default passwords setup is : password123"
fi
if [ "$remote_db_update" = "true" ]; then
    echo "The REMOTE_DB_PASS has been updated to the users inputted password."
fi
echo ""
echo -e "\e[32m↓↓↓ Next - Run the following ↓↓↓\e[0m"
echo ""
echo -e "\e[32m→→→→→\e[0m source ~/.bashrc && runroot"
echo ""
echo "##########################################################"
echo ""
fi

echo ""
echo "##########################################################"
echo "INIT FINISHED"
echo "##########################################################"
echo ""

fi