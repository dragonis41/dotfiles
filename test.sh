#!/bin/sh

# Check if there are any credentials added in git changes
FOUND_CREDENTIALS=$(git diff --staged --name-only --diff-filter=d -- | while IFS='' read -r file; do
  grep -Piw '\"?(?i)(accesskey|apikey|api_key|databasepassword|password|client_secret|sslcert|\w*key)\"?\s*[:-=]\s*[\w-]*' "$file"
done)

if [ ! -z "$FOUND_CREDENTIALS" ]; then
  printf "\n\e[31mERROR: Possible credentials detected!\e[0m\n"
  echo "$FOUND_CREDENTIALS"
  printf "\e[31mPlease remove credentials from the code before committing.\e[0m\n\n"
  exit 1
fi
