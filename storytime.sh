#!/bin/bash

# Check if TOKEN environment variable is set
if [ -z "$TOKEN" ]; then
  echo "Please export the 'TOKEN' environment variable with your Pivotal Tracker API token before running this script."
  exit 1
fi

# Check if PROJECT_ID environment variable is set
if [ -z "$PROJECT_ID" ]; then
  read -p "Enter the project ID: " PROJECT_ID
fi

# Check if PROJECT_ID environment variable is set
if [ -z "$PROJECT_ID" ]; then
  read -p "Enter the project ID: " PROJECT_ID
fi

read -p "Enter the story name: " STORY_NAME
read -p "Enter the story description: " STORY_DESCRIPTION

# Prompt for story_type and validate it
PS3="Select a story type: "
select STORY_TYPE in "feature" "bug" "chore"; do
  case $STORY_TYPE in
    "feature"|"bug"|"chore")
      break
      ;;
    *)
      echo "Invalid choice. Please select a valid story type."
      ;;
  esac
done

# Prompt for story_priority and validate it
PS3="Select a story priority: "
select STORY_PRIORITY in "p1" "p2" "p3"; do
  case $STORY_PRIORITY in
    "p1"|"p2"|"p3")
      break
      ;;
    *)
      echo "Invalid choice. Please select a valid story priority."
      ;;
  esac
done

# Construct the JSON payload
JSON_PAYLOAD=$(cat <<-END
{
  "kind": "story",
  "story_type": "$STORY_TYPE",
  "story_priority": "$STORY_PRIORITY",
  "name": "$STORY_NAME",
  "description": "$STORY_DESCRIPTION",
  "current_state": "planned",
  "project_id": $PROJECT_ID,
  "labels": [
    {
      "kind": "label",
      "name": "storytime"
    }
  ]
}
END
)

echo $JSON_PAYLOAD | jq

# # Send the curl request and capture the response
# RESPONSE=$(curl -X POST -H "X-TrackerToken: $TOKEN" -H "Content-Type: application/json" -d "$JSON_PAYLOAD" "https://www.pivotaltracker.com/services/v5/projects/$PROJECT_ID/stories")

# # Check if the request was successful
# if [ $? -eq 0 ]; then
#   STORY_ID=$(echo "$RESPONSE" | jq -r '.id')
#   STORY_URL=$(echo "$RESPONSE" | jq -r '.url')
#   echo "Story created successfully with ID: $STORY_ID"
#   echo "Story URL: $STORY_URL"
# else
#   echo "Error: Failed to create the story."
# fi

# Send the curl request and capture the HTTP response and response body
HTTP_RESPONSE=$(curl -X POST -w "%{http_code}" -H "X-TrackerToken: $TOKEN" -H "Content-Type: application/json" -d "$JSON_PAYLOAD" -o response.json "https://www.pivotaltracker.com/services/v5/projects/$PROJECT_ID/stories")

# Check if the HTTP response code is in the 200 range to determine success
if [ "$HTTP_RESPONSE" -ge 200 ] && [ "$HTTP_RESPONSE" -lt 300 ]; then
  STORY_URL=$(jq -r '.url' response.json)
  echo "Story created successfully with HTTP code: $HTTP_RESPONSE"
  echo "Story URL: $STORY_URL"
else
  echo "Error: Failed to create the story. HTTP code: $HTTP_RESPONSE"
fi

# Clean up the response file
rm -f response.json