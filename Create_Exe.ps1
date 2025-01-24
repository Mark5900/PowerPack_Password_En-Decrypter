Import-Module ps2exe

$Spalt = @{
	inputFile   = '.\Script.ps1'
	outputFile  = '.\PowerPack Password Encryptor.exe'
	title       = 'PowerPack Password Encrypte/Decrypter'
	description = 'Used to encrypt and decrypt passwords that you use in PowerPack Scripts'
	company     = 'Mark5900'
	version     = '1.0.0'
}

Invoke-ps2exe @Spalt -noConsole -noOutput -noError -noVisualStyles