#!/bin/bash

# Function to run a test case and check the output
run_test() {
    description="$1"
    command="$2"
    expected_output="$3"

    echo -n "Test: $description... "

    output=$(eval "$command" 2>&1)

    if [ "$output" = "$expected_output" ]; then
        echo "Passed"
    else
        echo "Failed"
        echo "Expected Output: $expected_output"
        echo "Actual Output: $output"
    fi
}

# Define the tests in YAML format
tests_yaml="
- description: Help Message
  command: 'tmcpkg -h'
  expected_output: 'usage:\n   tmcpkg [subcommand] [options]\n\nsubcommands:\n create -f <config-file-path>\n update -f <configfile-path>\n delete  -f <config-file-path> \n list  -f <config-file-path>\n get  -f <config-file-path>\n\nglobal options:\n   default config environment variable: TMCPCK_CONFIG:  <file-path>  #'
- description: Create Success
  command: 'tmcpkg create -f path/to/config'
  expected_output: 'Tanzu tmc package install create -f path/to/config'
- description: Create Failure (File not found)
  command: 'tmcpkg create -f non_existent_config'
  expected_output: 'file not found'
- description: Update Success
  command: 'tmcpkg update -f path/to/config'
  expected_output: 'Tanzu tmc package install update -f path/to/config'
- description: Update Failure (File not found)
  command: 'tmcpkg update -f non_existent_config'
  expected_output: 'file not found'
- description: Delete Success
  command: 'tmcpkg delete -f path/to/config'
  expected_output: 'Tanzu tmc package install delete -f path/to/config'
- description: Delete Failure (File not found)
  command: 'tmcpkg delete -f non_existent_config'
  expected_output: 'file not found'
- description: List Success
  command: 'tmcpkg list -f path/to/config'
  expected_output: 'Tanzu tmc package install list -f path/to/config'
- description: List Failure (File not found)
  command: 'tmcpkg list -f non_existent_config'
  expected_output: 'file not found'
- description: Get Success
  command: 'tmcpkg get -f path/to/config'
  expected_output: 'Tanzu tmc package install get -f path/to/config'
- description: Get Failure (File not found)
  command: 'tmcpkg get -f non_existent_config'
  expected_output: 'file not found'
"

# Use yq to parse the YAML and run the tests
echo "$tests_yaml" | yq -r '.[] | "\(.description)|\(.command)|\(.expected_output)"' | while IFS='|' read -r description command expected_output; do
    run_test "$description" "$command" "$expected_output"
done

echo "All tests completed."
