#!/bin/bash
sudo yum install net-tools -y

# Run netstat and grep for mysqld
netstat_output=$(netstat -tlpn | grep mysqld)

# Check if there are any matching lines
if [ -n "$netstat_output" ]; then
    # Use awk to extract the port number
    mysql_port=$(echo "$netstat_output" | awk '{split($4, a, ":"); print a[length(a)]}')
    echo "MySQL is running on port $mysql_port"
else
    echo "MySQL is not running"
fi

# Define the root directory to search for wp-config.php
root_dir="/var/www/html"

# Function to extract database configuration from wp-config.php
extract_db_config() {
    local config_file="$1"
    local db_name=$(grep -oP "(?<=DB_NAME', ')([^']+)" "$config_file")
    local db_user=$(grep -oP "(?<=DB_USER', ')([^']+)" "$config_file")
    local db_password=$(grep -oP "(?<=DB_PASSWORD', ')([^']+)" "$config_file")
    local db_host=$(grep -oP "(?<=DB_HOST', ')([^']+)" "$config_file")

    echo "Database Name: $db_name"
    echo "Database User: $db_user"
    echo "Database Password: $db_password"
    echo "Database Host: $db_host"
}

# Function to connect to the database and retrieve post titles and content
retrieve_posts() {
    local db_name="$1"
    local db_user="$2"
    local db_password="$3"
    local db_host="$4"

    # Use the retrieved database configuration to connect to the database
    # mysql -h "$db_host" -u "$db_user" -p"$db_password" -D "$db_name" -e "SELECT post_title, post_content FROM wp_posts WHERE post_type = 'post';"
}

# Find all wp-config.php files and process them
find "$root_dir" -type f -name "wp-config.php" | while read config_file; do
    echo "Found wp-config.php: $config_file"
    echo "Extracting database configuration..."
    extract_db_config "$config_file"

    # Connect to the database and retrieve posts
    echo "Connecting to the database..."
    retrieve_posts "$db_name" "$db_user" "$db_password" "$db_host"
done

