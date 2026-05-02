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
# Variables (in minutes)
# --------------------------------
total_teaching_min=0
total_OH_min=0

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
# Read file
# --------------------------------
while read line; do
    [ -z "$line" ] && continue

    day=$(echo "$line" | cut -d'|' -f1)
    activities=$(echo "$line" | cut -d'|' -f2 | tr -d ' ')

    # Validate allowed days
    case "$day" in
        S|M|T|W|Th) ;;
        *)
            echo "Invalid day: $day"
            continue
            ;;
    esac

    day_str="$day: "

    # Split activities
    for act in $(echo "$activities" | tr ';' ' ')
    do
        [ -z "$act" ] && continue

        interval=$(echo "$act" | grep -o "\[[^]]*\]" | tr -d '[]')
        code=$(echo "$act" | sed "s/.*\]//")

        # Extract times
        start=$(echo "$interval" | cut -d'-' -f1)
        end=$(echo "$interval" | cut -d'-' -f2)

        # Convert to minutes
        start_min=$(to_minutes "$start")
        end_min=$(to_minutes "$end")

        # Fix 12–1 PM (end < start)
        if [ "$end_min" -lt "$start_min" ]; then
            end_min=$(( end_min + 720 ))   # +12 hours
        fi

        duration=$(( end_min - start_min ))

        # Add to totals
        if [ "$code" = "OH" ]; then
            total_OH_min=$(( total_OH_min + duration ))
        else
            total_teaching_min=$(( total_teaching_min + duration ))
        fi

        # Build day string
        if [ "$code" = "OH" ]; then
            day_str="$day_str$interval OH "
        else
            day_str="$day_str$interval "
        fi

    done

    echo "$day_str"

done < "$filename"


# --------------------------------
# Convert total minutes to hours + minutes
# --------------------------------
teach_hr=$(( total_teaching_min / 60 ))
teach_min=$(( total_teaching_min % 60 ))

oh_hr=$(( total_OH_min / 60 ))
oh_min=$(( total_OH_min % 60 ))


echo "----------------------------------------"
echo "Total Teaching Load: ${teach_hr}h ${teach_min}m"
echo "Total Office Hours : ${oh_hr}h ${oh_min}m"


# --------------------------------
# Validate teaching load range (12–18 hours)
# --------------------------------
echo "Teaching Load Validation: Validate teaching load range (12–18 hours)"
if [ $total_teaching_min -ge 720 ] && [ $total_teaching_min -le 1080 ]; then
    echo "Valid Schedule "
else
    echo "Valid Schedule)"
fi


# --------------------------------
# Validate OH >= 50% of teaching load
# --------------------------------
echo "OH Ratio Validation:"
half_teach=$(( total_teaching_min / 2 ))

if [ $total_OH_min -ge $half_teach ]; then
    echo " OH hours are at least 50% of teaching load"
else
    echo " OH hours INVALID "
fi
