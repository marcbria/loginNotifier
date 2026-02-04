# loginNotifier
A script that reads your auth logs and runs a notifier when somebody logs in.

## Install
1. Make sure the watcher and notifier scripts are executable:
   ```bash
   chmod +x notifier.sh notify/*.sh
   ```
2. (Optional) Edit or replace the notifier scripts in `notify/` to match your preferred
   notification channels (for example, integrate Telegram or email).

## Usage
### Show session openings in the terminal
Run the watcher accepts 3 parameters: action (`opened`),  notification (`terminal`) and checktime (`10`):
```bash
./notifier.sh opened terminal 10
```
The last parameter is optional and indicates time in seconds (defaults is 10
seconds).

### Run in the background
Leave it running in the background and log output to a file:
```bash
nohup ./notifier.sh opened terminal 10 > notifier.log 2>&1 &
```

## Debian notes
If you run the script as a regular user and `journalctl` access is denied, run it with
`sudo` or add your user to the `adm` group.
