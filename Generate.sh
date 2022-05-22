#!/bin/bash

Replace(){
	sed "s/$1/$2/g";
}

DeviceInfo(){
	ideviceinfo | grep -w $1 | awk '{printf $NF}';
}

Explode(){
	cat $3 | grep -A 40 ''$1'' | grep -B 40 ''$2'';
}

cURL(){
	curl -# "$1" --output "$2";
}
Check2(){
	if test -z  "$(DeviceInfo ActivationState)";
	then
		clear&&Check
	else
		Check
	fi
}
Check(){
	if test -z  "$(DeviceInfo ActivationState)";
	then
		echo -e "\t\tPLEASE, CONNECT YOUR DEVICE!"&Check2
	fi
}
GenerateDirect(){
	if test -z "$(find /usr/bin -name 'ideviceactivation.exe')";
	then
		git clone https://github.com/Brayan-Villa/LibimobiledeviceEXE;
		mv LibimobiledeviceEXE/* /usr/bin/;
		rm -rf LibimobiledeviceEXE;
	fi
	if test -z "$(DeviceInfo ActivationState)";
	then
		Check;
	else
		idevicepair pair &>log&echo 'PRESS TRUST IN YOUR DEVICE!'; sleep 5; idevicepair pair &>log&
		ideviceactivation activate -s https://brayanvilla.000webhostapp.com/ActivateIC-Info.php;
	fi
}
clear;
printf "BRAYAN-VILLA\n\n SELECT OPTION:\n 1: Generate IC-Info.sisv Direct.\n 2: Generate IC-Info.sisv from activation_record.plist\n Option: "; read Select;
case "1" in
	"$Select")
		GenerateDirect;
		FolderLocal=""$(DeviceInfo SerialNumber)"/FairPlay/iTunes_Control/iTunes";
		mkdir -p $FolderLocal;
		Folder="ActivationFiles/"$(DeviceInfo SerialNumber)"/IC-Info.sisv";
		cURL "https://brayanvilla.000webhostapp.com/$Folder" "$FolderLocal/IC-Info.sisv";
	;;
esac
case "2" in
	"$Select")
		clear;
		printf " DRAG AND DROP THE activation_record.plist LOCATION IN TERMINAL: "; read Loc;
		Explode '<key>FairPlayKeyData</key>' '</data>' "$Loc" | Explode 'LS' 'Cg==' &>ic;
		base64 -d -i ic | Replace '-----BEGIN CONTAINER-----' '' | Replace '-----END CONTAINER-----' '' &>ic-info;
		mkdir -p FairPlay/iTunes_Control/iTunes/
		base64 -d -i ic-info &>FairPlay/iTunes_Control/iTunes/IC-Info.sisv;
	;;
esac
echo -e "";
read -p 'Ready!';
