#!/bin/sh
set -eu
container=savorly-storage-ci
data_dir=$(mktemp -d)
cleanup() { docker rm -f "$container" >/dev/null 2>&1 || true; }
trap cleanup EXIT
# A root-owned host folder models a fresh Unraid bind mount.
sudo chmod 755 "$data_dir"
sudo chown root:root "$data_dir"
sudo mkdir "$data_dir/.tailscale_state"
sudo chmod 700 "$data_dir/.tailscale_state"
start() {
  docker run -d --name "$container" --mount "type=bind,src=$data_dir,dst=/app/data" savorly:test >/dev/null
  attempts=0
  until docker exec "$container" wget -q -O /dev/null http://127.0.0.1:3000/api/config; do
    attempts=$((attempts + 1)); if [ "$attempts" -ge 30 ]; then docker logs "$container"; exit 1; fi
    sleep 1
  done
  docker exec "$container" sh -c 'test "$(awk '\''/^Uid:/{print $2}'\'' /proc/1/status)" = 1000'
  docker exec "$container" sh -c 'test "$(stat -c %u /app/data/.tailscale_state)" = 0; test "$(stat -c %a /app/data/.tailscale_state)" = 700'
}
start
docker exec "$container" node --input-type=module -e 'const s=await(await fetch("http://127.0.0.1:3000/api/state")).json();s.goals.calories=2345;const r=await fetch("http://127.0.0.1:3000/api/state",{method:"PUT",headers:{"Content-Type":"application/json"},body:JSON.stringify(s)});if(!r.ok)process.exit(1)'
docker rm -f "$container" >/dev/null
# Older files may have been created as root; startup must repair this one file.
sudo chown root:root "$data_dir/state.json"
sudo chmod 600 "$data_dir/state.json"
start
docker exec "$container" node --input-type=module -e 'const s=await(await fetch("http://127.0.0.1:3000/api/state")).json();if(s.goals.calories!==2345)process.exit(1)'
echo 'Bind-mounted appdata, recreation persistence, non-root app, and isolated Tailscale permissions passed.'
