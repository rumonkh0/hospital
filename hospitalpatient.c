#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "conio.h"

int pc, i, cond;
FILE *fptr;

// define structure for store information........
struct Pinfo
{
    int id;
    char name[15];
    int age;
    char disease[50];
    int bedno;
    double t_fees;
    double t_paid;
    double t_due;
} pinfo[1000];

void option(void);
void heading()
{
    printf("%s  %-15s%s\t%-20s%s   %8s  %10s %11s\n", "ID", "NAME", "AGE", "DISEASE", "BED NO", "TOTAL FEES", "TOTAL PAID", "TOTAL DUE");
}
void result(int i)
{
    printf("%-2d  %-15s%d\t%-20s%d      %9.2lf %11.2lf %12.2lf\n", pinfo[i].id, pinfo[i].name, pinfo[i].age, pinfo[i].disease, pinfo[i].bedno, pinfo[i].t_fees, pinfo[i].t_paid, pinfo[i].t_due);
}
void openw()
{
    fptr = fopen("patients.txt", "w");
}
void fileprint(int i)
{
    fprintf(fptr, "%d %s %d %s %d %.2lf %.2lf %.2lf\n", pinfo[i].id, pinfo[i].name, pinfo[i].age, pinfo[i].disease, pinfo[i].bedno, pinfo[i].t_fees, pinfo[i].t_paid, pinfo[i].t_due);
}

// scan information from text file to struct array.......
void load()
{
    fptr = fopen("patients.txt", "r");
    fscanf(fptr, "%d", &pc);
    for (i = 0; i < pc; i++)
    {
        fscanf(fptr, "%d", &pinfo[i].id);
        fscanf(fptr, "%s", pinfo[i].name);
        fscanf(fptr, "%d", &pinfo[i].age);
        fscanf(fptr, "%s", pinfo[i].disease);
        fscanf(fptr, "%d", &pinfo[i].bedno);
        fscanf(fptr, "%lf", &pinfo[i].t_fees);
        fscanf(fptr, "%lf", &pinfo[i].t_paid);
        fscanf(fptr, "%lf", &pinfo[i].t_due);
    }
    fclose(fptr);
}

// show all patient information............
void loadpatients()
{
    system("cls");
    if (pc != 0)
    {
        printf("Total patient: %d\n", pc);
        heading();
        printf("---------------------------------------------------------------------------------------\n");
        for (i = 0; i < pc; i++)
            result(i);
    }
    else
        printf("No patient found!!");
    printf("\nPress any key to go Main menu.....");
    getch();
    system("cls");
}

// insert new patient information............
void add()
{
    int tage, tbedno;
    double tt_fees, tt_paid, tt_due;
    char tname[50], tdisease[50];

    printf("please enter the patient name(one word): ");
    scanf("%s", tname);
    printf("please enter the patient age: ");
    scanf("%d", &tage);
    printf("please enter the name of disease of the patient(one word): ");
    scanf("%s", tdisease);
bed:
    printf("please enter the bed no. to admit: ");
    scanf("%d", &tbedno);
    for (i = 0; i < pc; i++)
        if (pinfo[i].bedno == tbedno)
        {
            printf("this bed is already booked\n");
            goto bed;
        }
    printf("please enter total fees of patient: ");
    scanf("%lf", &tt_fees);
    printf("please enter the paid amount: ");
    scanf("%lf", &tt_paid);

    if (pc != 0)
        pinfo[pc].id = pinfo[pc - 1].id + 1;
    else
        pinfo[pc].id = 1;
    strcpy(pinfo[pc].name, tname); // insert patient info in array........
    pinfo[pc].age = tage;
    strcpy(pinfo[pc].disease, tdisease);
    pinfo[pc].bedno = tbedno;
    pinfo[pc].t_fees = tt_fees;
    pinfo[pc].t_paid = tt_paid;
    pinfo[pc].t_due = tt_fees - tt_paid;

    system("cls");
    printf("Patient added\n");
    heading();
    result(pc);
    openw();
    fprintf(fptr, "%d\n", pc + 1);
    for (i = 0; i < pc + 1; i++)
        fileprint(i);
    fclose(fptr);
    load();
}

// search functionality by linear search algorithm..........
void search()
{
    int tid, found = 0, choice, s = 0;
    char tname[50];

start:
    printf("\nHow do you want to search: \n1)By ID\n2)By name\n3)By bed no\n4)By age\n5)By disease\n6)Main menu\n\n");
    cond = getch();

    switch (cond)
    {
    case '1':
        goto idsearch;
        break;
    case '2':
        goto namesearch;
        break;
    case '3':
        goto bedsearch;
        break;
    case '4':
        goto agesearch;
        break;
    case '5':
        goto diseasesearch;
        break;
    case '6':
        system("cls");
        option();
        break;
    default:
        system("cls");
        printf("!!!!!!!!!!!!Please enter a valid choice!!!!!!!!!!!!\n");
        goto start;
    }

    // search by id....................
idsearch:
    printf("Please enter the patient's id to search: ");
    scanf("%d", &tid);

    for (i = 0; i < pc; i++)
        if (pinfo[i].id == tid)
        {
            found = 1;
            system("cls");
            printf("Patient found!!!\n");
            result(i);
            break;
        }
    goto final;

    // search by name......................
namesearch:
    printf("Please enter the patient's name to search: ");
    scanf("%s", tname);

    system("cls");
    printf("Patient found!!!\n");
    heading();
    for (i = 0; i < pc; i++)
        if (strcmp(pinfo[i].name, tname) == 0)
        {
            s++;
            found = 1;
            result(i);
        }
    printf("\nTotal patient: %d\n", s);
    goto final;

    // search by bedno......................
bedsearch:
    printf("Please enter bed no to search patient: ");
    scanf("%d", &tid);

    for (i = 0; i < pc; i++)
        if (pinfo[i].bedno == tid)
        {
            found = 1;
            system("cls");
            printf("Patient found!!!\n");
            heading();
            result(i);
            break;
        }
    goto final;

    // search by age......................
agesearch:
    printf("Please enter age to search patient(s): ");
    scanf("%d", &tid);
    system("cls");
    printf("Patient found!!!\n");
    heading();
    for (i = 0; i < pc; i++)
        if (pinfo[i].age == tid)
        {
            s++;
            found = 1;
            result(i);
        }
    printf("\nTotal patient: %d\n", s);
    goto final;

    // search by disease......................
diseasesearch:
    printf("Please enter disease name to search patient(s): ");
    scanf("%s", tname);

    system("cls");
    printf("Patient found!!!\n");
    heading();
    for (i = 0; i < pc; i++)
        if (strcmp(pinfo[i].disease, tname) == 0)
        {
            s++;
            found = 1;
            result(i);
        }
    printf("\nTotal patient: %d\n", s);
    goto final;

final:
    if (found == 0)
    {
        system("cls");
        printf("Patient not found\n");
    }
}

// updating bed no. functionality............
void changebedno(int i)
{
    int j;
    int tbedno;
bed:
    printf("Enter new bed no. to transfer the patient: ");
    scanf("%d", &tbedno);
    for (j = 1; j <= pc; j++)
        if (pinfo[j].bedno == tbedno)
        {
            printf("this bed is already booked\n");
            goto bed;
        }

    pinfo[i].bedno = tbedno;
    system("cls");
    printf("Bed changed\n\n");
    heading();
    result(i);
    openw();
    fprintf(fptr, "%d\n", pc);
    for (i = 0; i < pc; i++)
        fileprint(i);
    fclose(fptr);
    load();
}

// update fees funtionality..................
void changet_fees(int i)
{
    int choice;
    double tt_fees;

start:
    printf("Please select a valid choice: \n1)Add fees\n2)Make payment for the patient\n3)Main menu\n");
    //    scanf("%d", & choice);
    cond = getch();

    switch (cond)
    {
    case '1':
        printf("How much money wanh to add? "); // update total fees...........
        scanf("%lf", &tt_fees);
        pinfo[i].t_fees += tt_fees;
        pinfo[i].t_due += tt_fees;
        break;
    case '2':
        printf("How much money you want to make payment? "); // update make payment of fees..............
        scanf("%lf", &tt_fees);
        pinfo[i].t_paid += tt_fees;
        pinfo[i].t_due -= tt_fees;
        break;
    case '3':
        option();
        break;
    default:
        printf("\n!!!!!!!!!!!!Please enter a valid choice!!!!!!!!!!!!\n");
        goto start;
    }

    system("cls");
    printf("Fees updated\n\n");
    heading();
    result(i);

    openw(); // save updated info in text file..............
    fprintf(fptr, "%d\n", pc);
    for (i = 0; i < pc; i++)
        fileprint(i);
    fclose(fptr);
}

// update information functionality..........
void edit()
{
    int id, tage, tbebno, tt_fees, choice, found = 0;
    printf("Please enter patient's id to edit: ");
    scanf("%d", &id);

    for (i = 0; i < pc; i++)
    {
        if (pinfo[i].id == id)
        {
            found = 1;
            system("cls");
            printf("Patient found!!!\n\n");
            heading();
            result(i);
        start:
            printf("\nPlease select which field you want to edit: \n1)Change bed\n2)Update fees\n3)Main menu\n\n");
            cond = getch();

            switch (cond)
            {
            case '1':
                changebedno(i);
                break;
            case '2':
                changet_fees(i);
                break;
            case '3':
                system("cls");
                option();
                break;
            default:
                printf("!!!!!!!!!!!!Please enter a valid choice!!!!!!!!!!!!\n");
                goto start;
            }
        }
    }
    if (found == 0)
    {
        system("cls");
        printf("Patient not found\n");
        option();
    }
}

// delete information functionality.......
int delete()
{
    int tid, found = 0, due = 0;

    printf("Please enter the patient's id to release: ");
    scanf("%d", &tid);

    for (i = 0; i < pc; i++)
    {
        if (pinfo[i].id == tid)
        {
            found = 1;
            if (pinfo[i].t_due > 0)
            {
                due = 1;
                goto out;
            }

            system("cls");
            printf("The below patient is released\n");
            result(i);

            while (i < pc - 1)
            {
                pinfo[i].id = pinfo[i + 1].id;
                strcpy(pinfo[i].name, pinfo[i + 1].name);
                pinfo[i].age = pinfo[i + 1].age;
                strcpy(pinfo[i].disease, pinfo[i + 1].disease);
                pinfo[i].bedno = pinfo[i + 1].bedno;
                pinfo[i].t_fees = pinfo[i + 1].t_fees;
                pinfo[i].t_paid = pinfo[i + 1].t_paid;
                pinfo[i].t_due = pinfo[i + 1].t_due;
                i++;
            }
        }
    }
out:
    if (found == 0)
    {
        system("cls");
        printf("Patient not found\n");
        option();
    }

    if (due == 1)
    {
        system("cls");
        printf("Due not cleared!! Please clear the due.\n");
        result(i);
        option();
    }
    openw();
    fprintf(fptr, "%d\n", pc - 1);
    for (i = 0; i < pc - 1; i++)
        fileprint(i);
    fclose(fptr);
    load();
}

// main menu screen options..........
void option()
{
    printf("\n\n-------Main menu-------\n\nEnter a choice:\n1)Add a patient\n2)Search a patient\n3)Update patient info\n4)Release a patient\n5)See all patients info\n6)exit\n\n");
    cond = getch();

    switch (cond)
    {
    case '1':
        add();
        break;
    case '2':
        search();
        break;
    case '3':
        edit();
        break;
    case '4':
        delete ();
        break;
    case '5':
        loadpatients();
        break;
    case '6':
        exit(2);
    default:
        system("cls");
        printf("please enter a valid choice (1-6)");
    }
}

int main()
{
    int cond;

    load();
    printf("*******************************************************\n"); // welcome screen............
    printf("*******************************************************\n");
    printf("***********<                                >**********\n");
    printf("***********<     WELCOME TO GREEN HOSPITAL  >**********\n");
    printf("***********<                                >**********\n");
    printf("*******************************************************\n");
    printf("*******************************************************\n\n");
    printf("            Patient Management System");
    while (1)
        option();

    return 0;
}
