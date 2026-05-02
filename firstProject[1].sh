#!/bin/sh

# --------------------------------
# Check usage
# --------------------------------
if [ "$#" -ne 1 ]; then
    echo "Usage: ./script.sh schedule.txt"
    exit 1
fi

filename="$1"

if [ ! -f "$filename" ]; then
    echo "Error: file not found!"
    exit 1
fi

# --------------------------------
# Variables
# --------------------------------
total_teaching_min=0
total_OH_min=0
day_count=0
days_list=""

task5_valid=1
task6_valid=1
task7_valid=1
task8_valid=1

# --------------------------------
# Convert hh(:mm) to minutes
# --------------------------------
to_minutes() {
    hour=$(echo "$1" | cut -d':' -f1)
    min=$(echo "$1" | cut -s -d':' -f2)
    [ -z "$min" ] && min=0
    echo $(( hour*60 + min ))
}

# --------------------------------
# Read file (Tasks 1,2,5,8)
# --------------------------------
while read line; do
 [ -z "$line" ] && continue

    day=$(echo "$line" | cut -d'|' -f1)
    activities=$(echo "$line" | cut -d'|' -f2 | tr -d ' ')

    # Task 8: Validate allowed teaching days
    case "$day" in
        S|M|T|W|Th) ;;
        *)
            echo "Invalid day: $day"
            task8_valid=0
            continue
            ;;
    esac

    # Task 5: Count distinct teaching days
    if ! echo "$days_list" | grep -q "$day"; then
        day_count=$(( day_count + 1 ))
        days_list="$days_list $day"
    fi

    # Process activities
    for act in $(echo "$activities" | tr ';' ' ')
    do
        [ -z "$act" ] && continue

        interval=$(echo "$act" | grep -o "\[[^]]*\]" | tr -d '[]')
        code=$(echo "$act" | sed "s/.*\]//")

        start=$(echo "$interval" | cut -d'-' -f1)
        end=$(echo "$interval" | cut -d'-' -f2)

        start_min=$(to_minutes "$start")
        end_min=$(to_minutes "$end")

        # Fix cases like 12-1
        if [ "$end_min" -lt "$start_min" ]; then
            end_min=$(( end_min + 720 ))
        fi

        duration=$(( end_min - start_min ))

        if [ "$code" = "OH" ]; then
            total_OH_min=$(( total_OH_min + duration ))
        else
            total_teaching_min=$(( total_teaching_min + duration ))
        fi
    done

done < "$filename"

# --------------------------------
# Totals
# --------------------------------
teach_hr=$(( total_teaching_min / 60 ))
teach_min=$(( total_teaching_min % 60 ))
oh_hr=$(( total_OH_min / 60 ))
oh_min=$(( total_OH_min % 60 ))

echo "----------------------------------------"
echo "Total Teaching Load: ${teach_hr}h ${teach_min}m"
echo "Total Office Hours : ${oh_hr}h ${oh_min}m"

# --------------------------------
# Task 3: Teaching load range (12–18)
# --------------------------------
echo "Teaching Load Validation:"
if [ $total_teaching_min -ge 720 ] && [ $total_teaching_min -le 1080 ]; then
    echo "Valid"
else
    echo "Invalid"
fi

# --------------------------------
# Task 4: OH >= 50% of teaching load
# --------------------------------
echo "OH Ratio Validation:"
half_teach=$(( total_teaching_min / 2 ))
if [ $total_OH_min -ge $half_teach ]; then
    echo "Valid"
else
    echo "Invalid"
fi

# --------------------------------
# Task 5: Distribution across teaching days
# --------------------------------
echo "Teaching Days Distribution:"
if [ $day_count -ge 4 ]; then
    echo "Valid"
else
    echo "Invalid"
    task5_valid=0
fi

# --------------------------------
# Prepare data for Task 6 & 7
# --------------------------------
temp_file="/tmp/schedule_slots_$$"
> "$temp_file"

while read line; do
    [ -z "$line" ] && continue
    day=$(echo "$line" | cut -d'|' -f1)
    activities=$(echo "$line" | cut -d'|' -f2 | tr -d ' ')

    case "$day" in S|M|T|W|Th) ;; *) continue ;; esac

    for act in $(echo "$activities" | tr ';' ' ')
    do
        interval=$(echo "$act" | grep -o "\[[^]]*\]" | tr -d '[]')
        code=$(echo "$act" | sed "s/.*\]//")

        start=$(echo "$interval" | cut -d'-' -f1)
        end=$(echo "$interval" | cut -d'-' -f2)

        s=$(to_minutes "$start")
        e=$(to_minutes "$end")
        [ "$e" -lt "$s" ] && e=$(( e + 720 ))

        echo "$day|$s|$e|$code|$interval" >> "$temp_file"
    done
done < "$filename"

# --------------------------------
# Task 6: Time conflicts
# --------------------------------
echo "Time Conflicts Check:"
conflict_found=0

while read a; do
    da=$(echo "$a" | cut -d'|' -f1)
    sa=$(echo "$a" | cut -d'|' -f2)
    ea=$(echo "$a" | cut -d'|' -f3)

    while read b; do
        [ "$a" = "$b" ] && continue
        db=$(echo "$b" | cut -d'|' -f1)
        sb=$(echo "$b" | cut -d'|' -f2)
        eb=$(echo "$b" | cut -d'|' -f3)

        if [ "$da" = "$db" ] && [ $sa -lt $eb ] && [ $ea -gt $sb ]; then
            conflict_found=1
            task6_valid=0
        fi
    done < "$temp_file"
done < "$temp_file"

[ $conflict_found -eq 0 ] && echo "No time conflicts detected"

# --------------------------------
# Task 7: Consecutive teaching rule
# --------------------------------
echo "Consecutive Teaching Rule Check:"
sorted="/tmp/sorted_slots_$$"
sort -t '|' -k1,1 -k2,2n "$temp_file" > "$sorted"

prev_day=""
prev_end=""
prev_code=""
count=1

while read line; do
    d=$(echo "$line" | cut -d'|' -f1)
    s=$(echo "$line" | cut -d'|' -f2)
    e=$(echo "$line" | cut -d'|' -f3)
    c=$(echo "$line" | cut -d'|' -f4)

    if [ "$d" != "$prev_day" ]; then
        count=1
        prev_day="$d"
        prev_end="$e"
        prev_code="$c"
        continue
    fi

    if [ "$prev_code" != "OH" ] && [ "$c" != "OH" ] && [ "$s" -eq "$prev_end" ]; then
        count=$(( count + 1 ))
    else
        count=1
    fi

    if [ $count -gt 2 ]; then
        task7_valid=0
    fi

    prev_end="$e"
    prev_code="$c"
done < "$sorted"

# --------------------------------
# Final Summary (Tasks 5–8)
# --------------------------------
echo "----------------------------------------"
echo "Final Validation Summary:"
[ $task5_valid -eq 1 ] && echo "Task 5 (Teaching Days): VALID" || echo "Task 5 (Teaching Days): INVALID"
[ $task6_valid -eq 1 ] && echo "Task 6 (Time Conflicts): VALID" || echo "Task 6 (Time Conflicts): INVALID"
[ $task7_valid -eq 1 ] && echo "Task 7 (Consecutive Teaching): VALID" || echo "Task 7 (Consecutive Teaching): INVALID"
[ $task8_valid -eq 1 ] && echo "Task 8 (Allowed Days): VALID" || echo "Task 8 (Allowed Days): INVALID"

rm -f "$temp_file" "$sorted"
