#!/bin/bash
#
# Shell Script to setup daps
# Author: truzzt GmbH
# Copyright 2023

# Define the omejdn contents
omejdn_contents=$(cat <<EOL
plugins:
  user_db:
    yaml:
      location: config/users.yml
  claim_mapper:
    attribute:
      skip_access_token: false
      skip_id_token: true
  api:
    admin_v1: 
    user_selfservice_v1:
      allow_deletion: false
      allow_password_change: true
      editable_attributes: []
user_backend_default: yaml
environment: production
issuer: 
front_url: 
bind_to: 0.0.0.0:4567
openid: true
default_audience: idsc:IDS_CONNECTORS_ALL
accept_audience: idsc:IDS_CONNECTORS_ALL
access_token:
  expiration: 3600
  algorithm: RS256
id_token:
  expiration: 3600
  algorithm: RS256
EOL
)

# Define the omejdn-plugins contents
omejdn_plugins_contents=$(cat <<EOL
plugins:
  token_user_attributes:
    skip_id_token: true
EOL
)

# Define the scope_description contents
scope_description_contents=$(cat <<EOL
---
omejdn:read: Read access to the Omejdn server API
omejdn:write: Write access to the Omejdn server API
omejdn:admin: Access to the Omejdn server admin API
profile: 'Standard profile claims (e.g.: Name, picture, website, gender, birthdate,
  location)'
email: Email-Address
address: Address
phone: Phone-number
EOL
)

# Define the scope_mapping contents
scope_mapping_contents=$(cat <<EOL
---
idsc:IDS_CONNECTOR_ATTRIBUTES_ALL:
- securityProfile
- referringConnector
- "@type"
- "@context"
- transportCertsSha256
EOL
)

# Define the users contents
users_contents=$(cat <<EOL
---
- username: admin
  attributes:
  - key: omejdn
    value: admin
  password: "\$2a\$12\$3NVyFBT4Biqhd9D5IokNFuL78NH8pvR/Ir48Ci6FlA8yKuLZuzqFa"
  backend: yaml
EOL
)

# Define the webfinger contents
webfinger_contents=$(cat <<EOL
--- {}
EOL
)

folder="config"

# Check if the folder exists
if [ ! -d "$folder" ]; then
    echo "Folder $folder does not exist. Creating..."
    
    # Create the folder
    mkdir "$folder"
    
    echo "Folder created: $folder"
else
    echo "Folder $folder already exists."
fi

files=("config/omejdn.yml" "config/omejdn-plugins.yml" "config/scope_description.yml" "config/scope_mapping.yml" "config/users.yml" "config/webfinger.yml")

for file in "${files[@]}"; do
    # Check if the file exists
    if [ ! -f "$file" ]; then
        echo "File $file does not exist. Creating..."
        
        # Create the file with different content based on filename
        case "$file" in
            "config/omejdn.yml")
                echo "$omejdn_contents" >> "$file"
                ;;
            "config/omejdn-plugins.yml")
                echo "$omejdn_plugins_contents" >> "$file"
                ;;
            "config/scope_description.yml")
                echo "$scope_description_contents" >> "$file"
                ;;
            "config/scope_mapping.yml")
                echo "$scope_mapping_contents" >> "$file"
                ;;
            "config/users.yml")
                echo "$users_contents" >> "$file"
                ;;
            "config/webfinger.yml")
                echo "$omejdn_webfinger_contents" >> "$file"
                ;;
            *)
                echo "Unknown file: $file"
                ;;
        esac
        
        echo "File created: $file"
    else
        echo "File $file already exists."
    fi
done

ruby omejdn.rb
