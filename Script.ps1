Add-Type -AssemblyName 'System.Windows.Forms'

# Create form
$form = New-Object System.Windows.Forms.Form
$form.Text = 'PowerPack - Encrypt / Decrypt Password'
$form.Size = New-Object System.Drawing.Size(700, 250)
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.MinimizeBox = $false

# Create labels
$textBoxLength = $form.Width - 25
$passwordLabel = New-Object System.Windows.Forms.Label
$passwordLabel.Text = 'Password:'
$passwordLabel.Location = New-Object System.Drawing.Point(50, 0)
$passwordLabel.Size = New-Object System.Drawing.Size(200, 20)

$encryptionKeyLabel = New-Object System.Windows.Forms.Label
$encryptionKeyLabel.Text = 'Encryption Key:'
$encryptionKeyLabel.Location = New-Object System.Drawing.Point(50, 50)
$encryptionKeyLabel.Size = New-Object System.Drawing.Size(200, 20)

$encryptedPasswordLabel = New-Object System.Windows.Forms.Label
$encryptedPasswordLabel.Text = 'Encrypted Password:'
$encryptedPasswordLabel.Location = New-Object System.Drawing.Point(50, 100)
$encryptedPasswordLabel.Size = New-Object System.Drawing.Size(200, 20)

# Create textboxes
$textBoxLength = $form.Width - 100
$passwordTextBox = New-Object System.Windows.Forms.TextBox
$passwordTextBox.Size = New-Object System.Drawing.Size($textBoxLength, 20)
$passwordTextBox.Location = New-Object System.Drawing.Point(50, 20)

$encryptionKeyTextBox = New-Object System.Windows.Forms.TextBox
$encryptionKeyTextBox.Size = New-Object System.Drawing.Size($textBoxLength, 20)
$encryptionKeyTextBox.Location = New-Object System.Drawing.Point(50, 70)

$encryptedPasswordTextBox = New-Object System.Windows.Forms.TextBox
$encryptedPasswordTextBox.Size = New-Object System.Drawing.Size($textBoxLength, 20)
$encryptedPasswordTextBox.Location = New-Object System.Drawing.Point(50, 120)

# Create buttons
$encryptButton = New-Object System.Windows.Forms.Button
$encryptButton.Text = 'Encrypt'
$encryptButton.Size = New-Object System.Drawing.Size(100, 30)
$y = $form.Height - $encryptButton.Height - 50
$encryptButton.Location = New-Object System.Drawing.Point(50, $y)

$decryptButton = New-Object System.Windows.Forms.Button
$decryptButton.Text = 'Decrypt'
$decryptButton.Size = New-Object System.Drawing.Size(100, 30)
$y = $form.Height - $decryptButton.Height - 50
$decryptButton.Location = New-Object System.Drawing.Point(200, $y)

# Functions
function Encrypt-Password {
	$password = $passwordTextBox.Text.Trim()
	$encryptionKey = $encryptionKeyTextBox.Text.Trim()
	$key = New-Object Byte[] 32

	if ([string]::IsNullOrWhiteSpace($password)) {
		[System.Windows.Forms.MessageBox]::Show('Please enter a password.')
		return
	}

	if ([string]::IsNullOrWhiteSpace($encryptionKey)) {
		[Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($key)
		$encryptionKeyTextBox.Text = [System.BitConverter]::ToString($key) -replace '-', ','
	} else {
		$key = $encryptionKey -split ',' | ForEach-Object { [Convert]::ToByte($_, 16) }
	}

	$passwordAsSecureString = ConvertTo-SecureString -String $password -AsPlainText -Force
	$encryptedPassword = ConvertFrom-SecureString -SecureString $passwordAsSecureString -Key $key

	$encryptedPasswordTextBox.Text = $encryptedPassword
}

function Decrypt-Password {
	$encryptedPassword = $encryptedPasswordTextBox.Text.Trim()
	$encryptionKey = $encryptionKeyTextBox.Text.Trim()

	if ([string]::IsNullOrWhiteSpace($encryptedPassword) -or [string]::IsNullOrWhiteSpace($encryptionKey)) {
		[System.Windows.Forms.MessageBox]::Show('Please enter both encrypted password and encryption key.')
		return
	}

	try {
		$key = $encryptionKey -split ',' | ForEach-Object { [Convert]::ToByte($_, 16) }
		$encryptedPasswordAsSecureString = $encryptedPassword | ConvertTo-SecureString -Key $key
		$bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($encryptedPasswordAsSecureString)
		$decryptedPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)

		$passwordTextBox.Text = $decryptedPassword
	} catch {
		[System.Windows.Forms.MessageBox]::Show('Failed to decrypt the password. Please check the encryption key and encrypted password.')
	}
}

# Button click events
$encryptButton.Add_Click({
		Encrypt-Password
	})

$decryptButton.Add_Click({
		Decrypt-Password
	})

# Add KeyDown event handler to textboxes
$passwordTextBox.Add_KeyDown({
		param($sender, $e)
		if ($e.Control -and $e.KeyCode -eq [System.Windows.Forms.Keys]::A) {
			$sender.SelectAll()
			$e.SuppressKeyPress = $true
		}
		if ($e.KeyCode -eq [System.Windows.Forms.Keys]::Enter) {
			Encrypt-Password
		}
	})

$encryptionKeyTextBox.Add_KeyDown({
		param($sender, $e)
		if ($e.Control -and $e.KeyCode -eq [System.Windows.Forms.Keys]::A) {
			$sender.SelectAll()
			$e.SuppressKeyPress = $true
		}
		if ($e.KeyCode -eq [System.Windows.Forms.Keys]::Enter) {
			if ([string]::IsNullOrWhiteSpace($passwordTextBox.Text)) {
				Decrypt-Password
			} else {
				Encrypt-Password
			}
		}
	})

$encryptedPasswordTextBox.Add_KeyDown({
		param($sender, $e)
		if ($e.Control -and $e.KeyCode -eq [System.Windows.Forms.Keys]::A) {
			$sender.SelectAll()
			$e.SuppressKeyPress = $true
		}
		if ($e.KeyCode -eq [System.Windows.Forms.Keys]::Enter) {
			Decrypt-Password
		}
	})

# Add controls to form
$form.Controls.Add($passwordLabel)
$form.Controls.Add($encryptionKeyLabel)
$form.Controls.Add($encryptedPasswordLabel)
$form.Controls.Add($passwordTextBox)
$form.Controls.Add($encryptionKeyTextBox)
$form.Controls.Add($encryptedPasswordTextBox)
$form.Controls.Add($encryptButton)
$form.Controls.Add($decryptButton)

$form.ShowDialog()