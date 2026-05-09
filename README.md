Overview

This project is a shell script-based system designed to analyze and validate a teaching schedule from an input file. It processes time intervals for teaching sessions and office hours, then performs multiple validations to ensure the schedule follows specific academic rules.

⚙️ Features

Reads schedule data from a text file
Parses time intervals and activity codes (Teaching / OH)
Converts time into minutes for calculations
Calculates total teaching load and office hours
Detects time conflicts between sessions
Checks consecutive teaching rules
Validates allowed teaching days
Provides final validation summary
🧠 Key Functionalities
1. Load and Parse Data

The script reads each line from the input file and extracts:

Day of the week
Time intervals
Activity type (Teaching or Office Hours)
2. Time Processing
Converts time format (hh:mm) into minutes
Calculates duration of each activity
Handles edge cases where time crosses intervals
3. Validation Rules

The system checks:

📊 Teaching load is within acceptable range (12–18 hours)
🕒 Office hours are at least 50% of teaching load
📅 Teaching occurs on at least 4 different days
⚠️ No overlapping time conflicts
🔁 No more than 2 consecutive teaching sessions
📌 Only valid teaching days are allowed (S, M, T, W, Th)
📤 Output

The script prints:

Total teaching load
Total office hours
Validation results for each rule
Final summary (VALID / INVALID per task)

🚀 How to Run
chmod +x script.sh
./script.sh schedule.txt
