# loginNotifier
A script that checks your journalctl every certain time and run a notifier when matches certains message.

## Install
1. Make sure the watcher and notifier scripts are executable:
   ```bash
   chmod +x notifier.sh notify/*.sh
   ```
2. (Optional) Edit or replace the notifier scripts in `notify/` to match your preferred
   notification channels (for example, integrate Telegram or email).

## Usage
### Show session openings in the terminal
The watcher accepts 3 parameters: action (`opened`),  notification (`terminal`) and optionally, the elapseTime (`10`):
```bash
./notifier.sh opened terminal 10
```

### Run in the background
Leave it running in the background and log output to a file:
```bash
nohup ./notifier.sh opened terminal 10 > notifier.log 2>&1 &
```

## Notifier Parameters and Configuration

### Overview
The `notifier.sh` script accepts three parameters to control its behavior:

### Parameters

#### 1. Action (Required)
- **Parameter:** First positional argument (`$1`)
- **Type:** String
- **Description:** The session event keyword to match in journalctl logs
- **Examples:** `opened`, `closed`, `login`, `logout`
- **Usage:** This value is used to filter relevant journal entries and is passed to the notifier script

#### 2. Notifier Type (Required)
- **Parameter:** Second positional argument (`$2`)
- **Type:** String (case-insensitive)
- **Description:** The type of notification handler to use. Corresponds to a script file in the `notify/` directory
- **Examples:** `terminal`, `telegram`, `mail`, `slack`, `webhook`
- **Behavior:** The script will look for `notify/<notifier-type-lowercase>.sh` and execute it
- **Error Handling:** If the notifier script doesn't exist or isn't executable, the script will exit with an error

#### 3. Poll Interval (Optional)
- **Parameter:** Third positional argument (`$3`)
- **Type:** Positive integer (seconds)
- **Default:** `10` seconds
- **Description:** Cooldown interval between consecutive notifications to prevent spam
- **Validation:** Must be a positive integer; non-numeric or zero/negative values will cause the script to exit with an error
- **Example:** Use `60` for 1-minute intervals between notifications

### Parameter Examples

```bash
# Basic usage: monitor for "opened" sessions and notify via terminal
./notifier.sh opened terminal

# With custom poll interval (30-second cooldown)
./notifier.sh opened telegram 30

# Monitor for closed sessions with email notifications and 60-second interval
./notifier.sh closed mail 60
```

### Creating Custom Notifier Scripts

Each notifier script in the `notify/` directory must follow a specific interface:

#### Requirements

1. **File Naming:** Must be named `{type}.sh` (lowercase)
2. **Executable:** Must have execute permissions (`chmod +x`)
3. **Required Function:** Must define a `build_message` function
4. **Parameters:** Must accept three parameters:
   - `$1` - Action (e.g., "opened", "closed")
   - `$2` - Username of the user triggering the event
   - `$3` - The full journal line entry

#### Script Template

```bash
#!/usr/bin/env bash
# Description: My custom notifier script

# build_message: Returns a formatted message string
# Parameters: $1=action, $2=user, $3=journal_line
build_message() {
  local action="$1"
  local user="$2"
  local line="$3"
  echo "Login Event: User '$user' session $action"
}

# Main notification handler (optional)
# This function is called with the same three parameters
# Add your notification logic here (send email, call API, etc.)
main() {
  local action="$1"
  local user="$2"
  local line="$3"
  
  # Example: Send notification
  # mail -s "Session $action for $user" admin@example.com
}

main "$@"
```

### Configuration: Excluded Users

The script has a hardcoded list of excluded users to prevent notifications for system accounts:

```bash
EXCLUDED_USERS=("root" "debian")
```

Users in this list will not trigger notifications. To customize excluded users, edit the `notifier.sh` script and modify the `EXCLUDED_USERS` array.

### Configuration: Custom Message Building

Each notifier script must implement the `build_message` function. This function:
- Receives the action, username, and journal line
- Returns a formatted message string
- Is called before the notifier is executed, allowing preview of the notification

### Troubleshooting Configuration

#### "journalctl access denied"
If you see this error:
```
journalctl access denied.
Run with sudo or add the user to the adm group to read auth logs.
```

**Solutions:**
- Run with `sudo`: `sudo ./notifier.sh opened terminal`
- Add your user to the `adm` group: `sudo usermod -aG adm $USER` (then log out and back in)

#### "Notify script not found or not executable"
Ensure your notifier script:
1. Exists in the `notify/` directory
2. Is executable: `chmod +x notify/your-notifier.sh`
3. Has the exact filename matching the notifier type (case-insensitive)

#### "Notify script does not define build_message"
Make sure your custom notifier script includes:
```bash
build_message() {
  # Your implementation here
}
```

## Debian notes
If you run the script as a regular user and `journalctl` access is denied, run it with
`sudo` or add your user to the `adm` group.