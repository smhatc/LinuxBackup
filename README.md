# 🐧 LinuxBackup

A personal repository containing a backup script to back up all my files from any Linux distribution onto an external storage medium.

Feel free to use, take inspiration from, or fork/clone this script and adjust it to your own backup strategy.

## Instructions

1. Clone the script to your computer or simply download and unzip it.

2. In your terminal, run `rsync --version` to check if you have `rsync` installed and install it if needed using your distribution's package manager.

3. After connecting your external drive, run `lsblk -o NAME,TYPE,SIZE,MOUNTPOINT` in your terminal to find its current mount point.

4. Edit `mount-points.txt` and place your external drive's mount point in it. Optionally place multiple mount points and add comments starting with `#` to describe them.

5. Edit `exclude.txt` to include only directories or files inside your source directory (home directory by default) which you do not want to back up, line-by-line. This file is entirely optional and can be deleted to simply back up everything in your source directory.

6. In your terminal, navigate (`cd`) into the directory you just cloned/downloaded. Give the script execute permissions using the `chmod +x ./backup.sh` command.

7. Finally, ensure you're in the correct directory and type `./backup.sh` in your terminal to run the script. By default, the script will back up your user's entire home directory minus any files/folders listed in the optional `exclude.txt` file. The source directory can be changed by changing the `file_backup_src` variable in the script.

## Useful Tips

Since manually navigating to the script directory before running it each time could get tiresome, consider adding an alias or function to your shell configuration file (e.g. `.bashrc`) similar to the following:

```
# Example shell function to quickly run the backup script
bkup() {
    local backup_dir="$HOME/Path/To/The/Script/Directory/LinuxBackup"
    local backup_script="backup.sh"
    [[ -x "${backup_dir}/${backup_script}" ]] && cd "$backup_dir" && ./"$backup_script"
}
```

## Usage Notes

1. The script depends on the `rsync` CLI program.

2. The script requires the `mount-points.txt` file, which should contain the mount point location of the external drive to back up to. The file can contain multiple mount points, line-by-line. The script will only consider mount points which are currently mounted. In case of multiple mounted drives, the script will ask the user which one to use. The file should be in the following format:

    ```
    # Optional clarifying comment starting with "#" ignored by the script
    /run/media/user/whatever
    /media/user/whatever
    /mnt/whatever
    ...
    ```

3. The `exclude.txt` file is optional and can be used to ignore certain files or directories in the source directory from the backup. This file allows for finer control and is useful for ignoring things such as development files, virtual machines, ISOs, etc., and should be in the following format if used:

    ```
    example_ignored_directory/
    example_ignored_file.txt
    *.log
    *.iso
    ...
    ```

4. By default, the script backs up the current user's entire home directory minus any files listed in `exclude.txt`. If you wish to narrow down the source directory to back up, adjust the `file_backup_src` variable in the script.

5. Finally, to explain the method of backup used by the script, it is an incremental backup. Any files present in the source directory (`file_backup_src`) will be mirrored over exactly to the backup directory (`file_backup_dir`). **This also means files deleted or overwritten in the source are deleted or overwritten in the destination**, but the script makes accidental deletions or overwrites safer by first archiving a copy of the old file before the mirrored copy of the file is deleted or overwritten. Archived files are stored in the `file_backup_arc` directory, and, due to this being an incremental backup, subsequent runs of the script will only copy over what has changed instead of everything, making it much more efficient than simply copy-pasting.

## Things to Avoid

`rsync` can exhibit unexpected behavior, such as copying over files which have not changed since its last run, if the source and destination filesystems are different (e.g. an `ext4` formatted Linux system as the source and a `NTFS` or `FAT` formatted external drive as the destination). While there are some ways to prevent this, they are not covered in the current iteration of this script. For best results, ensure source and destination filesystems are the same.
