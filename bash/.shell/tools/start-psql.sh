#!/usr/bin/env zsh
DATABASE_PATH=$HOME/database

psql() {
  # Find a running postgres:18 container from table output
  local cid
  cid=$(container ls | awk 'NR>1 && /postgres:18/ && /running/ {print $1; exit}')

  if [[ -n "$cid" ]]; then
    # Already running → behave like native psql
    echo "🔗 Connecting to existing container: $cid"
    container exec -it "$cid" psql "$@"
  else
    # Start new instance from DATABASE_PATH
    echo "🚀 Starting new Postgres container..."
    cd "$DATABASE_PATH" || { echo "❌ Could not cd to $DATABASE_PATH"; return 1; }

    if [[ ! -f ./psql.sh ]]; then
      echo "❌ No ./psql.sh found in $DATABASE_PATH"
      return 1
    fi

    # Start container
    ./psql.sh || { echo "❌ Failed to execute psql.sh"; return 1; }

    # Wait for container to be ready
    echo "⏳ Waiting for container to start..."
    sleep 3

    # Get new container ID
    cid=$(container ls | awk 'NR>1 && /postgres:18/ && /running/ {print $1; exit}')

    if [[ -n "$cid" ]]; then
      local addr
      addr=$(container ls | awk -v id="$cid" '$1 == id {print $NF}')
      echo "✅ Postgres started (Container: $cid, IP: ${addr:-unknown})"

      # Wait a bit more for postgres to be ready
      sleep 2

      # Execute psql with user-provided args
      container exec -it "$cid" psql "$@"
    else
      echo "❌ Failed to find started Postgres container."
      return 1
    fi
  fi
}
