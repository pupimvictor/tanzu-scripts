#!/bin/bash

# Check if TOKEN environment variable is set
check_token() {
  if [ -z "$TOKEN" ]; then
    echo "Please export the 'TOKEN' environment variable with your Pivotal Tracker API token before running this script."
    exit 1
  fi
}

# Prompt for the project ID or use the one from the environment
get_project_id() {
  if [ -z "$PROJECT_ID" ]; then
    read -p "Enter the project ID: " PROJECT_ID
  fi
}

# Prompt for user input and validate choices
prompt_user_input() {
  read -p "Enter the story name: " STORY_NAME
  read -p "Enter the story description: " STORY_DESCRIPTION

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
}

# Create and send the HTTP request, capturing the response code and URL
send_http_request() {
  local JSON_PAYLOAD
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

  local HTTP_RESPONSE
  HTTP_RESPONSE=$(curl -# -X POST -w "%{http_code}" -H "X-TrackerToken: $TOKEN" -H "Content-Type: application/json" -d "$JSON_PAYLOAD" -o response.json "https://www.pivotaltracker.com/services/v5/projects/$PROJECT_ID/stories")

  if [ "$HTTP_RESPONSE" -ge 200 ] && [ "$HTTP_RESPONSE" -lt 300 ]; then
    local STORY_URL
    STORY_URL=$(jq -r '.url' response.json)
    echo "Story created successfully with HTTP code: $HTTP_RESPONSE"
    echo "Story URL: $STORY_URL"
  else
    echo "Error: Failed to create the story. HTTP code: $HTTP_RESPONSE"
  fi

  # Clean up the response file
  rm -f response.json
}

# Main script flow
main() {
  check_token
  get_project_id
  prompt_user_input
  send_http_request
}

# Run the script
main
