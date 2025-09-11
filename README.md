# 🐧 LinuxBackup

A personal repository containing a backup script to back up all my files from any Linux distribution onto an external storage medium.

Feel free to take inspiration from this script or fork/clone and adjust it to your own backup strategy.

## 📌 Currently Tested Distributions

-   Fedora Workstation.

## 📋 Usage Notes

### While the script is mostly self-documenting, below is a clarification of its current behavior and runtime assumptions:

1. The script depends on the `rsync` CLI program being installed, which should be available to download from any Linux distribution's package manager.

2. The script assumes that there is a directory called `My Files` stored in the current user's home directory containing all the files needed to be backed up. If this is not true, change the value of the `file_backup_src` variable to the location of your files, ensuring they all share this one root directory.

3. The script assumes the backup location (`file_backup_dir`) and backup archive location (`file_backup_arc`) to be an external drive.

4. The script assumes the external drive to be mounted at a very specific location (`/run/media/your-username/the-drive-uuid`). This is the location some Linux distributions mount drives. If this is not true for your distribution, please adjust the value of the `drive_path` variable accordingly.

5. The UUID and mount point of the external drive can be found through the `lsblk -o NAME,MOUNTPOINT,UUID` command. Then, for the script to correctly read the UUID, it should be stored in another file called `configuration.txt` in the format `external_hdd_uuid="the-drive-uuid-here"`. The `configuration.txt` file should be in the same directory as the backup script.

6. Finally, to explain the method of backup used by the script, it is an incremental backup. Any files present in the source directory (`file_backup_src`) will be mirrored over exactly to the backup directory (`file_backup_dir`). **This also means files deleted or overwritten in the source are deleted or overwritten in the destination**, but the script makes accidental deletions or overwrites safer by first archiving a copy of the old file before the mirrored copy of the file is deleted or overwritten. Archived files are stored in the `file_backup_arc` directory, and, due to this being an incremental backup, subsequent runs of the script will only copy over what has changed instead of everything, making it much more efficient than simply copy-pasting.

### Things to avoid when using the script:

1. `rsync` can exhibit unexpected behavior, such as copying over files which have not changed since its last run, if the source and destination filesystems are different (e.g. an `ext4` formatted Linux system as the source and a `NTFS` or `FAT` formatted external drive as the destination). While there are some ways to prevent this, they are not covered in the current iteration of this script. For best results, ensure source and destination filesystems are the same.

## 💻 Run Instructions

1. Clone the script to your computer or simply download and unzip it.

2. Open your terminal and navigate (`cd`) into the directory you just cloned/downloaded.

3. Ensure the source, destination, and archive directories listed in the `backup.sh` file are okay for your setup or adjust them as needed.

4. If you are using an external drive as your backup destination (the script assumes this by default) and your distribution mounts these drives in a location based on their UUID, create a `configuration.txt` file in the same directory and insert your drive's UUID there in the format discussed in the Usage Notes section.

5. Give the script execute permissions using the command `chmod +x ./backup.sh`.

6. Run the script by typing `./backup.sh` into your terminal, ensuring that you are still inside the project directory you cloned/downloaded first.
