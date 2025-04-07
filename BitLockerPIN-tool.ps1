Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function Show-CustomMessage {
    param (
        [string]$title,
        [string]$message
    )

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "$title 🔑"
    $form.StartPosition = "CenterScreen"
    $form.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $form.AutoSize = $true
    $form.AutoSizeMode = "GrowAndShrink"
    $form.FormBorderStyle = "FixedDialog"
    $form.MaximizeBox = $false
    $form.MinimizeBox = $false
    $form.Padding = '20,20,20,20'
    $form.TopMost = $true

    $label = New-Object System.Windows.Forms.Label
    $label.Text = $message
    $label.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $label.AutoSize = $true
    $label.MaximumSize = New-Object System.Drawing.Size(450, 0)
    $label.TextAlign = "TopLeft"

    $button = New-Object System.Windows.Forms.Button
    $button.Text = "Tamam"
    $button.Font = New-Object System.Drawing.Font("Segoe UI", 9)
    $button.AutoSize = $true
    $button.Anchor = "Bottom"
    $button.Add_Click({ $form.Close() })

    $flowLayout = New-Object System.Windows.Forms.FlowLayoutPanel
    $flowLayout.FlowDirection = "TopDown"
    $flowLayout.Dock = "Fill"
    $flowLayout.WrapContents = $false
    $flowLayout.AutoSize = $true
    $flowLayout.AutoSizeMode = "GrowAndShrink"
    $flowLayout.Controls.AddRange(@($label, $button))

    $form.Controls.Add($flowLayout)
    $form.ShowDialog()
}

function Show-InfoBox {
    $msg = @"
Yeni BitLocker PIN’inizi ayarlamak üzeresiniz.

Lütfen aşağıdaki kurallara uyun:
• PIN 6-20 karakter uzunluğunda olmalıdır
• Harf, rakam ve özel karakter içerebilir
• Sıralı (1234) veya tekrar eden (1111) PIN’lerden kaçının
"@
    Show-CustomMessage -title "Bilgilendirme" -message $msg
}

function Prompt-ForPIN {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "BitLocker PIN Ayarla  🔑"
    $form.Font = New-Object System.Drawing.Font("Segoe UI", 9)
    $form.StartPosition = "CenterScreen"
    $form.FormBorderStyle = "FixedDialog"
    $form.MaximizeBox = $false
    $form.MinimizeBox = $false
    $form.TopMost = $true
    $form.AutoSize = $true
    $form.AutoSizeMode = "GrowAndShrink"
    $form.Padding = '20,20,20,20'

    $label1 = New-Object System.Windows.Forms.Label
    $label1.Text = "Yeni PIN:"
    $label1.AutoSize = $true

    $textbox1 = New-Object System.Windows.Forms.TextBox
    $textbox1.Width = 400
    $textbox1.UseSystemPasswordChar = $true

    $label2 = New-Object System.Windows.Forms.Label
    $label2.Text = "PIN Tekrar:"
    $label2.AutoSize = $true

    $textbox2 = New-Object System.Windows.Forms.TextBox
    $textbox2.Width = 400
    $textbox2.UseSystemPasswordChar = $true

    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Text = "PIN’i Ayarla"
    $okButton.AutoSize = $true
    $okButton.Font = New-Object System.Drawing.Font("Segoe UI", 9)
    $okButton.Add_Click({
        if ([string]::IsNullOrWhiteSpace($textbox1.Text)) {
            Show-CustomMessage -title "Hata" -message "PIN boş olamaz. Lütfen geçerli bir PIN girin."
        }
        elseif ($textbox1.Text -ne $textbox2.Text) {
            Show-CustomMessage -title "Hata" -message "PIN’ler uyuşmuyor. Lütfen tekrar deneyin."
        }
        elseif ($textbox1.Text.Length -lt 6 -or $textbox1.Text.Length -gt 20) {
            Show-CustomMessage -title "Hata" -message "PIN uzunluğu 6 ile 20 karakter arasında olmalıdır."
        }
        else {
            $form.Tag = $textbox1.Text
            $form.Close()
        }
    })

    $layout = New-Object System.Windows.Forms.FlowLayoutPanel
    $layout.FlowDirection = "TopDown"
    $layout.Dock = "Fill"
    $layout.WrapContents = $false
    $layout.AutoSize = $true
    $layout.AutoSizeMode = "GrowAndShrink"
    $layout.Controls.AddRange(@($label1, $textbox1, $label2, $textbox2, $okButton))

    $form.Controls.Add($layout)
    $form.ShowDialog()

    return $form.Tag
}

function Set-BitLockerPIN {
    param(
        [string]$pin
    )

    if ([string]::IsNullOrWhiteSpace($pin)) {
        return
    }

    try {
        $volume = Get-BitLockerVolume -MountPoint "C:"
        $tpmProtectors = $volume.KeyProtector | Where-Object { $_.KeyProtectorType -eq "TpmPin" }

        if ($tpmProtectors.Count -gt 0) {
            $id = $tpmProtectors[0].KeyProtectorId
            manage-bde -protectors -delete C: -id $id | Out-Null
        }

        manage-bde -protectors -add C: -TPMAndPIN $pin | Out-Null

        $newProtectors = (Get-BitLockerVolume -MountPoint "C:").KeyProtector | Where-Object { $_.KeyProtectorType -eq "TpmPin" }
        if ($newProtectors.Count -gt 0) {
            Show-CustomMessage -title "Başarılı" -message "PIN başarıyla değiştirildi."
        } else {
            throw "PIN koruyucu eklenemedi."
        }
    }
    catch {
        Show-CustomMessage -title "Hata" -message "PIN değiştirilemedi: $_"
    }
}

# Başlatıcı
Show-InfoBox
$pin = Prompt-ForPIN
if ($pin) {
    Set-BitLockerPIN -pin $pin
}
