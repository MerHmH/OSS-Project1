#! /bin/bash
if [ $# -ne 3 ]
then
	echo "uage: ./proj1_12191691_hanminho.sh file1 file2 file3"
	exit 1
fi

if ! [[ -f "$1" && -f "$2" && -f "$3" ]];
then
		echo "uage: ./proj1_12191691_hanminho.sh file1 file2 file3 (something is not file)"
	exit 1
fi

if ! [[ "$1" =~ \.csv$ && "$2" =~ \.csv$ && "$3" =~ \.csv$ ]];
then
		echo "uage: ./proj1_12191691_hanminho.sh file1 file2 file3 (csv file)"
	exit 1
fi 
echo " "
echo "**********OSS1 - Project1 **********"
echo "*       StudentID : 12191691       *"
echo "*         Name : Minho Han         *"
echo "************************************"
echo " "
stop="N"
until [ "$stop" = "Y" ]; do

	echo "[MENU]"
	echo "1. Get the data of Heung-Min Son's Current Club, Appearances, Goals, Assists in players"
	echo "2. Get the team data to enter a league position in teams.csv"
	echo "3. Get the Top-3 Attendance matches in matches.csv"
	echo "4. Get the team's league position and team's top scorer in teams.csv & players.csv"
	echo "5. Get the modified format of date_GMT in matches.csv"
	echo "6. Get the data of the winning team by the largest difference on home stadium in teams.csv& matches.csv"
	echo "7. Exit"

	read -p  "Enter your CHOICE (1~7) : " choice
	case "$choice" in
	1) 
		read -p "Do you want to get the Heung-Min Son's data? (y/n):" number1
		if [ "$number1" = y ]; 
		then 
			echo "Son's Current Club, Appearances, Goals, Assists"
			cat players.csv | awk -F "," '$1=="Heung-Min Son"{print "Team:"$4",Appearances:"$6",Goals:"$7",Assists:"$8}'
			echo " "
		else
			echo " "
		fi
		;;
	2) 
		read -p "Do you want to get the team data of league_position[1~20]:" number2
		cat teams.csv | awk -v num2=$number2 -F "," '$6==num2{print $6, $1, $2/($2+$3+$4)}'
		echo " "
		;;
	3) 
		read -p "Do you want to know Top-3 attendance data? (y/n):" number3
		if [ "$number3" = y ];
		then
			echo "***Top-3 Attendance Matches***"
			awk -F ',' '{print $2 "," $0}' matches.csv | sort -t',' -k1nr | cut -d',' -f2- | head -n 3 | awk -F "," '{print $3" vs "$4 "("$1")\n"$2,$7"\n"}'
		else
			echo " "
		fi
		;;
	4) 
		read -p "Do you want to get each team's ranking and the highest-scoring player? (y/n):" number4
		if [ "$number4" = y ];
		then 
			IFS=$'\n' read -d '' -r -a teams_array < <(tail -n +2 teams.csv | sort -t',' -k6,6n)

			declare -A max_goals

			for team_info in "${teams_array[@]}"; 
			do
    			IFS=',' read -r -a team_data <<< "$team_info"
    			team_name="${team_data[0]}"
  			  	max_player_info=$(grep "$team_name" players.csv | sort -t',' -k7,7nr | head -n 1)
    			IFS=',' read -r -a player_data <<< "$max_player_info"
    			player_name="${player_data[0]}"
    			player_goals="${player_data[6]}"
    			max_goals["$team_name"]="$player_name $player_goals"
			done

			for team_info in "${teams_array[@]}"; 
			do
    			IFS=',' read -r -a team_data <<< "$team_info"
    			team_name="${team_data[0]}"
    			team_league_position="${team_data[5]}"
    			max_player_info="${max_goals["$team_name"]}"
   				echo "$team_league_position $team_name"
    			echo "$max_player_info"
    			echo " "
			done
		fi
		;;
	5) 
		read -p "Do you want to modify the format of date? (y/n):" number5
		if [ "$number5" = y ];
		then
			sed -E 's/Jan/01/;s/Feb/02/;s/Mar/03/;s/Apr/04/;s/May/05/;s/Jun/06/;s/Jul/07/;s/Aug/08/;s/Sep/09/;s/Oct/10/;s/Nov/11/;s/Dec/12/' matches.csv | awk -F "," '{print "[" substr($1, 7, 4) "/" substr($1, 1, 2) "/" substr($1, 4, 2) "/" substr($1, 14, 4) substr($1, 18) "]" }' | head -n 11 | tail -n 10
			echo " "
		else
			echo " "
		fi
		;;
	6) 	
		cat teams.csv | awk -F "," 'NR>=2 {print NR-1")"$1}'
		read -p "Enter your team number:" number6
		echo " "
		team_name=$(cat teams.csv | awk -v num6=$((number6+1)) -F "," 'NR==num6 {print $1}' )
		maxgoal=$(cat matches.csv | awk -v team="$team_name" -F "," '$3==team && $5-$6>0{print $5-$6}' | sort -k1nr | head -n 1)
		cat matches.csv | awk -v team="$team_name" -v goalcha=$maxgoal -F "," '$3==team && $5-$6 == goalcha {print $1"\n"$3,$5,"vs",$6,$4"\n"}'
		;;
	7)	echo "Bye!"
		stop="Y" ;;
	esac
done