# Database Tables

Busybox manages various database tables for different platforms and operations.

## Social Media Tables

### General
- **`socialmedia`** - General social media data and configurations

### Facebook
- **`fb_user`** - Facebook user profiles and authentication data
- **`fb_posts`** - Facebook posts queue for publishing
- **`fb_groups`** - Facebook groups list
- **`fb_group__metadata`** - Metadata for groups (settings, status, timestamps)
- **`fb_people`** - People database for network management
- **`fb_friends`** - Friends list and relationships
- **`fb_pages`** - Facebook pages management
- **`fb_page__metadata`** - Page metadata (settings, analytics)
- **`fb_plan`** - Scheduling plans for automated posting

### YouTube
- **`yo_user`** - YouTube user data and channel information

### Instagram
- **`in_user`** - Instagram user data and account settings

## Table Operations

All tables can be managed using the `--db` command:

```bash
# Show all tables
busy --db=show

# Show specific table
busy --db=show --table="database.table"

# Add record
busy --db=add --table="database.table" --data="field1,field2,field3"

# Update record
busy --db=update --table="database.table.record_id" --data="new_data"

# Drop table
busy --db=drop --table="database.table"
```

## Table Structure

Each table follows a consistent structure:
- **Primary Key**: Auto-incremented ID
- **Timestamps**: Created and updated timestamps
- **Status Fields**: Active/inactive, processed/pending
- **Data Fields**: Platform-specific content and metadata

## Best Practices

1. **Regular Backups**: Use database export tools to backup data
2. **Cleanup**: Remove processed records periodically to maintain performance
3. **Indexing**: Tables are automatically indexed for optimal query performance
4. **Security**: Database files are encrypted and stored locally

---

For usage examples, see [Usage Guide](usage.md) or the [main README](../README.md).
