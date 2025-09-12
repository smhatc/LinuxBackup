# 🐧 LinuxBackup

A personal repository containing a backup script to back up all my files from any Linux distribution onto an external storage medium.

Feel free to use, take inspiration from, or fork/clone this script and adjust it to your own backup strategy.

## 📋 Usage Notes

### While the script is mostly self-documenting, below is a clarification of its current behavior and runtime assumptions:

1. The script depends on the `rsync` CLI program being installed, which should be available to download from any Linux distribution's package manager.

2. The script requires a mandatory external text file in the same directory as the script called `mount-points.txt` containing the mount point location of the external drive to back up to. The file can contain multiple mount points, one per line, which is useful in case of distro hopping, different systems using different distributions, or using multiple external drives for the backup. The script will only consider mount points which are currently mounted, and ignore all others. The file should be in the following format:

    ```
    # Optional clarifying comment starting with "#" ignored by the script
    /run/media/user/whatever
    /media/user/whatever
    /mnt/whatever
    ...
    ```

3. By default, the script assumes the existence of a directory called `My Files` in the current user's home directory to act as the source directory to back up, and will fail if it does not find it. If your file organization structure is different, either create this directory in your home directory, placing all of your files and directories inside it, or simply adjust the value of the `file_backup_src` variable in the script to contain the full path to your root source directory, ensuring all other files and directories you want to back up are inside of it.

4. Optionally, the script also allows for the creation of an external text file in the same directory called `exclude.txt` which allows users to specify any directories or files inside the source directory which they wish to ignore and exclude from the backup, one per line. This is completely optional and the script will run just fine without it, but it allows for finer control and is useful for things such as development files, throwaway virtual machines, and operating system ISOs among other things. The file should be in the following format:

    ```
    example_ignored_directory/
    example_ignored_file.txt
    *.log
    *.iso
    ...
    ```

5. Finally, to explain the method of backup used by the script, it is an incremental backup. Any files present in the source directory (`file_backup_src`) will be mirrored over exactly to the backup directory (`file_backup_dir`). **This also means files deleted or overwritten in the source are deleted or overwritten in the destination**, but the script makes accidental deletions or overwrites safer by first archiving a copy of the old file before the mirrored copy of the file is deleted or overwritten. Archived files are stored in the `file_backup_arc` directory, and, due to this being an incremental backup, subsequent runs of the script will only copy over what has changed instead of everything, making it much more efficient than simply copy-pasting.

### Things to avoid when using the script:

1. `rsync` can exhibit unexpected behavior, such as copying over files which have not changed since its last run, if the source and destination filesystems are different (e.g. an `ext4` formatted Linux system as the source and a `NTFS` or `FAT` formatted external drive as the destination). While there are some ways to prevent this, they are not covered in the current iteration of this script. For best results, ensure source and destination filesystems are the same.

## 💻 Run Instructions

1. Clone the script to your computer or simply download and unzip it.

2. Check if you have `rsync` installed and install it if needed.

3. After connecting your external drive, find its current mount point through the following command (different distributions mount drives in different locations):

    `lsblk -o NAME,TYPE,SIZE,MOUNTPOINT`

    Pay attention to the type and size columns to help you identify the external drive.

4. Open your terminal and navigate (`cd`) into the directory you just cloned/downloaded.

5. Run the command `touch mount-points.txt` to create the mandatory mount points configuration file and place your external drive's mount point in it. Refer to the Usage Notes section for more information about this file.

6. Ensure the paths of the `file_backup_src` (source directory of the files to back up), `file_backup_dir` (the destination to back up to), and `file_backup_arc` (the destination to archive deleted or overwritten backup files to) variables listed in the script are correct for your file organization structure and adjust them as needed. Refer to the Usage Notes section for more information about the behavior of the script and what these variables mean.

7. Optionally create the `exclude.txt` file in case there are directories or files inside your source directory which you do not want to back up. Refer to the Usage Notes section for more information about this file.

8. In your terminal, give the script execute permissions using the command `chmod +x ./backup.sh`.

9. Run the script by typing `./backup.sh` into your terminal, ensuring that you are still inside the project directory you cloned/downloaded first.
