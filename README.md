# Terraform Audit Trails to Elastic Ingestion Script

This script fetches audit trail data from Terraform Cloud's Audit Trails API and ingests it into an Elasticsearch instance, such as Elastic Cloud. It’s useful for centralizing and analyzing audit logs in Elastic.

## Disclaimer
This script is provided "as is" without warranty of any kind, express or implied. The user assumes all risks associated with using or modifying this script. The author is not liable for any damages or issues that may arise from using this script. **Use at your own discretion.**

## Features
- Fetches audit trail data from Terraform Cloud for the past hour.
- Ingests data into an Elasticsearch index for easy search and analysis in Kibana.

## Prerequisites
- **jq**: This script requires `jq` to parse JSON data. Install it on macOS with:
  ```bash
  brew install jq
  ```
- **Terraform Cloud API Token**: Generate an API token in Terraform Cloud under **User Settings > API Tokens**.

## Setup Instructions

### 1. Set Required Environment Variables
The script uses the following environment variables. Set these in your shell session or add them to your shell profile (e.g., `~/.bashrc` or `~/.zshrc`).

```bash
export TERRAFORM_API_TOKEN="your-terraform-api-token"
export ELASTIC_URL="https://your-elastic-instance-url:9243"  # Include the :9243 port
export ELASTIC_USER="your-elastic-username"
export ELASTIC_PASSWORD="your-elastic-password"
```

### 2. Run the Script
To execute the script, run the following command in your terminal:

```bash
./fetch_audit_trail_elastic.sh
```

The script will retrieve audit trails from the past hour, parse them, and ingest them into your specified Elasticsearch instance.

## Automating with Cron to Run Hourly
To automatically fetch and ingest audit logs every hour, set up a cron job. This will run the script at the start of every hour, pulling the latest audit data from Terraform.

1. Open the crontab editor:
   ```bash
   crontab -e
   ```

2. Add a new cron entry to execute the script every hour:
   ```bash
   0 * * * * /path/to/fetch_audit_trail_elastic.sh
   ```
   - Replace `/path/to/fetch_audit_trail_elastic.sh` with the full path to your script.

3. Save and exit. The script will now run automatically each hour, fetching and ingesting the last hour’s Terraform audit trails into Elastic.

## Troubleshooting
- **No data in Elastic**: Ensure the `TERRAFORM_API_TOKEN` and `ELASTIC_URL` variables are set correctly and accessible to the script.

## Additional Notes
Consider reviewing the script periodically to ensure it matches your organization's security and compliance requirements, particularly if it's accessing sensitive logs.