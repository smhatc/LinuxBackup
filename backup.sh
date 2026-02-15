#!/usr/bin/env bash

##################################
### DEFINING GENERAL VARIABLES ###
##################################

# Output formatting variables
process_icon=" >"
error_icon="(!)"
success_icon="(√)"
line_separator="--------------------------------------------------"

# Path to the mandatory file containing list of external drive mount points line-by-line
mount_points_file="./mount-points.txt"

# Path to an optional file containing list of files/folders to exclude from the backup line-by-line
exclude_file="./exclude.txt"

##############################################
### CHOOSING MOUNT POINT TO USE FOR BACKUP ###
##############################################

# Check if mount points file exists and is readable
if [[ ! -f "$mount_points_file" ]]; then
    echo "${error_icon} The mandatory mount points file was not found at \"${mount_points_file}\"."
    exit
elif [[ ! -r "$mount_points_file" ]]; then
    echo "${error_icon} The mandatory mount points file was found but is not readable (insufficient permissions)."
    exit
fi

# Variable to track which mount points from the external file are currently mounted
mounted=()

# The external drive mount point to use for the backup
drive_path=""

# Read all potential mount points from config (comments starting with # in config file are ignored)
mapfile -t possible_mountpoints < <(grep -v '^\s*#' "$mount_points_file" | grep -v '^\s*$')

# Check which mount points are mounted and set drive_path. If multiple are mounted the user is asked to choose
for path in "${possible_mountpoints[@]}"; do
    [[ -d "$path" ]] && mounted+=("$path")
done

if [[ "${#mounted[@]}" -eq 0 ]]; then
    echo "${error_icon} None of the configured mount points are mounted."
    exit
elif [[ "${#mounted[@]}" -eq 1 ]]; then
    drive_path="${mounted[0]}"
else
    echo "${process_icon} Multiple mounted drives found. Please choose one to use for the backup destination:"
    select choice in "${mounted[@]}"; do
        if [[ -n "$choice" ]]; then
            drive_path="$choice"
            echo "${success_icon} Using mounted drive at \"${drive_path}\" as the backup destination." && echo "$line_separator"
            break
        else
            echo "${error_icon} Invalid selection. Try again."
        fi
    done
fi

##############################################
### USING OPTIONAL EXCLUDE FILE IF PRESENT ###
##############################################

# Check if exclude file exists and is readable before using it (silent on fail since it is optional)
if [[ -r "$exclude_file" ]]; then
    echo "${process_icon} An exclude file has been detected. Applying exclude list..."
    exclude_opt="--exclude-from=${exclude_file}"
    echo "${success_icon} Applied exclude list successfully." && echo "$line_separator"
else
    exclude_opt=""
fi

#######################
### BACKUP SETTINGS ###
#######################

# Current date in a specific format for the archiving functionality
current_date="$(date +%Y-%m-%d_%H-%M-%S)"

# Path of the files to back up
file_backup_src="$HOME"

# Path (assuming external drive) to back up the files to
file_backup_dir="${drive_path}/$HOSTNAME/Current Backup"

# Path (assuming external drive) to archive deleted or overwritten files to
file_backup_arc="${drive_path}/$HOSTNAME/Backup Archive"

###########################################
### SANITY CHECKS BEFORE RUNNING BACKUP ###
###########################################

# Ensure source directory exists and is readable
if [[ ! -d "$file_backup_src" ]]; then
    echo "${error_icon} Source directory does not exist at \"${file_backup_src}\"."
    exit
elif [[ ! -r "$file_backup_src" ]]; then
    echo "${error_icon} Source directory exists but is not readable (insufficient permissions)."
    exit
fi

# Ensure backup destination directory exists and is writable
if [[ ! -d "$file_backup_dir" ]]; then
    echo "${process_icon} Creating backup destination directory at \"${file_backup_dir}\"..."
    mkdir -p "$file_backup_dir" && echo "${success_icon} Backup destination directory has been created." && echo "$line_separator"
elif [[ ! -w "$file_backup_dir" ]]; then
    echo "${error_icon} Destination directory exists but is not writable (insufficient permissions)."
    exit
fi

# Ensure backup archive directory exists and is writable
if [[ ! -d "$file_backup_arc" ]]; then
    echo "${process_icon} Creating backup archive directory at \"${file_backup_arc}\"..."
    mkdir -p "$file_backup_arc" && echo "${success_icon} Backup archive directory has been created." && echo "$line_separator"
elif [[ ! -w "$file_backup_arc" ]]; then
    echo "${error_icon} Archive directory exists but is not writable (insufficient permissions)."
    exit
fi

######################
### RUN THE BACKUP ###
######################

# Use rsync to perform the backup
echo "${process_icon} Starting backup..."
rsync -avhPb $exclude_opt \
    --backup-dir "${file_backup_arc}/${current_date}" \
    --delete \
    "${file_backup_src}" \
    "${file_backup_dir}" &&
    echo "${success_icon} Backup completed successfully on ${current_date}."
