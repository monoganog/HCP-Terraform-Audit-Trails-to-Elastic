#!/bin/bash

# DISCLAIMER:
# This script is provided "as is" without warranty of any kind, express or implied.
# The user assumes all risks associated with using or modifying this script. 
# The author is not liable for any damages or issues that may arise from using this script.
# Use at your own discretion.

# Variables
# Terraform Org Token, see here for details: https://developer.hashicorp.com/terraform/cloud-docs/users-teams-organizations/api-tokens#organization-api-tokens
TERRAFORM_API_TOKEN="${TERRAFORM_API_TOKEN:?Please set the Terraform API Token}"
# Set this with your Elastic search Endpoint. (e.g., https://my-deployment-1c95a5.es.uksouth.azure.elastic-cloud.com:9243)
ELASTIC_URL="${ELASTIC_URL:?Please set the Elastic URL (e.g., https://my-deployment-1c99a4.es.uksouth.azure.elastic-cloud.com:9243)}"
# Set with your Elastic Cloud username. For permissions needed see: https://developer.hashicorp.com/hcp/docs/vault/logs-metrics/elasticsearch/logs#create-role
ELASTIC_USER="${ELASTIC_USER:?Please set the Elastic User}"
# Set with your Elastic Cloud password
ELASTIC_PASSWORD="${ELASTIC_PASSWORD:?Please set the Elastic Password}"

INDEX_URL="$ELASTIC_URL/terraform-audit-trails/_doc"
API_URL="https://app.terraform.io/api/v2/organization/audit-trail"

# Calculate SINCE_DATE to be one hour ago in ISO8601 format with milliseconds (macOS)
SINCE_DATE=$(date -u -v -1H +"%Y-%m-%dT%H:%M:%S.000Z")

echo "Fetching data from Terraform Audit Trails API since $SINCE_DATE..."

# Fetch audit trail data
RESPONSE=$(curl --silent --header "Authorization: Bearer $TERRAFORM_API_TOKEN" --request GET "$API_URL?&since=$SINCE_DATE")

# Error handling for API response
if [ -z "$RESPONSE" ]; then
  echo "No data returned from the Terraform API."
  exit 1
fi

if echo "$RESPONSE" | jq -e '.errors?' >/dev/null; then
  echo "Error fetching data from Terraform API:"
  echo "$RESPONSE" | jq '.errors'
  exit 1
fi

# Parse and ingest data into Elastic Cloud
echo "$RESPONSE" | jq -c '.data[]' | while read -r event; do
  EVENT_ID=$(echo "$event" | jq -r '.id')

  # Send each event to Elastic Cloud with retry logic
  echo "Ingesting event $EVENT_ID into Elasticsearch..."
  curl -s --retry 3 --retry-delay 5 -X POST "$INDEX_URL/$EVENT_ID" \
       -H "Content-Type: application/json" \
       -u "$ELASTIC_USER:$ELASTIC_PASSWORD" \
       -d "$event"
done

echo "Ingestion completed."
