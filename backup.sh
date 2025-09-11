#!/bin/bash

# Output formatting variables
process_icon=" >"
error_icon="(!)"
success_icon="(√)"
line_separator="--------------------------------------------------"

# Check configuration file exists
config_file="./configuration.txt"

if [[ ! -f "$config_file" ]]; then
    echo "${error_icon} Configuration file not found at \"${config_file}\"."
    exit
fi

# Read all potential mount points from config (comments starting with # in config file are ignored)
mapfile -t possible_mountpoints < <(grep -v '^\s*#' "$config_file" | grep -v '^\s*$')

# Check which mount points are mounted and set drive_path. If multiple are mounted the user is asked to choose
mounted=()
drive_path=""
for path in "${possible_mountpoints[@]}"; do
    [[ -d "$path" ]] && mounted+=("$path")
done

if [[ ${#mounted[@]} -eq 0 ]]; then
    echo "${error_icon} None of the configured mount points are mounted."
    exit
elif [[ ${#mounted[@]} -eq 1 ]]; then
    echo "${process_icon} Setting the mounted drive to use for the backup destination..."
    drive_path="${mounted[0]}"
    echo "${success_icon} Using mounted drive at \"${drive_path}\" as the backup destination."
else
    echo "${process_icon} Multiple mounted drives found. Please select one:"
    select choice in "${mounted[@]}"; do
        if [[ -n "$choice" ]]; then
            drive_path="$choice"
            echo "${success_icon} Using mounted drive at \"${drive_path}\" as the backup destination."
            break
        else
            echo "${error_icon} Invalid selection. Try again."
        fi
    done
fi

echo "$line_separator"

# Backup settings
current_date=$(date +%Y-%m-%d_%H-%M-%S) # Current date in a specific format for the archiving functionality
file_backup_src="$HOME/My Files" # Path of the files to back up
file_backup_dir="${drive_path}/$HOSTNAME/Current Backup" # Path (assuming external drive) to back up the files to
file_backup_arc="${drive_path}/$HOSTNAME/Backup Archive" # Path (assuming external drive) to archive deleted or overwritten files to

# Ensure the source directory exists
if [[ ! -d "$file_backup_src" ]]; then
    echo "${error_icon} Source directory does not exist at \"${file_backup_src}\"."
    exit
fi

# Ensure backup destination directory exists
if [[ ! -d "$file_backup_dir" ]]; then
    echo "${process_icon} Creating backup destination directory at \"${file_backup_dir}\"..."
    mkdir -p "$file_backup_dir" && echo "${success_icon} Backup destination directory has been created." && echo "$line_separator"
fi

# Ensure backup archive directory exists
if [[ ! -d "$file_backup_arc" ]]; then
    echo "${process_icon} Creating backup archive directory at \"${file_backup_arc}\"..."
    mkdir -p "$file_backup_arc" && echo "${success_icon} Backup archive directory has been created." && echo "$line_separator"
fi

# Perform backup
echo "${process_icon} Starting backup..."
rsync -avhPb --backup-dir "${file_backup_arc}/${current_date}" --delete "${file_backup_src}" "${file_backup_dir}" && echo "${success_icon} Backup completed successfully on ${current_date}."
