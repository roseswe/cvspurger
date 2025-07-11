#!/bin/bash
# filepath: $Header: /home/cvs/src/prj/cvspurger/cvspurger.sh,v 1.7 2025/07/11 12:45:11 ralph Exp $
# (c) 2020-2025 by ROSE_SWE, Ralph Roth
# @(#) $Id: cvspurger.sh,v 1.7 2025/07/11 12:45:11 ralph Exp $

show_help() {
    echo "Usage: $(basename "$0") [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -?, -h, --help, --usage   Show this help message and exit"
    echo "  -V, --version             Show version information and exit"
    echo "  -f, --file <singlefile>   Process only the specified file (instead of all files)"
    echo "  -r, --revs <number>       Purge if revision count is greater than <number> (default: 30)"
}

show_version() {
    echo "Version: @(#) $Id: cvspurger.sh,v 1.7 2025/07/11 12:45:11 ralph Exp $"
    echo "(c) 2020-2025 by ROSE_SWE, Ralph Roth - All rights reserved."
}

# Parse command-line arguments
file_to_process=""
revision_limit=30
while [ "$1" != "" ]; do
    case "$1" in
        -\?|-h|--help|--usage|/\?|/h)
            show_help
            exit 0
            ;;
        -V|--version)
            show_version
            exit 0
            ;;
        -f|--file)
            shift
            if [ -z "$1" ]; then
                echo "[!!] Error: Missing file argument for -f/--file option."
                exit 2
            fi
            file_to_process="$1"
            ;;
        -r|--revs)
            shift
            if [[ -z "$1" || ! "$1" =~ ^[0-9]+$ ]]; then
                echo "[!!] Error: Missing or invalid revision count for -r/--revs option."
                exit 4
            fi
            revision_limit="$1"
            ;;
        *)
            echo "[!!] Error: Unrecognized option: $1"
            show_help
            exit 3
            ;;
    esac
    shift
done

# Function to get the oldest and newest revision numbers
get_revision_limits() {
    local file="$1"
    local revisions
    revisions=$(cvs log "$file" 2>/dev/null | grep '^revision' | awk '{print $2}')
    if [[ -z "$revisions" ]]; then
        return 1 # No revisions found
    fi
    local revision_array=($(echo "$revisions"))
    local count=${#revision_array[@]}

    if [[ $count -lt 6 ]]; then
        return 1
    fi

    local oldest1=${revision_array[1]}
    local oldest2=${revision_array[2]}
    local newest1=${revision_array[$((count - 2))]}
    local newest2=${revision_array[$((count - 3))]}

    echo "$oldest1 $oldest2 $newest2 $newest1"
    return 0
}

# Function to get the revisions to purge
get_purge_range() {
    local file="$1"
    local oldest1="$2"
    local oldest2="$3"
    local newest2="$4"
    local newest1="$5"
    local revisions
    revisions=$(cvs log "$file" 2>/dev/null | grep '^revision' | awk '{print $2}')
    local revision_array=($(echo "$revisions"))
    local count=${#revision_array[@]}
    local purge_range=""
    local first_purge=1

    for ((i=0; i < count; i++)); do
        local current_revision=${revision_array[i]}
        if [[ "$current_revision" != "$oldest1" && "$current_revision" != "$oldest2" && "$current_revision" != "$newest2" && "$current_revision" != "$newest1" ]]; then
            if [[ $first_purge -eq 1 ]]; then
                purge_range="$current_revision"
                first_purge=0
            else
                purge_range="$purge_range-$current_revision"
            fi
        fi
    done
    echo "$purge_range"
}

echo "CVS Purger Script - purges CVS ,v files with too many revisions to reduce the size..."
export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8

process_file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        if [[ "$file" != *,v ]]; then
            revision_count=$(cvs log "$file" 2>/dev/null | grep '^revision' | wc -l)
            if [[ "$revision_count" -gt "$revision_limit" ]]; then
                read newest1 newest2 oldest2 oldest1 < <(get_revision_limits "$file")
                if [ -n "$oldest1" ]; then
                    if purge_range=$(get_purge_range "$file" "$oldest1" "$oldest2" "$newest2" "$newest1"); then
                        if [[ -n "$purge_range" ]]; then
                            CMD="cvs admin -o $oldest2:$newest2 $file"
                            $CMD 2>/dev/null > /dev/null
                            echo "✅ $file, $revision_count revisions, purged $oldest2:$newest2"
                        else
                            echo "➖ $file not enough revisions to purge"
                        fi
                    else
                        echo "❌ $file n/a"
                    fi
                else
                    echo "❓ $file (no CVS revisions found)"
                fi
            else
                if [[ "$revision_count" -gt 0 ]]; then
                    echo "🆗 $file, $revision_count revisions"
                fi
            fi
        else
            if [[ -n "$(cvs log "$file" 2>/dev/null | grep '^revision')" ]] ; then
                echo "❓ $file"
            fi
        fi
    fi
}

if [[ -n "$file_to_process" ]]; then
    process_file "$file_to_process"
else
    # Iterate over all files in the current directory
    for file in *; do
        process_file "$file"
    done
fi

echo "[Info]  All done!  Bye..."
