#!/bin/bash

# Author Name: Rumon Khan
# Author Email: rummankh0@gmail.com
# Social Media: https://www.linkedin.com/in/rudradcruze/
# © All rights reserved by rudradcruze - 2023

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
    local last_id=$(tail -n 1 patient.csv | cut -d ',' -f1) # Extracts the ID from the last line
    local next_id=$((last_id + 1))                          # Increments the last ID by 1 to generate the next ID
    echo "$next_id"
}

searchPatientByID() {
    local id="$1"
    grep "^$id," patient.csv
}

updatePatientField() {
    local id="$1"
    local field="$2"
    local patient_info=$(searchPatientByID "$id")

    if [ -n "$patient_info" ]; then
        echo "Patient Found: "
        echo "$patient_info"

        # Prompt for the field to update
        read -p "Enter the field to update (Name, Age, Disease, BedNo, Fees, Paid, Due) for ID $id: " field_value

        # Check if the field provided by the user is valid
        if [[ "$field_value" =~ ^(Name|Age|Disease|BedNo|Fees|Paid|Due)$ ]]; then
            # Ask for the new value for the specified field
            read -p "Enter new $field_value for ID $id: " new_value

            # Update the specified field for the patient
            awk -v id="$id" -v field="$field_value" -v new="$new_value" -F',' 'BEGIN {OFS=","} {if ($1 == id) $field = new; print}' patient.csv > temp.csv
            mv temp.csv patient.csv

            echo "Field '$field_value' updated for ID $id."
        else
            echo "Invalid field name. Please enter a valid field name."
        fi
    else
        echo "Patient with ID $id not found."
    fi
}

function addPatient() {
    read -p "patient name: " name
    read -p "patient age: " age
    read -p "Patient's disease: " disease
    bedNo=""
    bed=0
    while [ "$bed" -eq 0 ]; do
        read -p "Admid in bed no: " bedNo
        if grep -q "^.*,.*,.*,${bedNo},.*" patient.csv; then
            echo "Bed number $bedNo already occupied."
        else
            bed=1
        fi
    done
    read -p "Total fees of patient: " fees
    read -p "Paid amount: " paid
    id=$(getNextId)
    due=$((fees - paid))

    echo "$id,$name,$age,$disease,$bedNo,$fees,$paid,$due" >>patient.csv
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
    echo "Enter student id: "
    read student_id_for_student

    return_function_value student $student_id_for_student 2
    student_return_value=$function_return_value

    if [ "$student_return_value" == 0 ]; then
        echo "Student not exsist"
    else
        head_banner
        echo -e "\n=========================================="
        echo -e "= Welcome $student_return_value"
        echo -e "=========================================="

        view_single_student $student_id_for_student
    fi
}
function releasePatient() {
    echo "not build yet"
}
printPatients() {
    column -s',' -t < patient.csv
}

# getFullName() {
#     local first_name="$1"
#     local last_name="$2"
    
#     # Concatenate the first name and last name
#     echo "$first_name + $last_name"
# }

# # Calling the function and capturing its output in a variable
# read -p "enter " fir las
# full_name=$(getFullName $fir $las)

# echo "Full Name: $full_name"

#main programme
choice="y"
while [ $choice == "y" ] || [ $choice == "Y" ]; do
    head_banner
    echo "Enter your choice: "
    echo "1. Add a patient"
    echo "2. Search a patient"
    echo "3. Update patient info"
    echo "4. Release a patient" #See all patients info
    echo "5. See all patients info"
    echo "6. Exit"
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
        exit
        ;;
    *)
        echo "Invalid Input"
        ;;
    esac
    # Ask user if they want to continue
    echo -e "\nDo you want to perform another operation [y/n]: "
    read choice
done
