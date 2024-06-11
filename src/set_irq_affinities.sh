#!/bin/bash
#
# set_irq_affinities.sh
#
# This script sets the IRQ affinities for various devices to specific CPUs.
# It allows custom affinity settings for specific IRQs and sets a default affinity for all others.
# The results of the affinity settings are logged, including any failures.
# Note: THIS IS NOT PERMANENT! These affinities will be reset upon reboot!
# This script will need to be set up with a service or run again at reboot. 
#
# Usage: ./set_irq_affinities.sh [-a default_affinity] [-c custom_affinities_file]
#   -a default_affinity: Optional. Default CPU affinity mask for all IRQs (default: 1 for CPU 0).
#   -c custom_affinities_file: Optional. Path to a file with custom IRQ affinities.
#
# Example Usage:
#   Set default affinity to CPU 0 and use custom affinities from a file:
#     ./set_irq_affinities.sh -a 1 -c custom_affinities.txt
# 
#
# Example Affinities File Format: 
#  106 8   # eth0: IRQ 106 to CPU 3 (mask 8 in hexadecimal)
#  125 4   # UART: IRQ 125 to CPU 2 (mask 4 in hexadecimal)
#  184 2   # PPS: IRQ 184 to CPU 1 (mask 2 in hexadecimal)
#
# Authors: Laxmi Vijayan
# Date: 05.01.24

# Default values
DEFAULT_AFFINITY="1"
CUSTOM_AFFINITIES_FILE=""

usage() {
    echo "Usage: $0 [-a default_affinity] [-c custom_affinities_file]"
    echo "  -a  Set the default CPU affinity mask for all IRQs (default: $DEFAULT_AFFINITY)"
    echo "  -c  Path to a file with custom IRQ affinities (format: IRQ CPU_MASK per line)"
    exit 1
}

while getopts ":a:c:" opt; do
    case $opt in
        a)
            DEFAULT_AFFINITY=$OPTARG
            ;;
        c)
            CUSTOM_AFFINITIES_FILE=$OPTARG
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            usage
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            usage
            ;;
    esac
done

IRQ_DIR="/proc/irq"
declare -a failed_irqs

set_affinity() {
    echo $2 | sudo tee "${IRQ_DIR}/$1/smp_affinity" > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        failed_irqs+=($1)
    fi
}

if [ -n "$CUSTOM_AFFINITIES_FILE" ]; then
    while IFS=' ' read -r irq mask; do
        if [[ "$irq" =~ ^[0-9]+$ ]] && [[ "$mask" =~ ^[0-9a-fA-F]+$ ]]; then
            set_affinity "$irq" "$mask"
        else
            echo "Invalid line in custom affinities file: $irq $mask"
        fi
    done < "$CUSTOM_AFFINITIES_FILE"
fi

for irq in $(ls "${IRQ_DIR}" | grep -E '^[0-9]+$'); do
    case $irq in
        $(awk '{print $1}' "$CUSTOM_AFFINITIES_FILE" 2>/dev/null))
            ;;
        *)
            set_affinity $irq $DEFAULT_AFFINITY
            ;;
    esac
done

echo "IRQ affinities have been set."
if [ ${#failed_irqs[@]} -gt 0 ]; then
    echo "IRQ Affinities could not be set for: ${failed_irqs[*]}"
fi
