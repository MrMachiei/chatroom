#!/bin/bash
wielka=0
if [ "$1" == "-UPPER" ]
then
	wielka=1
	shift 1
elif [ "$2" == "-UPPER" ]
then
	wielka=1
fi
if [ $# -lt 1 ]
then
	echo "Błąd składni, podaj katalog!"
	exit 1
elif [ -d $1 ]
then

	
	#tworzenie katalogu dla chatow
	if ! [ -d "$1/usr" ]
	then
		`mkdir "$1/usr"`
                `chmod 777 "$1/usr"`
	fi
	
	#tworzenie nickow

	nick=""
	if [ -f "$1/usr/users.txt" ]
	then
		users=`cat "$1/usr/users.txt"`
	else 
		`touch "$1/usr/users.txt"`
		`chmod 777 "$1/usr/users.txt"`
	fi

	#logowanie

	while [ -z $nick ]
	do
		echo -n "Podaj swój nick: "
		read nick
		users=`cat "$1/usr/users.txt"`
		if [ -z "$users" ]
		then
			`echo $nick >> "$1/usr/users.txt"`
		else
			for i in $users
			do
				if [ "$i" == "$nick" ]
				then
					echo "Użytkownik istnieje, podaj inny nick!"
					nick=""
				else
					`echo -n "$nick " >> "$1/usr/users.txt"`
				fi
			done
		fi
	done

	#tworzenie pokoju
	
	if ! [ -d "$1/rooms" ]
        then
                `mkdir "$1/rooms"`
                `chmod 777 "$1/rooms"`
        fi
	if ! [ -d "$1/prv" ]
        then
                `mkdir "$1/prv"`
                `chmod 777 "$1/prv"`
        fi
	
	#tworzenie prywatnej skrzynki
	
       	`touch "$1/prv/$nick.txt"`
       	`chmod 777 "$1/prv/$nick.txt"`

	#menu
	czy=1
	while [ $czy -eq 1 ]
	do
		echo "-------MENU-------"
		select opt in "Stwórz pokój" "Wejdź do pokoju" "Odśwież wiadomości w pokoju" "Odbierz wiadomości prywatne" "Wyślij wiadomość do aktualnego pokoju" "Wyślij wiadomość prywatną" "Zakończ"
		do
			case $opt in
				"Stwórz pokój")
					echo -n "Podaj nazwę pokoju: "
				  	read name
					if [ -f "$1/rooms/$name.txt" ]					
					then
						echo "Taki pokój istnieje!"
					else
						`touch "$1/rooms/$name.txt"`
                				`chmod 777 "$1/rooms/$name.txt"`
					fi
					;;
				"Wejdź do pokoju")
					pokoje=`ls "$1/rooms"| cut -d "." -f1| tr " " "\n"`
					if [ -z "$pokoje" ]
					then 
						echo "Brak pokoi."
					else
						echo "Lista dostępnych pokoi: "
						echo -e "$pokoje"
						teraz=""
						echo -n "Wybierz pokój: "
						read teraz
						if ! [ -f "$1/rooms/$teraz.txt" ]
						then
							echo "Pokój nie istnieje!"
							teraz=""
						fi
					fi
					;;
				"Odśwież wiadomości w pokoju")
					if [ -z "$teraz" ]
					then
						echo "Nie jesteś w pokoju!"
					else
						echo "Wiadomości w pokoju $teraz"
						wiad=`cat "$1/rooms/$teraz.txt"`
						if [ $wielka -eq 1 ]
						then
							wiad=`echo $wiad | tr [a-z] [A-Z]`
						fi
						echo -e "`echo $wiad | tr "~" "\n"`"
					fi
					;;
				"Odbierz wiadomości prywatne")
					priv=`cat "$1/prv/$nick.txt"`
					if [ -z "$priv" ]
					then
						echo "Brak nowych wiadomości prywatnych"
					else
						echo "Wiadomości prywtane:"
						wiad=`cat "$1/prv/$nick.txt"`
						if [ $wielka -eq 1 ]
                                                then
                                                        wiad=`echo $wiad | tr [a-z] [A-Z]`
                                                fi
                                                echo -e "`echo $wiad | tr "~" "\n"`"
						`echo "" > "$1/prv/$nick.txt"`
					fi
					;;
				"Wyślij wiadomość do aktualnego pokoju")
					if [ -z "$teraz" ]
                                        then    
                                                echo "Nie jesteś w pokoju!"
                                        else    
                                                echo "Podaj wiadomość: "
						read mess
						czas=`date +%H:%M`
						`echo -n -e "$nick ($czas):\n$mess~" >>  "$1/rooms/$teraz.txt"`
                                        fi      
					;;
				"Wyślij wiadomość prywatną")
					dost=`cat "$1/usr/users.txt"`
					dost=`echo $dost | tr " " "\n"`
					echo -e "Dostępni użytkownicy:\n$dost"
					echo "Do kogo: "
					read kto
					if [ -f "$1/prv/$kto.txt" ]
					then
						echo "Podaj wiadomość: "
                                                read mess
                                                czas=`date +%H:%M`
                                                `echo -n -e "$nick ($czas):\n$mess~" >>  "$1/prv/$kto.txt"`
					else
						echo "Użytkownik nie jest zalogowany!"
					fi
					;;
				"Zakończ") czy=0;;
			esac
			break
		done
	done
	#wylogowany - usuwamy użytkownika

	`touch temp.txt`
	`chmod 777 temp.txt`
	users=`cat "$1/usr/users.txt"`
	for i in $users
	do
		if [ "$i" == "$nick" ]
		then
			continue
		fi
		`echo -n "$i " >> temp.txt`
	done
	`mv temp.txt  "$1/usr/users.txt"`
	`rm "$1/prv/$nick.txt"`
else
	echo "Katalog nie istnieje!"
fi
