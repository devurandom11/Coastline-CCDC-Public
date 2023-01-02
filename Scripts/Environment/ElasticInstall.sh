#! /bin/bash

# Check if user has sudo permissions
if [[ $(id -u) -ne 0 ]]; then
    echo "This script must be run with sudo privileges. Please use 'sudo' to run this script."
    exit
fi

echo 'Importing GPG Key...'

curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | gpg --dearmor -o /usr/share/keyrings/elastic.gpg

echo 'Success'

echo 'Adding Sources...'

echo "deb [signed-by=/usr/share/keyrings/elastic.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-8.x.list

echo 'Success'

echo 'Updating'

apt update && apt install elasticsearch

echo 'Done. Configure with:'

echo '''sudo vim /etc/elasticsearch/elasticsearch.yml'''

exit
