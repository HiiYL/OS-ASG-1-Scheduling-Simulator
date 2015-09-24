# Scheduling Simulator (Operating Systems Assignment)

There are 4 scheduling algorithms here:

- FCFS (First Come First Served)-based pre-emptive Priority - **fcfs.sh**
- Round Robin Scheduling - **rooundrobin.sh**
- Three-level Queue Scheduling - **multilevel.sh**
- Shortest Remaining Time Next (SRTN) scheduling - **strn.sh**

All these bash scripts read an input file using a common script, **readprocessinput.sh**. 

To run, type into terminal:

`./strn.sh input.txt`

The input file is formatted as follows: Each line contains a process detailed (in order) by process name, arrival time, burst time and priority, separated by spaces. The last line contains an integer, and this is the quantum.

Below is a sample run or SRTN:

    [bruceoutdoors@BruceManjaro bash]$ ./strn.sh input2.txt
    Process Name: P1
    Arrival Time: 8
    Burst Time: 1
    Priority: 1
    
    Process Name: P2
    Arrival Time: 5
    Burst Time: 1
    Priority: 1
    
    Process Name: P3
    Arrival Time: 30
    Burst Time: 7
    Priority: 1
    
    Process Name: P4
    Arrival Time: 35
    Burst Time: 3
    Priority: 1
    
    Process Name: P5
    Arrival Time: 2
    Burst Time: 8
    Priority: 1
    
    Process Name: P6
    Arrival Time: 4
    Burst Time: 2
    Priority: 1
    
    Process Name: P7
    Arrival Time: 3
    Burst Time: 5
    Priority: 1
    
    Quantum: 4
    
    ~~~ Shortest Time Remaining Next (STRN) Scheduling ~~~
    
    Grantt Chart: 
    0 [*IDLE*] 2 [P5] 3 [P7] 4 [P6] 6 [P2] 7 [P7] 8 [P1] 9 [P7] 12 [P5] 19 [*IDLE*] 30 [P3] 37 [P4] 40
    
    Total   Turnaround Time : 43
    Total   Waiting Time    : 16
    Average Turnaround Time : 6.14
    Average Waiting Time    : 2.28
    
    ~~~ END: Shortest Time Remaining Next (STRN) Scheduling ~~~
