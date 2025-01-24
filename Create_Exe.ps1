Import-Module ps2exe

$Version = '1.1.0'

$Spalt = @{
	inputFile   = '.\Script.ps1'
	outputFile  = ".\PowerPack Password Encryptor $Version.exe"
	title       = 'PowerPack Password Encrypte/Decrypter'
	description = 'Used to encrypt and decrypt passwords that you use in PowerPack Scripts'
	company     = 'Mark5900'
	version     = $Version
}

Invoke-ps2exe @Spalt -noConsole -noOutput -noError -noVisualStyles