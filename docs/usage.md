# Usage Guide

## Basic Syntax

```bash
busy [--option=value]... [:place]
```

or

```bash
busy [sub_command] [--option=value]... [:place]
```

## Command Examples

### Social Media Operations

**Like a post:**
```bash
busy --like="https://socialportal.com/fanpage/post" :0
```

**Follow a profile:**
```bash
busy --follow="https://socialportal.com/profile" :2
```

**Share content:**
```bash
busy --share="https://example.com" --url="https://socialportal.com/group_name" :1
```

**Comment on a post:**
```bash
busy --comment="Great content!" --url="socialportal.com/groups/example/post/123456"
```

**Join a group:**
```bash
busy --join="https://socialportal.com/group_name" :1
```

### Content Publishing

**Publish a post:**
```bash
busy --post="database.table.record" :5
```
> Posts are fetched from database. Without value, uses oldest post from default table.

**Subscribe to a channel:**
```bash
busy --subscribe="https://example.com" :1
```

### Live Streaming

**Start streaming:**
```bash
busy --live=start --url="rtmp://live-api.platform.com:80/api=1&key=YOUR_KEY" :0
```

**Stop streaming:**
```bash
busy --live=stop :0
```

**Check stream status:**
```bash
busy --live=status :0
```

### Database Operations

**Show all tables:**
```bash
busy --db=show
```

**Show table records:**
```bash
busy --db=show --table="database.table"
```

**Add record:**
```bash
busy --db=add --table="database.table" --data="field1,field2,field3"
```

**Update record:**
```bash
busy --db=update --table="database.table.record_id" --data="new_data"
```

**Drop table:**
```bash
busy --db=drop --table="database.table"
```

### System Operations

**Clear clipboard:**
```bash
busy --clip-clear
# or
busy -cc
```

**Restart display:**
```bash
busy --restart :5        # restart DISPLAY:5
busy --restart=all       # restart all displays
```

**Screen management:**
```bash
busy --screen=status                    # show screen sessions
busy --screen=on --cmd="htop"          # run htop in screen
```

**Cron management:**
```bash
busy --cron=on           # enable cron
busy --cron=off          # disable cron
busy --cron=status       # check cron status
```

### Authentication

**Login to a portal:**
```bash
busy --login --url="https://socialportal.com" :1
```

## Update System

Update Busybox components:

```bash
update --full              # Update all files
update --binaries          # Update binary files only
update --busy              # Update busy executable
update --cron_task         # Update cron tasks
update --logrotate         # Update log rotation config
update --tint2rc           # Update tint2 configuration
update --openbox           # Update OpenBox config
update [path/]file         # Update specific file
update -h                  # Display help
```

## Remote Access

Access your Busybox instance via SSH:

```bash
ssh 192.168.1.23 -p 22
su busybox
```

---

For more details, see the [main README](../README.md) or visit the [Wiki](https://github.com/busy4me/busybox/wiki).
