﻿FUNCTION Show-MessageBox
{

    <#
            .SYNOPSIS
            Show a message box on a seperate thread

            .DESCRIPTION
            Allows you to show a custom title, and message while another task is running - can also choose to show an OK button, for acknowledgement

            .PARAMETER Title
            Set the title of the form, which contains the message box

            .PARAMETER InitialMessage
            Set the initial text of the message box

            .PARAMETER ShowOkButton
            Shows an OK button, if a status/update requires acknowledgement

            .EXAMPLE
            Show-MessageBox -Title 'Warning' -InitialMessage 'Low Disk Space!' -ShowOkButton

            .EXAMPLE
            Show-MessageBox -Title 'Hello' -InitialMessage 'World'
    #>


    PARAM(
        [Parameter(Mandatory = $true, Position = 0)]
        $Title,

        [Parameter(Mandatory = $false)]
        $InitialMessage,

        [Parameter()]
        [switch]$ShowOkButton
    )

    TRY
    { 
        $Script:MessageBox           = [Hashtable]::Synchronized(@{})
        $Script:MessageBox.IsRunning = $true       
        $Script:MessageBox.TheTitle  = $Title 
        IF ($ShowOkButton) {
            $Script:MessageBox.ShowOKButton = $true
        }
        IF ($InitialMessage) {
            $Script:MessageBox.InitialMessage = $InitialMessage
        }

        $RunSpace                    = [Management.Automation.Runspaces.RunspaceFactory]::CreateRunspace()
        $RunSpace.ApartmentState     = "STA"
        $RunSpace.ThreadOptions      = "ReuseThread"
        $RunSpace.Name               = "MessageBox"
        $RunSpace.Open()
        $RunSpace.SessionStateProxy.SetVariable("MessageBox",$MessageBox)        

        $PowerShellCmd               = [Management.Automation.PowerShell]::Create().AddScript({

                [void][reflection.assembly]::Load('System.Windows.Forms, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
                [void][reflection.assembly]::Load('System.Data, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
                [void][reflection.assembly]::Load('System.Drawing, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')

                [System.Windows.Forms.Application]::EnableVisualStyles()
                $Script:MessageBox.form1                            = New-Object 'System.Windows.Forms.Form'
                $Script:MessageBox.textbox1                         = New-Object 'System.Windows.Forms.TextBox'
                $Script:MessageBox.buttonOK                         = New-Object 'System.Windows.Forms.Button'
                $InitialFormWindowState                             = New-Object 'System.Windows.Forms.FormWindowState'

                $Script:MessageBox.form1.SuspendLayout()

                $Script:MessageBox.form1.Controls.Add($Script:MessageBox.textbox1)
                IF ($Script:MessageBox.ShowOkButton){ $Script:MessageBox.form1.Controls.Add($Script:MessageBox.buttonOK) }
                $Script:MessageBox.form1.AcceptButton               = $Script:MessageBox.buttonOK
                $Script:MessageBox.form1.AutoScaleDimensions        = '6, 13'
                $Script:MessageBox.form1.AutoScaleMode              = 'Font'
                $Script:MessageBox.form1.ClientSize                 = '284, 262'
                $Script:MessageBox.form1.FormBorderStyle            = 'FixedDialog'
                $Script:MessageBox.form1.MaximizeBox                = $False
                $Script:MessageBox.form1.MinimizeBox                = $False
                $Script:MessageBox.form1.Name                       = 'MBF1form1'
                $Script:MessageBox.form1.StartPosition              = 'CenterScreen'
                $Script:MessageBox.form1.Text                       = $Script:MessageBox.TheTitle                 

                $Script:MessageBox.textbox1.BackColor               = 'White'
                $Script:MessageBox.textbox1.BorderStyle             = 'FixedSingle'
                $Script:MessageBox.textbox1.Location                = '12, 12'
                $Script:MessageBox.textbox1.Multiline               = $True
                $Script:MessageBox.textbox1.Name                    = 'MBF1textbox1'
                $Script:MessageBox.textbox1.ReadOnly                = $True
                $Script:MessageBox.textbox1.Size                    = '260, 209'
                $Script:MessageBox.textbox1.TabIndex                = 1

                IF ($Script:MessageBox.InitialMessage){ $Script:MessageBox.textbox1.Text = $Script:MessageBox.InitialMessage }
                IF (-not $($Script:MessageBox.InitialMessage)){ $Script:MessageBox.textbox1.Text = '' }

                $Script:MessageBox.buttonOK.Anchor                  = 'Bottom, Right'
                $Script:MessageBox.buttonOK.DialogResult            = 'OK'
                $Script:MessageBox.buttonOK.Location                = '197, 231'
                $Script:MessageBox.buttonOK.Name                    = 'MBF1buttonOK'
                $Script:MessageBox.buttonOK.Size                    = '75, 23'
                $Script:MessageBox.buttonOK.TabIndex                = 0
                $Script:MessageBox.buttonOK.Text                    = '&OK'
                $Script:MessageBox.buttonOK.UseVisualStyleBackColor = $True
                $Script:MessageBox.form1.ResumeLayout()

                #Save the initial state of the form
                $InitialFormWindowState                             = $Script:MessageBox.form1.WindowState
                #Init the OnLoad event to correct the initial state of the form
                $Script:MessageBox.form1.add_Load({
                        $Script:MessageBox.form1.WindowState = $InitialFormWindowState
                })
                #Clean up the control events
                $Script:MessageBox.form1.add_FormClosed({
                        $Script:MessageBox.form1.remove_Load($Script:MessageBox.form1_Load)
                        $Script:MessageBox.form1.remove_Load($Form_StateCorrection_Load)
                        $Script:MessageBox.form1.remove_FormClosed($Form_Cleanup_FormClosed)
                })
                #Show the Form
                $Script:MessageBox.form1.ShowDialog()                

        })

        $PowerShellCmd.Runspace      = $RunSpace
        [void]$PowerShellCmd.BeginInvoke()
    }

    CATCH
    {
        $_
    }

}