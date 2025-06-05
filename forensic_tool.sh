#!/bin/bash

# Script Header Information
# Student Name: yogev levi
# Class Code: S21
# Unit: TMagen773634
# Lecturer: david

# Showes the current working directory as the location for storing the case files.
HOME=$(pwd)

# Establish specific color values to style the output display.

GREEN="\e[0;32m"
RED="\e[31m"
STOP="\e[0m"
BOLD="\e[1m"
CYAN="\e[0;36m"
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")

# Create a routine to process the results and compile them into a report.

function RESULTS()
{
	# Specify the location where the report file will be saved.

	report_file="$HOME/forensic_case/results_report.txt"
	end_time=$(date)
	total_time=$(( $(date -d "$end_time" +"%s") - $(date -d "$START" +"%s") ))
	
	 # Output information about the end of the analysis
	 
	printf "${BOLD}${CYAN}"
	echo -e "Ended , here's the summarized details:\n"
	printf "${STOP}"
	sleep 3
	printf "${BOLD}"
	echo "Start time: $START" | tee -a $report_file
	echo "End time: $(date)" | tee -a $report_file
	echo -e "Total analysis time (in seconds): $total_time\n" | tee -a $report_file
	printf "${STOP}"
	sleep 1
	# Scan the forensic case folder to identify any contained subdirectories.

	exee_file=$(find "$HOME/forensic_case" -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
	if [ -n "$exee_file" ]
	then
		for dir in $exee_file
		do
			file_count=$(find "$dir" -type f | wc -l)
            echo -e "Number of files in $dir: $file_count\n" | tee -a $report_file
		done
	else
		echo "No directories found in './forensic_case'."
	fi
	 # Package the forensic tools and the results report into a single compressed zip file.
	 
	printf "${BOLD}${CYAN}"
	echo -e "All the general statistics saved in: $report_file\n"
	printf "${STOP}"
	new_dir="$HOME/forensic_case/forensics_results"
	mkdir -p "$new_dir"
	mv $HOME/forensic_case/binwalk $HOME/forensic_case/bulk_extractor $HOME/forensic_case/foremost $HOME/forensic_case/volatility $HOME/forensic_case/strings "$new_dir/"> /dev/null 2>&1
	printf "${BOLD}${CYAN}"
	echo -e "The results of the memory analysis saved in folders inside the: $new_dir\n"
	printf "${STOP}"
	ZIP_FILE="$HOME/forensic_case/forensic_$timestamp.zip"
	cd "$HOME/forensic_case" && zip -r "$ZIP_FILE" "forensics_results" "results_report.txt" > /dev/null 2>&1
    printf "${BOLD}${CYAN}"
    echo "Results successfully compressed into: $ZIP_FILE"
    printf "${STOP}"
}


# Create a procedure to launch Volatility and perform in-depth memory examination.

function VOLATILITY_ANALYZE()
{
	vol_file="/home/kali/Desktop/forensic_case/volatility_2.5_linux_x64"
	PROFILE=$($vol_file -f $file_analyze imageinfo 2>/dev/null | grep -i "Suggested Profile" | cut -d ':' -f 2 | cut -d ',' -f 1 | xargs)
	printf "${BOLD}${GREEN}"
	echo -e "The memory profile is: $PROFILE\n"
	printf "${STOP}"
	
	# Show which memory profile was applied in the course of the analysis.

	echo -e "[+] Getting processes list from the memory\n"
	$vol_file -f $file_analyze --profile=$PROFILE pslist 2>/dev/null | tee $HOME/forensic_case/volatility/processes.txt> /dev/null 2>&1
	
	echo -e "[+] Getting information related to network connections\n"
	$vol_file -f $file_analyze --profile=$PROFILE connscan 2>/dev/null | tee $HOME/forensic_case/volatility/connections_scan.txt> /dev/null 2>&1
	
	echo -e "[+] Making an attempt to provide hive list\n"
	$vol_file -f $file_analyze --profile=$PROFILE hivelist 2>/dev/null | tee $HOME/forensic_case/volatility/hives.txt> /dev/null 2>&1
	
	echo -e "[+] Making an attempt to extract registry information\n"
	$vol_file -f $file_analyze --profile=$PROFILE dumpregistry --dump-dir $HOME/forensic_case/volatility/ > /dev/null 2>&1
	echo -e "The memory information saved in: $HOME/forensic_case/volatility\n"
	RESULTS
}

# Function to check if Volatility is installed and if not, install it
function VOLATILITY_BANNER()
{
	echo -e "Checking if Volatility is installed...\n"
	# Check if Volatility is installed and working
	vol_banner=$(/home/kali/Desktop/forensic_case/volatility_2.5_linux_x64 -h | grep "Framework")
	if [ -n $vol_banner ]
	then
		echo -e "\n"
		printf "${GREEN}"
		echo -e "[ + ] Volatility is installed. here's the banner, Starting analysis...\n"
		printf "${STOP}"
	else
		printf "${RED}"
		echo "Not found the volatility file, Trying install it again..."
		printf "${STOP}"
		target_folder="/home/kali/Desktop/forensic_case"
		local_file_path="/home/kali/Desktop/Volatililty_for_Linux.zip"
		cd /home/kali/Desktop
		chmod +r "$local_file_path"> /dev/null 2>&1
		python3 -m http.server 8000 &> /dev/null &
		server_pid=$!
		sleep 3
		wget -O "$target_folder/Volatililty_for_Linux.zip" "http://localhost:8000/Volatililty_for_Linux.zip" &> /dev/null
		kill $server_pid
		sudo unzip -o "$target_folder/Volatililty_for_Linux.zip" -d "$target_folder" &> /dev/null
		mv $target_folder/volatility_2.5.linux.standalone/volatility_2.5_linux_x64 $target_folder
		echo -e "Trying again to find volatility...\n"
		VOLATILITY_BANNER
	fi
	VOLATILITY_ANALYZE
}

# Function to extract human-readable strings from executable files
function STRINGS_HUMAN()
{
	printf "${BOLD}"
	echo -e "Extracting human-readable strings from .exe files...\n"
	printf "${STOP}"
	# Find .exe files in the specified directory
	exee=$(ls $HOME/forensic_case/foremost/exe/*.exe 2>/dev/null)
	if [ -n "$exee" ]
	then
		echo -e "Found .exe files. Extracting strings with the keys: passwords, usernames and card.\n"
		for file in $exee
		do
			strings_keys="passwords usernames card" # Keys for string extraction
			filename=$(basename "$file")
			for i in $strings_keys
			do
				strings $file | grep -i $i >> "$HOME/forensic_case/strings/${filename}_${i}.txt" 2> /dev/null
			done
		done
			printf "${CYAN}"
			echo -e "Results saved to $HOME/forensic_case/strings\n"
			printf "${STOP}"
	else
		echo "No .exe files found."
	fi
	VOLATILITY_BANNER
}

# Function for data carving using tools like binwalk, bulk_extractor, and foremost
function CARVING()
{
	# Run carving tools on the specified file
	echo -e "[ ! ] Extracting data with binwalk [ ! ]\n"
    binwalk --run-as=root -e "$file_analyze" --directory $HOME/forensic_case/binwalk > /dev/null 2>&1
    printf "${CYAN}"
    echo -e "[ + ] Saved in: $HOME/forensic_case/binwalk\n"
    printf "${STOP}"
	echo -e "[ ! ] Extracting data with bulk_extractor [ ! ]\n"
	bulk_extractor $file_analyze -o $HOME/forensic_case/bulk_extractor> /dev/null 2>&1
	printf "${CYAN}"
	echo -e "[ + ] Saved in: $HOME/forensic_case/bulk_extractor\n"
	printf "${STOP}"
	echo -e "[ ! ] Extracting data with foremost [ ! ]\n"
	foremost $file_analyze -o $HOME/forensic_case/foremost> /dev/null 2>&1
	printf "${CYAN}"
	echo -e "[ + ] Saved in: $HOME/forensic_case/foremost\n"
	printf "${STOP}"
	
	printf "${BOLD}"
	echo -e "[ + ] Checking for PCAP file....\n"
	printf "${STOP}"
	# Check if a PCAP file exists in the bulk_extractor output directory
	shark=$(ls $HOME/forensic_case/bulk_extractor | grep *.pcap)
	if [ $shark ]
	then
		printf "${RED}"
		echo "No PCAP file found."
		printf "${STOP}"
	else
		printf "${CYAN}"
		echo "PCAP file was found ! Location:$HOME/forensic_case/bulk_extractor"
		printf "${STOP}"
		pcap_file=$(find /home/kali/Desktop/forensic_case -type f -name "*.pcap")
		file_size=$(ls -l $pcap_file | tr -s ' ' | cut -d ' ' -f 5)
		printf "${CYAN}"
		echo -e "File size: $file_size\n"
		printf "${STOP}"
	fi
	STRINGS_HUMAN
}
	


# Function to install relevant forensic tools
function INSTALL_FORENSICS
{
	printf "${BOLD}"
	echo -e "Installing relevat apps....\n"
	printf "${STOP}"
	target_folder="/home/kali/Desktop/forensic_case"
	#file_url="http://89.138.68.87:8000/Volatililty_for_Linux.zip"
	local_file_path="/home/kali/Desktop/Volatililty_for_Linux.zip"
	cd /home/kali/Desktop
	chmod +r "$local_file_path"> /dev/null 2>&1
	python3 -m http.server 8000 &> /dev/null &
	server_pid=$!
	sleep 3
	wget -O "$target_folder/Volatililty_for_Linux.zip" "http://localhost:8000/Volatililty_for_Linux.zip" &> /dev/null
	kill $server_pid
	sudo unzip -o "$target_folder/Volatililty_for_Linux.zip" -d "$target_folder" &> /dev/null
	mv $target_folder/volatility_2.5.linux.standalone/volatility_2.5_linux_x64 $target_folder
	 # Install forensic tools if not already installed
	installs="bulk-extractor binwalk foremost"
	for p in $installs
	do
		if dpkg -l | grep -q "^ii  $p"
		then
			printf "${GREEN}${BOLD}"
			echo -e "$p is already installed, skipping...\n"
			printf "${STOP}"
		else
			printf "${BOLD}"
			echo -e "Installing: $p\n"
			printf "${STOP}"
			sudo apt install -y $p > /dev/null 2>&1
		fi
	done
	printf "${CYAN}"
	echo -e "[ + ] All required apps installed [ + ]\n"
	printf "${STOP}"
	CARVING
}

# Function to start the entire process
function START()
{
	figlet "My second project"
	sleep 1
	# Record the start time
	START=$(date)
	# Check if the user is root
	user=$(whoami)
	printf "${BOLD}"
	echo -e "[ ! ] First Checking if you are root [ ! ]\n"
	printf "${STOP}"
	sleep 2

	if [ "$user" == "root" ]
	then
		printf "${GREEN}"
		echo -e "You are root.. continuing..\n"
		printf "${STOP}"
	else
		printf "${RED}"
		echo -e "You are not root.. exiting...\n"
		printf "${STOP}"
		exit
	fi
	
	sleep 1
	printf "${BOLD}"
	echo "Please enter a full path to the file you would like to investigate:"
	printf "${STOP}"
	read file_analyze
	if [ -e "$file_analyze" ]
	then
		echo -e "The file is exist, starting analyze\n"
	else
		echo -e "The file does not exist. Please try entering the path again.\n"
		START
	fi

	# Create the directory structure for the forensic case files
	printf "${CYAN}"
	echo -e "Creating a directory for the case...\n"
	printf "${STOP}"
	mkdir $HOME/forensic_case $HOME/forensic_case/binwalk $HOME/forensic_case/bulk_extractor $HOME/forensic_case/foremost $HOME/forensic_case/volatility $HOME/forensic_case/strings> /dev/null 2>&1
	INSTALL_FORENSICS
}

START
