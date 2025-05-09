#!/bin/bash

LOGFILE="$HOME/Downloads/apache_logs.txt" 

echo "==================== Apache Log Analysis ===================="
echo

# 1. Request Counts
echo ">> 1. Request Counts"
total_requests=$(wc -l < "$LOGFILE")
get_requests=$(grep '"GET' "$LOGFILE" | wc -l)
post_requests=$(grep '"POST' "$LOGFILE" | wc -l)
echo "Total requests: $total_requests"
echo "GET requests: $get_requests"
echo "POST requests: $post_requests"
echo

# 2. Unique IP Addresses
echo ">> 2. Unique IP Addresses"
unique_ips=$(awk '{print $1}' "$LOGFILE" | sort | uniq | wc -l)
echo "Unique IPs: $unique_ips"

echo "GET requests per IP:"
awk '$6 ~ /"GET/ {print $1}' "$LOGFILE" | sort | uniq -c | sort -nr | head -5

echo "POST requests per IP:"
awk '$6 ~ /"POST/ {print $1}' "$LOGFILE" | sort | uniq -c | sort -nr | head -5
echo

# 3. Failure Requests
echo ">> 3. Failure Requests (4xx and 5xx)"
failed_requests=$(awk '$9 ~ /^[45][0-9][0-9]$/' "$LOGFILE" | wc -l)
fail_percent=$(echo "scale=2; ($failed_requests/$total_requests)*100" | bc)
echo "Failed requests: $failed_requests"
echo "Failure percentage: $fail_percent%"
echo

# 4. Top User (Most Active IP)
echo ">> 4. Most Active IP"
awk '{print $1}' "$LOGFILE" | sort | uniq -c | sort -nr | head -1
echo

# 5. Daily Request Averages
echo ">> 5. Daily Request Average"
awk '{print $4}' "$LOGFILE" | cut -d: -f1 | tr -d '[' | sort | uniq -c | awk '{sum += $1; count++} END {print "Average requests per day:", sum/count}'
echo

# 6. Failure Analysis by Day
echo ">> 6. Days with Most Failures"
awk '$9 ~ /^[45]/ {print $4}' "$LOGFILE" | cut -d: -f1 | tr -d '[' | sort | uniq -c | sort -nr | head
echo

# Additional Insights
echo ">> Additional: Requests per Hour"
awk '{print $4}' "$LOGFILE" | cut -d: -f2 | sort | uniq -c | sort -n
echo

echo ">> Additional: Status Code Breakdown"
awk '{print $9}' "$LOGFILE" | sort | uniq -c | sort -nr
echo

echo ">> Additional: Most Active IP by Method"
echo "Top GET user:"
awk '$6 ~ /"GET/ {print $1}' "$LOGFILE" | sort | uniq -c | sort -nr | head -1
echo "Top POST user:"
awk '$6 ~ /"POST/ {print $1}' "$LOGFILE" | sort | uniq -c | sort -nr | head -1
echo

echo ">> Additional: Failure Patterns by Hour"
awk '$9 ~ /^[45]/ {print $4}' "$LOGFILE" | cut -d: -f2 | sort | uniq -c | sort -nr | head

echo
echo "====================== End of Report ======================="
