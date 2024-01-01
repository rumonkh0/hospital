#!/bin/bash
function head_banner() {
    clear
    echo "*******************************************************"
    echo "*******************************************************"
    echo "***********<                                >**********"
    echo "***********<     WELCOME TO GREEN HOSPITAL  >**********"
    echo "***********<                                >**********"
    echo "*******************************************************"
    echo "*******************************************************"
}
getNextId() {
    local last_id=$(tail -n 1 patient.csv | cut -d ',' -f1)
    local next_id=$((last_id + 1))
    echo "$next_id"
}

searchPatientByID() {
    local id_to_search="$1"      # ID to search for
    local csv_file="patient.csv" # CSV file name

    # Check if the ID exists in the first column of the CSV file
    if grep -q "^$id_to_search," "$csv_file"; then
        return 0 # ID found, return true (0)
    else
        return 1 # ID not found, return false (1)
    fi
}

updateFieldByID() {
    local id="$1"
    read -p "Which field want to change: " field_name
    read -p "Enter new value: " new_value

    local file="patient.csv"
    local tempfile="temp.csv"

    local found=false
    local IFS=','

    while read -r line; do
        read -ra fields <<<"$line"

        if [[ "${fields[0]}" == "$id" ]]; then
            found=true
            case "$field_name" in
            "Name") fields[1]="$new_value" ;;
            "Age") fields[2]="$new_value" ;;
            "Disease") fields[3]="$new_value" ;;
            "BedNo") fields[4]="$new_value" ;;
            "Fees")
                fields[5]="$new_value"
                fields[7]=$((fields[5] - fields[6]))
                ;;
            "Paid")
                fields[6]="$((fields[6] + new_value))"
                fields[7]=$((fields[7] - new_value))
                ;;
            *)
                echo "Invalid field name"
                rm "$tempfile"
                return 0
                ;;
            esac
            echo "${fields[*]}" >>"$tempfile"
        else
            echo "$line" >>"$tempfile"
        fi
    done <"$file"

    if ! $found; then
        rm "$tempfile"
    else
        mv "$tempfile" "$file"
        echo "Updated"
        return 1
    fi

}

beds=()
loadBeds() {
    unset beds
    while IFS= read -r line; do
        beds+=("$line")
    done <"beds.csv"
}
bedAvailable() {
    loadBeds
    echo "Available Beds:" ${#beds[@]}
    sorted_beds=($(printf "%s\n" "${beds[@]}" | sort -n))
    printf "%s, " "${sorted_beds[@]}"
    # for bed in "${beds[@]}"; do
    #     echo "$bed"
    # done
}

AvailableCheck() {
    loadBeds
    found=false
    bed_to_check=$1
    for bed in "${beds[@]}"; do
        if [ "$bed" -eq "$bed_to_check" ]; then
            found=true
            break
        fi
    done

    if $found; then
        echo "Bed $bed is available."
    else
        echo "Bed $bed_to_check is not available."
    fi
}

saveAvailableBeds() {
    rm -f beds.csv
    printf "%s\n" "${beds[@]}" >"beds.csv"
}

addBed() {
    loadBeds
    local new_bed="$1"
    beds+=("$new_bed")
    saveAvailableBeds
}

removeBed() {
    local bed_to_remove="$1"
    local index=-1
    for ((i = 0; i < ${#beds[@]}; i++)); do
        if [ "${beds[i]}" = "$bed_to_remove" ]; then
            index=$i
            break
        fi
    done

    if [ "$index" -ne -1 ]; then
        unset 'beds[index]'
        saveAvailableBeds
    fi
}

function addPatient() {
    read -p "patient name: " name
    read -p "patient age: " age
    read -p "Patient's disease: " disease
    bedNo=""
    bedc=0
    bedAvailable
    while [ "$bedc" -eq 0 ]; do
        echo ""
        read -p "Admid in bed no: " bedNo
        AvailableCheck $bedNo
        if grep -q "^.*,.*,.*,${bedNo},.*" patient.csv; then
            echo "Bed number $bedNo already occupied."
        else
            bedc=1
        fi
    done
    read -p "Total fees of patient: " fees
    read -p "Paid amount: " paid
    id=$(getNextId)
    due=$((fees - paid))

    echo "$id, $name,$age,$disease,$bedNo,$fees,$paid,$due" >>patient.csv

    removeBed $bedNo
    echo "Patient admitted"
}
searchPatient() {
    read -p "Patient name: " patient_name
    local row=$(awk -v name="$patient_name" -F',' '$2 == name {print}' patient.csv)

    if [ -n "$row" ]; then
        echo "$row"
    else
        echo "Patient '$patient_name' does not exist in the CSV file."
    fi
}
function updatePatient() {
    choice=n
    while [ "$choice" == "n" ]; do
        read -p "Enter patient id: " id

        searchPatientByID $id
        if [ $? -eq 0 ]; then
            updateFieldByID $id
            if [ $? -eq 0 ]; then
                echo ""
            else
                choice=y
            fi
        else
            echo "Patient ID not found."
        fi

    done

}
function releasePatient() {
    local found=false

    while ! $found; do

        read -p "Enter patient id: " id
        local file="patient.csv"
        local tempfile="temp.csv"
        finfo=()
        while IFS=',' read -r line; do
            # local info[0]=$(echo "$line" | cut -d',' -f1,5)
            # read info[0] occuBed <<<$(awk -F ',' '{print $1, $5}' <<<"$line")
            occuBed=""
            IFS=',' read -r -a info <<<"$line"

            if [[ "${info[0]}" != "$id" ]]; then
                echo "$line" >>"$tempfile" # Write lines that don't match the ID to temp file
            else
                occuBed=${info[4]}
                found=true
                finfo=("${info[@]}")
            fi
        done <"$file"

        if ! $found; then
            echo "Patient with ID $id not found."
            rm "$tempfile"
        else
            if [[ "${finfo[7]}" -gt 0 ]]; then
                echo "The patient have due of: "${finfo[7]}"TK. Please clear the due."
            else
                mv "$tempfile" "$file" && rm -f "$tempfile"
                echo "Patient with ID $id deleted."
                addBed $occuBed
            fi
        fi

    done
}
printPatients() {
    clear
    column -s',' -t <patient.csv
    # sort -t',' -k3 -n patient.csv
    # tail -n +2 patient.csv | sort -t',' -k3 -n | column -s',' -t
    echo "1) Sort by age"
    echo "2) Sort by Name"
    read val
    case "$val" in
    1)
        clear
        {
            head -n 1 patient.csv
            tail -n +2 patient.csv | sort -t',' -k3
        } | column -s',' -t
        ;;
    2)
        clear
        {
            head -n 1 patient.csv
            tail -n +2 patient.csv | sort -t',' -k2
        } | column -s',' -t

        ;;
    *)
        echo "Enter a valid choice"
        ;;
    esac

}

#main programme
choice="y"
while [ $choice == "y" ] || [ $choice == "Y" ]; do
    head_banner
    echo "Enter your choice: "
    echo "1. Add a patient"
    echo "2. Search a patient"
    echo "3. Update patient info"
    echo "4. Release a patient"
    echo "5. See all patients info"
    echo "6. See bed availability"
    echo "7. Exit"
    read menuOption

    case "$menuOption" in
    1)
        addPatient
        ;;
    2)
        searchPatient
        ;;
    3)
        updatePatient
        ;;
    4)
        releasePatient
        ;;
    5)
        printPatients
        ;;
    6)
        bedAvailable
        ;;
    7)
        exit
        bedAvailable
        saveAvailableBeds
        ;;
    *)
        echo "Invalid Input"
        ;;
    esac
    # Ask user if they want to continue
    echo -e "\nDo you want to perform another operation [y/n]: "
    read choice
done
