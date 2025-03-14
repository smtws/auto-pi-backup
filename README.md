# Auto Pi Backup

**Small script to automate backing up a Raspberry Pi's filesystem to a NAS mount.**

---

## Overview
This script automates the process of backing up a Raspberry Pi's filesystem to a NAS mount. It uses `image-backup` from the [RonR-RPi-image-utils](https://github.com/seamusdemora/RonR-RPi-image-utils) repository to create incremental and full backups. The script also includes features like automatic cleanup of old backups and handling of NAS mount/unmount operations.

---

## Key Features
- **Incremental Backups**: Uses `image-backup` to only back up changes since the last backup, saving time and storage.
- **Automatic Cleanup**: Deletes backups older than 4 weeks to free up space.
- **Full Backup Every Week**: Creates a full backup every 7 days for redundancy.
- **Auto Mount/Unmount**: Automatically mounts the NAS share before backup and unmounts it afterward.
- **Cron Job Integration**: Designed to run as a daily cron job for hands-free operation.

---

## Setup

### 1. Clone the Repository
```bash
git clone https://github.com/smtws/auto-pi-backup.git
cd auto-pi-backup
```

### 2. Install `image-backup`
This script relies on `image-backup` from the [RonR-RPi-image-utils](https://github.com/seamusdemora/RonR-RPi-image-utils) repository. Install it by following the instructions in the repository.

### 3. Configure the Script
Edit the script (`backup.sh`) and update the following variables at the top of the file:

```bash
# Configuration
NAS_MOUNT="/mnt/backup"  # Local mount point for the NAS
NAS_SHARE="YOUR_NAS_IP:/path/to/your/share"  # NAS IP and share path
```

### 4. Make the Script Executable and move it, and clean up
Run the following command to make the script executable:
```bash
chmod +x backup.sh
chown root:root backup.sh
sudo mv backup.sh /usr/sbin/backup.sh
cd ..
rm -rf auto-pi-backup
```

### 5. Set Up Cron Job
Add a daily cron job to run the script automatically. Edit the crontab:

```bash
sudo crontab -e
```

Add the following line to run the script daily at 2 AM:

```bash
0 2 * * * /usr/sbin/backup.sh
```

### 5. Test the Script
Run the script manually to ensure everything works:

```bash
sudo /usr/sbin/backup.sh
```
#### Do not interrupt it, it will take several minutes and it does NOT handle SIGTERM or SIGKILL gracefully 

Check the log file (`/var/log/backup.log`) for any errors or issues.

---

## How It Works
1. **Mount NAS**: The script mounts the NAS share to the specified mount point.
2. **Check Backup Age**: If the last backup is older than 7 days, it renames the old backup and creates a new full backup.
3. **Incremental Backup**: If a backup already exists, the script uses `image-backup` to perform an incremental backup.
4. **Cleanup**: Backups older than 4 weeks are automatically deleted.
5. **Unmount NAS**: After the backup completes, the script unmounts the NAS share.

---

## Dependencies
- **`image-backup`**: This script relies on `image-backup` from the [RonR-RPi-image-utils](https://github.com/seamusdemora/RonR-RPi-image-utils) repository. Make sure to install it before using this script.

---

## License
This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for details.

---

## Disclaimer
This script is provided **"as-is," without any warranties or guarantees** of any kind, either express or implied. The author disclaims all liability for any damages, losses, or issues arising from the use of this script. Use at your own risk.

---

## Contributing
Contributions are welcome! If you find any issues or have suggestions for improvements, please open an issue or submit a pull request.

---

## Support
If you find this script useful, consider giving it a ⭐ on GitHub! For questions or issues, please open an issue in the repository.

---
