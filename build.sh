#! /bin/sh

. ./build

bench=public/bench.txt
bench_incr=public/bench-incremental.txt

echo "starting build $build_id"

# --- COLD BUILD ---
echo "build_id=$build_id" > $bench
echo "push_ts=$push_ts" >> $bench
echo "start_ts=$(date +%s)" >> $bench

node build.js

echo "end_ts=$(date +%s)" >> $bench

echo "=== Cold build results ==="
cat $bench

# --- INCREMENTAL BUILD ---
# Capture the moment incremental build phase begins (this becomes push_ts for incremental)
incremental_push_ts=$(date +%s.%N)

# For static-large, we modify a single file to test incremental deploy
# Check if the files directory exists (confirms cold build succeeded)
if [ -d "public/files" ]; then
    cache_exists="true"
    file_count=$(ls -1 public/files/*.html 2>/dev/null | wc -l || echo "0")
    echo "Static files found: $file_count HTML files"
else
    cache_exists="false"
    file_count="0"
    echo "WARNING: No files found in public/files - incremental build may not work!"
fi

# Modify ONLY one static file's content to test incremental deploy
# This simulates a single file change - no full rebuild needed
echo "<!-- Incremental build marker: ${build_id}-incr-$(date +%s) -->" >> public/files/index.html
echo "Modified public/files/index.html for incremental deploy test"

echo "build_id=$build_id" > $bench_incr
echo "push_ts=$incremental_push_ts" >> $bench_incr
echo "cache_exists=$cache_exists" >> $bench_incr
echo "file_count=$file_count" >> $bench_incr
echo "start_ts=$(date +%s)" >> $bench_incr

# No rebuild needed - the deployment platform will detect the single file change
# This tests how fast platforms can deploy when only 1 of 10,000 files changed

echo "end_ts=$(date +%s)" >> $bench_incr

echo "=== Incremental build results ==="
cat $bench_incr
