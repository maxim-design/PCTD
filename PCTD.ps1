

Function Loadsaved { 
                    $global:errOutput2 = $($secretStuff = Get-Content  -Path $PCTDFOLDER\PCTDTool.cfg | ConvertTo-SecureString -key $key) 2>&1
                     if ($global:errOutput2 -eq $Null) {
                                        ($LoadedData = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR((($secretStuff)))) | ConvertFrom-Json)
                                                $objButton1Box.Text = $LoadedData.Folder
                                                $objButton2Box.Text = $LoadedData.File
                                                $objButton3Box.Text = $LoadedData.Count
                                                $objButton4Box.Text = $LoadedData.Name 
                                                $Global:Targetname  = $objButton4Box.Text
                                                $Global:targetpath  = $objButton1Box.Text
                                                $Global:counter     = $objButton3Box.Text
                                                $Global:sourcefile  = $objButton2Box.Text
                          
                                            $CurrentSetupbox.Text =
                                                "`n",
                                                "The current setup is:", "`r`n",
                                                "`r`n",
                                                "Folder:  ", $objButton1Box.Text, "`r`n",
                                                "File:         ", $objButton2Box.Text, "`r`n",
                                                "Copies:   ", $objButton3Box.Text,"`r`n", 
                                                "Name:    ", $objButton4Box.Text,"`r`n" 

                                            "The current setup is:" | foreach {
                                                $oldFont =  $CurrentSetupbox.Font
                                                $font = New-Object System.Drawing.Font("Lucida Calligraphy", 10,[System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold -bor [System.Drawing.FontStyle]::Underline))
                                                $string = $_
                                                $CurrentSetupbox.SelectionStart = $CurrentSetupbox.Text.IndexOf($string)
                                                $CurrentSetupbox.SelectionLength = $string.length
                                                $CurrentSetupbox.SelectionFont = $font
                                                $CurrentSetupbox.SelectionColor = [Drawing.Color]::DarkBlue
                                                $CurrentSetupbox.DeselectAll()}
                                            "Folder:",
                                            "File:",
                                            "Copies:",
                                            "Name:" | foreach {
                                                $oldFont =  $CurrentSetupbox.Font
                                                $font = New-Object System.Drawing.Font("Lucida Calligraphy", 10,[System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold -bor [System.Drawing.FontStyle]::Underline)) 
                                                $string = $_
                                                $CurrentSetupbox.SelectionStart = $CurrentSetupbox.Text.IndexOf($string)
                                                $CurrentSetupbox.SelectionLength = $string.length
                                                $CurrentSetupbox.SelectionFont = $font
                                                $CurrentSetupbox.SelectionColor = [Drawing.Color]::DarkBlue
                                                $CurrentSetupbox.DeselectAll()
                                                }
                                
                          }
                    else
                        { 
                           }

                    }

Function clean-up
 {
 if ((test-path $sourcefile -PathType Leaf) -eq "True") 
                          {
                            $target = $targetpath
                            $global:FolderList = Get-childitem $target -Directory -Name "*$TargetName*"  # $Targetname
                            if ($global:FolderList -eq $Null) {"No directories with the name:$TargetName exist. Nothing to remove .","`r`n"} else {
                            $global:FolderList | ForEach-Object {    
                            $Folder_object = $target + "\" + $_
                            "Removing directory: $Folder_object ............. "
                            Remove-Item -Recurse -force $Folder_object -ErrorAction SilentlyContinue 
                            $ia = Test-Path -Path $Folder_object
                            if ($ia -eq "True") { "Error. Unable to remove path ","`r`n"} else {"Remove successfull.","`r`n"}
                             }}
                             } else { [Microsoft.VisualBasic.Interaction]::MsgBox('Cannot find install pack file. Source file is missing or have been moved since last saved configuration. :(','OKOnly,SystemModal,Critical','PCTD Tool')
                                      $script:CHKFLE = "Bad"
                                     }
 }


 Function new-dir
 { 
 1..$counter | ForEach {
                        "Creating directory: $targetpath\$TargetName$_ ............. "
                        $Script:tmpfilename = Split-Path $sourcefile -leaf
                        $temppath =  MD "$targetpath\$TargetName$_\$TargetName"
                        Copy-Item $sourcefile -Destination $temppath\$tmpfilename
                        $ib = Test-Path -Path "$temppath\$tmpfilename" -PathType Leaf
                        if ($ib -eq "True") {"Successfully created.","`r`n"} else {"Error. Folder was not created.","`r`n"}
                       
 }
  }






 Function extract {
                   $resoultbox.BackColor = "#012456"
                   $resoultbox.ForeColor = "White"
                   $progressbox.BackColor = "#012456"
                   $progressbox.ForeColor = "White"
                   1..$counter | ForEach {
                        $progressbox.Text ="Progress: " 
                        "Progress:" | foreach {
                        $oldFont =  $progressbox.Font
                        $font = New-Object System.Drawing.Font("Times New Roman", 8,[System.Drawing.FontStyle]([System.Drawing.FontStyle]::Underline))
                        $string = $_
                        $progressbox.SelectionStart = $progressbox.Text.IndexOf($string)
                        $progressbox.SelectionLength = $string.length
                        $progressbox.SelectionFont = $font
                        $progressbox.SelectionColor = [Drawing.Color]::White
                        $progressbox.DeselectAll() } 
                        $temppath = "$targetpath\$TargetName$_\$TargetName"
                        Push-Location -Path $temppath
                        $resoultbox.Text += "Extracting [$temppath\$tmpfilename]: " #,"`r`n"
                            & .\$tmpfilename "-y" | out-string -stream | ForEach-Object {$_}| foreach {
                            [System.Console]::SetCursorPosition(0, [System.Console]::CursorTop)
                            $tf = $_ | Add-Content -path $tempfolder\extraction.tmp | Select-String -Pattern "\d{1,3}%" -AllMatches | ForEach-Object {$_.Matches.Value } | Foreach {
                            if ($progressbox.Lines -Match  "\d{1,3}%" ) { $progressbox.Lines = $progressbox.Lines -replace "\d{1,3}%", $_ }
                            else {$progressbox.Text += $_}}
                            #$resoultbox.Text += $_ 
                            $resoultbox.SelectionStart = $resoultbox.TextLength;
                            $resoultbox.ScrollToCaret()
                            [System.Windows.Forms.Application]::DoEvents()
                                         } 
                        $resoultbox.Text += " Done.","`r`n"         
                        Pop-Location
                                            }
                            
  
}




Function Deploy {

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName Microsoft.VisualBasic


$UserFolder = $env:USERPROFILE # \AppData\Local

if (Test-Path -Path $UserFolder\AppData\Local\PCTD\Configuration) 
        { $PCTDFOLDER = "$UserFolder\AppData\Local\PCTD\Configuration"
            }
        else
        {  MD $UserFolder\AppData\Local\PCTD\Configuration
           $PCTDFOLDER = "$UserFolder\AppData\Local\PCTD\Configuration"
             }
if (Test-Path -path $PCTDFOLDER\Logs)
        { } else { MD $PCTDFOLDER\Logs}




# defines all objects on the form
$Form = New-Object System.Windows.Forms.Form
$pic = New-Object System.Windows.Forms.PictureBox 
$TabControl = New-object System.Windows.Forms.TabControl
$Main = New-Object System.Windows.Forms.TabPage
        $progressbox = New-Object System.Windows.Forms.RichTextBox
        $resoultbox = New-Object System.Windows.Forms.RichTextBox
        $CurrentSetupbox = New-Object System.Windows.Forms.RichTextBox
        $WorkingPanel = New-Object System.Windows.Forms.PictureBox 
        $DeployButton = New-Object System.Windows.Forms.Button
$Settings = New-Object System.Windows.Forms.TabPage
        $Groupbox1= New-Object system.Windows.Forms.Groupbox
                   $ButtonAdd1 = New-Object System.Windows.Forms.Button
                   $objButton1Box = New-Object System.Windows.Forms.TextBox
                   $ButtonAdd2 = New-Object System.Windows.Forms.Button
                   $objButton2Box = New-Object System.Windows.Forms.TextBox
                   $ButtonAdd3 = New-Object System.Windows.Forms.Button
                   $objButton3Box = New-Object System.Windows.Forms.TextBox
                   $ButtonAdd4 = New-Object System.Windows.Forms.Button
                   $objButton4Box = New-Object System.Windows.Forms.TextBox
                   $Save = New-Object System.Windows.Forms.Button
                   $Load = New-Object System.Windows.Forms.Button
                   $Clear = New-Object System.Windows.Forms.Button
                   $MusicCheckbox = New-Object System.Windows.Forms.Checkbox 
                   $soundplay = New-Object System.Windows.Forms.Button
$soundstop = New-Object System.Windows.Forms.Button

$HELP = New-Object System.Windows.Forms.Button
$Exit = New-Object System.Windows.Forms.Button
$Builderlabel = New-Object System.Windows.Forms.Label


#defines the folder and file selction boxes #
$dlg = New-object Windows.Forms.FolderBrowserDialog
$openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$Global:logname = Get-Date -Format "MM_dd_yyyy_HH_mm_ss_ms"



# sets up the encyption for config file #
$script:tempfolder = $env:temp
$tmpkey = {140
29
79
178
162
41
53
43
144
182
115
41
98
126
123
133} | Set-Content $tempfolder\mykey.key

$key = Get-Content $tempfolder\mykey.key


#imagelist
$imagelist1 = New-object System.Windows.Forms.ImageList
$imagelist1.Images.Add([System.Drawing.Image]::FromFile(".\house.png"))
$imagelist1.Images.Add([System.Drawing.Image]::FromFile(".\settings.png"))
$folder = ([System.Drawing.Image]::FromFile(".\Folders-small.png"))
$file = ([System.Drawing.Image]::FromFile(".\File-small.png"))
$copies = ([System.Drawing.Image]::FromFile(".\count-small.png"))
$Name = ([System.Drawing.Image]::FromFile(".\Name-small.png"))
$saveimg = ([System.Drawing.Image]::FromFile(".\save-small.png"))
$loadimg = ([System.Drawing.Image]::FromFile(".\load-small.png"))
$clearimg = ([System.Drawing.Image]::FromFile(".\clear-small.png"))




# Form - parameters
$Form.Text = "PCTD, Program Copies for Testing Deployment Tool "
$Form.minimumSize = New-Object System.Drawing.Size(720, 480)
$Form.maximumSize = New-Object System.Drawing.Size(720, 480)
$Form.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon(".\LOGO.ico")
$Form.TopMost = "True"
$Form.ShowInTaskbar = "True"
$Form.ControlBox = $True
$Form.KeyPreview = $True
$Form.StartPosition = "CenterScreen"
$Form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::Fixed3D
$Form.DataBindings.DefaultDataSourceUpdateMode = 0
$form.Add_Closing({param($sender,$e)
        $result = [Microsoft.VisualBasic.Interaction]::MsgBox("Are you sure you want to QUIT?", 'YesNo,SystemModal,Question', $Form.Text)
        if ($result -ne [System.Windows.Forms.DialogResult]::Yes) {$e.Cancel= $True} })
$Form.Add_KeyDown({
		if ($_.KeyCode -eq "Escape")
		{ $Form.Close()}
	})

# Tab Control - parameters 
$TabControl.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 5
$System_Drawing_Point.Y = 5
$TabControl.Location = $System_Drawing_Point
$TabControl.Name = "tabControl"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 380
$System_Drawing_Size.Width = 560
$TabControl.Size = $System_Drawing_Size
$TabControl.Multiline = $True
$TabControl.ImageList = $imagelist1
$Form.Controls.Add($tabControl)

# Main Page - parameters 
$Main.DataBindings.DefaultDataSourceUpdateMode = 0
$Main.UseVisualStyleBackColor = $True
$Main.Name = "MainPage"
$Main.Font = New-Object System.Drawing.Font("Lucida Calligraphy", 14,1, 3, 1)
$Main.Text = "Menu"
$Main.ImageIndex = 0
$Main.BackColor = ""
$Main.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$TabControl.Controls.Add($Main)
        
        $progressbox.ReadOnly = $True
        $progressbox.WordWrap = $True
        $progressbox.Multiline = $True
        $progressbox.Location = New-Object System.Drawing.Point(365, 175)
        $progressbox.BorderStyle = [System.Windows.Forms.BorderStyle]::None
        $progressbox.Size = New-Object System.Drawing.Size(160, 25)
        $progressbox.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", 8, [System.Drawing.FontStyle]::Regular)
        $Main.Controls.Add($progressbox)

        # feedback field #
        $resoultbox.ReadOnly = $True
        $resoultbox.WordWrap = $True
        $resoultbox.Multiline = $True
        $resoultbox.Location = New-Object System.Drawing.Point(5, 170)
        $resoultbox.BorderStyle = [System.Windows.Forms.BorderStyle]::None 
        $resoultbox.Size = New-Object System.Drawing.Size(540, 175)
        $resoultbox.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", 8, [System.Drawing.FontStyle]::Regular)
        $Main.Controls.Add($resoultbox)
        

        #info on current setup, box #
        $CurrentSetupbox.ReadOnly = $True
        $CurrentSetupbox.WordWrap = $True
        $CurrentSetupbox.Multiline = $True
        $CurrentSetupbox.Location = New-Object System.Drawing.Point(5, 10)
        $CurrentSetupbox.Size = New-Object System.Drawing.Size(380, 150)
        $CurrentSetupbox.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
        $CurrentSetupbox.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", 8, [System.Drawing.FontStyle]::Regular)
        $Main.Controls.Add($CurrentSetupbox)
        
        # Deploy Button #
        $DeployButton.Location = New-Object System.Drawing.Point(410, 25)
        $DeployButton.Enabled = $True
        $DeployButton.Size = New-Object System.Drawing.Size(110, 125)
        $DeployButton.Font = New-Object System.Drawing.Font("Lucida Calligraphy", 10,1, 3, 1)
        #$DeployButton.Image = 
        $DeployButton.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
        $DeployButton.ImageAlign = [System.Drawing.ContentAlignment]::BottomCenter
        $DeployButton.Text = 'DEPLOY'
        $DeployButtonToolTip = New-Object System.Windows.Forms.ToolTip
        $DeployButtonToolTip.IsBalloon = $True
        $DeployButtonToolTip.InitialDelay = 1000
        $DeployButtonToolTip.AutoPopDelay = 10000
        $DeployButtonToolTip.SetToolTip($DeployButton, "This will deploy your program`r`n in the target directory creating`r`n the desired number of copies`r`n`r`n Take note, the program will replace`r`n current copies in the target directory")
        $Main.Controls.Add($DeployButton)

###############################################  Run the Deploy  ###################################################################################################
####################################################################################################################################################################
#                                                                                                                                                                 ##
        $DeployButton.add_click({  $DeployButton.Enabled = $False                                                                                                 ##
                                   $resoultbox.Text  ="`r`n"                                                                                                      ##
                                   $resoultbox.Text += clean-up                                                                                                   ##
                                   if ($CHKFLE -ne "Bad") {                                                                                                       ##
                                                           $resoultbox.Text += new-dir                                                                            ##
                                                           extract                                                                                                ##
                                                           $resoultbox.Text += "Log: $logname Created"                                                            ##
                                                           $resoultbox.SaveFile("$PCTDFOLDER\Logs\$logname.log")                                                  ##
                                                           $n = (get-content $tempfolder\extraction.tmp | Select-String -pattern "Everything is Ok").length    ##
                                                           if ( $n -eq $counter) {success} else { failure}                                                        ##
                                                           $DeployButton.Enabled = $True                                                                          ##
                                                           }                                                                                                      ##
                                       else { failure                                                                                                             ##
                                              $DeployButton.Enabled = $True                                                                                       ##
                                              }                                                                                                                   ##                                                                                                                         ##    
                                        })                                                                                                                        ## 
#                                                                                                                                                                 ##
####################################################################################################################################################################
####################################################################################################################################################################


# Settings Page - parameters 
$Settings.DataBindings.DefaultDataSourceUpdateMode = 0
$Settings.UseVisualStyleBackColor = $True
$Settings.Name = "SettingsPage"
$Settings.Text = "Settings”
$Settings.ImageIndex = 1
$Settings.BackColor = ""
$Settings.BorderStyle = [System.Windows.Forms.BorderStyle]::Fixed3D
$TabControl.Controls.Add($Settings)

# groupbox1 - parameters #
$Groupbox1                       = New-Object system.Windows.Forms.Groupbox
$Groupbox1.text                  = "Setup deployment parameters"
$Groupbox1.location              = New-Object System.Drawing.Point(25,10)
$Groupbox1.Padding               = New-Object -TypeName System.Windows.Forms.Padding -ArgumentList (3,5,5,0)
$Groupbox1.minimumSize = New-Object System.Drawing.Size(500,325)
$Groupbox1.maximumSize = New-Object System.Drawing.Size(500,325)  
$Settings.controls.Add($Groupbox1)

    #this defines the first button
        $ButtonAdd1.Location = New-Object System.Drawing.Point(20, 40)
        $ButtonAdd1.Size = New-Object System.Drawing.Size(85, 35)
        $ButtonAdd1.Font = New-Object System.Drawing.Font("Lucida Calligraphy", 10,1, 3, 1)
        $ButtonAdd1.Image = $folder
        $ButtonAdd1.TextAlign = [System.Drawing.ContentAlignment]::MiddleRight
        $ButtonAdd1.ImageAlign = [System.Drawing.ContentAlignment]::MiddleLeft
        $ButtonAdd1.Text = 'Folder'
        $ButtonAdd1.add_click({
		        $dlg.ShowDialog()
                if ($dlg.SelectedPath -ne "")
		        {$objButton1Box.text = $dlg.SelectedPath}
	               })
        $objbuttonboxlabel1 = New-Object System.Windows.Forms.Label
        $objbuttonboxlabel1.Location = New-Object System.Drawing.Point(50, 95)
        $objbuttonboxlabel1.Size = New-Object System.Drawing.Size(210, 20)
        $objbuttonboxlabel1.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",8,0,3,0)
        $objbuttonboxlabel1.Text = "Main directory path for program copies "
        $objButton1Box.ReadOnly = $True
        $objButton1Box.Location = New-Object System.Drawing.Point(50, 110)
        $objButton1Box.Size = New-Object System.Drawing.Size(375, 75)
        $objButton1Box.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", 8, [System.Drawing.FontStyle]::Regular)
        #tooltip 1#
        $Button1ToolTip = New-Object System.Windows.Forms.ToolTip
        $Button1ToolTip.IsBalloon = $True
        $Button1ToolTip.InitialDelay = 1000
        $Button1ToolTip.AutoPopDelay = 9000
        $Button1ToolTip.SetToolTip($ButtonAdd1, "Select the main directory for your program copies")

    #this defines the second button
        $ButtonAdd2.Location = New-Object System.Drawing.Point(125, 40)
        $ButtonAdd2.Size = New-Object System.Drawing.Size(120, 35)
        $ButtonAdd2.Font = New-Object System.Drawing.Font("Lucida Calligraphy", 10, 1, 3, 1)
        $ButtonAdd2.Image = $file
        $ButtonAdd2.TextAlign = [System.Drawing.ContentAlignment]::MiddleRight
        $ButtonAdd2.ImageAlign = [System.Drawing.ContentAlignment]::MiddleLeft
        $ButtonAdd2.Text = 'Source file'
        $ButtonAdd2.add_click({
		        $openFileDialog.ShowDialog()
                if ($openFileDialog.FileName -ne "") 
		        {$objButton2Box.text = $openFileDialog.FileName}
	            })
        $objbuttonboxlabel2 = New-Object System.Windows.Forms.Label
        $objbuttonboxlabel2.Location = New-Object System.Drawing.Point(50, 145)
        $objbuttonboxlabel2.Size = New-Object System.Drawing.Size(100, 20)
        $objbuttonboxlabel2.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",8,0,3,0)
        $objbuttonboxlabel2.Text = "Installation pack file name "
        $objButton2Box.ReadOnly = $True
        $objButton2Box.Location = New-Object System.Drawing.Point(50, 160)
        $objButton2Box.Size = New-Object System.Drawing.Size(375, 75)
        $objButton2Box.Font = New-Object System.Drawing.Font("Gill Sans", 8, [System.Drawing.FontStyle]::Regular)
        #tooltip 2#
        $Button2ToolTip = New-Object System.Windows.Forms.ToolTip
        $Button2ToolTip.IsBalloon = $True
        $Button2ToolTip.InitialDelay = 1000
        $Button2ToolTip.AutoPopDelay = 9000
        $Button2ToolTip.SetToolTip($ButtonAdd2, "Select your program's pack, install file, that will deploy each copy")

    #this defines the third Button  #
        $ButtonAdd3.Location = New-Object System.Drawing.Size(260, 40)
        $ButtonAdd3.Size = New-Object System.Drawing.Size(100, 35)
        $ButtonAdd3.Font = New-Object System.Drawing.Font("Lucida Calligraphy", 12, 1, 3, 1)
        $ButtonAdd3.Image = $copies
        $ButtonAdd3.TextAlign = [System.Drawing.ContentAlignment]::MiddleRight
        $ButtonAdd3.ImageAlign = [System.Drawing.ContentAlignment]::MiddleLeft
        $ButtonAdd3.Text = "Copies"
        $ButtonAdd3.add_click({ $innerform.ShowDialog() })
        $objbuttonboxlabel3 = New-Object System.Windows.Forms.Label
        $objbuttonboxlabel3.Location = New-Object System.Drawing.Point(50, 195)
        $objbuttonboxlabel3.Size = New-Object System.Drawing.Size(80, 20)
        $objbuttonboxlabel3.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",8,0,3,0)
        $objbuttonboxlabel3.Text = "No. of copies "
        $objButton3Box.ReadOnly = $True
        $objButton3Box.Location = New-Object System.Drawing.Size(50, 210)
        $objButton3Box.Size = New-Object System.Drawing.Size(30, 75)
        $objButton3Box.Font = New-Object System.Drawing.Font("Gill Sans", 8, [System.Drawing.FontStyle]::Regular)
        $objButton3Box.MaxLength = 2
        $objButton3Box.Add_TextChanged({ $this.Text = $this.Text -replace '\D' })
        #$objButton3Box.Add_TextChanged({ $this.Text = $this.Text -replace '0' })
        #tooltip 3#
        $Button3ToolTip = New-Object System.Windows.Forms.ToolTip
        $Button3ToolTip.IsBalloon = $True
        $Button3ToolTip.InitialDelay = 1000
        $Button3ToolTip.AutoPopDelay = 9000
        $Button3ToolTip.SetToolTip($ButtonAdd3, "Define how many copies are desired to be created of the pack install program")
        
        #this defines the forth Button  #
        $ButtonAdd4.Location = New-Object System.Drawing.Size(380, 40)
        $ButtonAdd4.Size = New-Object System.Drawing.Size(100, 35)
        $ButtonAdd4.Font = New-Object System.Drawing.Font("Lucida Calligraphy", 12, 1, 3, 1)
        $ButtonAdd4.Image = $Name
        $ButtonAdd4.TextAlign = [System.Drawing.ContentAlignment]::MiddleRight
        $ButtonAdd4.ImageAlign = [System.Drawing.ContentAlignment]::MiddleLeft
        $ButtonAdd4.Text = "Name"
        $ButtonAdd4.add_click({ $innerform2.ShowDialog() })
        $objbuttonboxlabel4 = New-Object System.Windows.Forms.Label
        $objbuttonboxlabel4.Location = New-Object System.Drawing.Point(150, 195)
        $objbuttonboxlabel4.Size = New-Object System.Drawing.Size(130, 20)
        $objbuttonboxlabel4.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",8,0,3,0)
        $objbuttonboxlabel4.Text = "Program Name to deploy "
        $objButton4Box.ReadOnly = $True
        $objButton4Box.Location = New-Object System.Drawing.Size(150, 210)
        $objButton4Box.Size = New-Object System.Drawing.Size(130, 75)
        $objButton4Box.Font = New-Object System.Drawing.Font("Gill Sans", 8, [System.Drawing.FontStyle]::Regular)
        #tooltip 4#
        $Button4ToolTip = New-Object System.Windows.Forms.ToolTip
        $Button4ToolTip.IsBalloon = $True
        $Button4ToolTip.InitialDelay = 1000
        $Button4ToolTip.AutoPopDelay = 9000
        $Button4ToolTip.SetToolTip($ButtonAdd4, "Define the name of the program you'r making copies off")
        
        # INNER FORM.WINDOW - custom select window for the third Button #

                    $innerform = New-Object System.Windows.Forms.Form
                    $innerform.Text = "Enter Number of copies (recommended 1-9)"
                    $innerform.TopMost = "True"
                    $innerform.ControlBox = $False
                    $innerform.minimumSize = New-Object System.Drawing.Size(340, 110)
                    $innerform.maximumSize = New-Object System.Drawing.Size(340, 110)
                    $innerform.StartPosition = "CenterScreen"
                    $innerform.KeyPreview = $True
                    $innerform.Add_KeyDown({
		                    if ($_.KeyCode -eq ("Escape"))
		                    {
			                    if ($innerform.Controls.Contains($errinner))
			                    {
				                    $innerform.Controls.Remove($errinner)
				                    $InnerTextBox.Text = ""
				                    $innerform.Close()
			                    }
			                    else
			                    {
				                    $InnerTextBox.Text = ""
				                    $innerform.Close()
			                    }
		                    }
	                    }) 
                    $innerform.Add_KeyDown({ if ($_.KeyCode -eq ("Enter")) {if ($InnerTextBox.Text -ne "" -and $InnerTextBox.Text -ne "0")
		                    {
			                    $objButton3Box.Text = $InnerTextBox.Text
			                    $InnerTextBox.Text = ""
			                    if ($innerform.Controls.Contains($errinner))
			                    {
				                    $innerform.Controls.Remove($errinner)
				                    $innerform.Close()
			                    }
			                    else
			                    { $innerform.Close() }
		                    }
		                    else { $innerform.Controls.Add($errinner) } } })

                    $errinner = New-Object System.Windows.Forms.Label
                    $errinner.Location = New-Object System.Drawing.Size(1, 1)
                    $errinner.Size = New-Object System.Drawing.Size(250, 25)
                    $errinner.Font = New-Object System.Drawing.Font("Ariel", 8, 0, 3, 0)
                    $errinner.ForeColor = "Red"
                    $errinner.TextAlign = [System.Drawing.ContentAlignment]::Middleright
                    $errinner.Text = "Must input valid number or press ESC"

                    $OK = New-Object System.Windows.Forms.Button
                    $OK.Location = New-Object System.Drawing.Point(225, 25)
                    $OK.Size = New-Object System.Drawing.Size(40, 30)
                    $OK.Text = 'OK'
                    $OK.add_click({
		                    if ($InnerTextBox.Text -ne "" -and $InnerTextBox.Text -ne "0")
		                    {
			                    $objButton3Box.Text = $InnerTextBox.Text
			                    $InnerTextBox.Text = ""
			                    if ($innerform.Controls.Contains($errinner))
			                    {
				                    $innerform.Controls.Remove($errinner)
				                    $innerform.Close()
			                    }
			                    else
			                    { $innerform.Close() }
		                    }
		                    else { $innerform.Controls.Add($errinner) }
	                    })

                    $InnerTextBox = New-Object System.Windows.Forms.TextBox
                    $InnerTextBox.Location = New-Object System.Drawing.Size(80, 28)
                    $InnerTextBox.Size = New-Object System.Drawing.Size(30, 75)
                    $InnerTextBox.Font = New-Object System.Drawing.Font("Gill Sans", 12, [System.Drawing.FontStyle]::Regular)
                    $InnerTextBox.MaxLength = 2
                    $InnerTextBox.Add_TextChanged({ $this.Text = $this.Text -replace '\D' })
                   #$InnerTextBox.Add_TextChanged({ $this.Text = $this.Text -replace '0' })

                    $innerform.Controls.Add($OK)
                    $innerform.Controls.Add($InnerTextBox)

         # INNER FORM.WINDOW - custom select window for the forth Button #

                    $innerform2 = New-Object System.Windows.Forms.Form
                    $innerform2.Text = "Define the name of the program for copies"
                    $innerform2.TopMost = "True"
                    $innerform2.ControlBox = $False
                    $innerform2.minimumSize = New-Object System.Drawing.Size(340, 110)
                    $innerform2.maximumSize = New-Object System.Drawing.Size(340, 110)
                    $innerform2.StartPosition = "CenterScreen"
                    $innerform2.KeyPreview = $True
                    $innerform2.Add_KeyDown({
		                    if ($_.KeyCode -eq "Escape")
		                    {
			                    if ($innerform2.Controls.Contains($errinner2))
			                    {
				                    $innerform2.Controls.Remove($errinner2)
				                    $InnerTextBox2.Text = ""
				                    $innerform2.Close()
			                    }
			                    else
			                    {
				                    $InnerTextBox2.Text = ""
				                    $innerform2.Close()
			                    }
		                    }
	                    })
                    $innerform2.Add_KeyDown({ if ($_.KeyCode -eq ("Enter")) {if ($InnerTextBox2.Text -ne "")
		                    {
			                    $objButton4Box.Text = $InnerTextBox2.Text
			                    $InnerTextBox2.Text = ""
			                    if ($innerform2.Controls.Contains($errinner2))
			                    {
				                    $innerform2.Controls.Remove($errinner2)
				                    $innerform2.Close()
			                    }
			                    else
			                    { $innerform2.Close() }
		                    }
		                    else { $innerform2.Controls.Add($errinner2) } } })

                    $errinner2 = New-Object System.Windows.Forms.Label
                    $errinner2.Location = New-Object System.Drawing.Size(1, 1)
                    $errinner2.Size = New-Object System.Drawing.Size(250, 25)
                    $errinner2.Font = New-Object System.Drawing.Font("Ariel", 8, 0, 3, 0)
                    $errinner2.ForeColor = "Red"
                    $errinner2.TextAlign = [System.Drawing.ContentAlignment]::Middleright
                    $errinner2.Text = "Must enter input or press ESC"

                    $OK2 = New-Object System.Windows.Forms.Button
                    $OK2.Location = New-Object System.Drawing.Point(225, 25)
                    $OK2.Size = New-Object System.Drawing.Size(40, 30)
                    $OK2.Text = 'OK'
                    $OK2.add_click({
		                    if ($InnerTextBox2.Text -ne "")
		                    {
			                    $objButton4Box.Text = $InnerTextBox2.Text
			                    $InnerTextBox2.Text = ""
			                    if ($innerform2.Controls.Contains($errinner2))
			                    {
				                    $innerform2.Controls.Remove($errinner2)
				                    $innerform2.Close()
			                    }
			                    else
			                    { $innerform2.Close() }
		                    }
		                    else { $innerform2.Controls.Add($errinner2) }
	                    })

                    $InnerTextBox2 = New-Object System.Windows.Forms.TextBox
                    $InnerTextBox2.Location = New-Object System.Drawing.Size(40, 28)
                    $InnerTextBox2.Size = New-Object System.Drawing.Size(150, 75)
                    $InnerTextBox2.Font = New-Object System.Drawing.Font("Gill Sans", 12, [System.Drawing.FontStyle]::Regular)
                    $innerform2.Controls.Add($OK2)
                    $innerform2.Controls.Add($InnerTextBox2)



function CheckAllBoxes{
                                if( $objButton1Box.Text.Length -and $objButton2Box.Text.Length -and $objButton3Box.Text.Length -and $objButton4Box.Text.Length){$Save.Enabled=$true}else{$Save.Enabled=$false}
                                }
   
$objButton1Box.ADD_TextChanged({ CheckAllBoxes })
$objButton2Box.ADD_TextChanged({ CheckAllBoxes })
$objButton3Box.ADD_TextChanged({ CheckAllBoxes })
$objButton4Box.ADD_TextChanged({ CheckAllBoxes })


        #this defines Save Button
        $Save.Location = New-Object System.Drawing.Point(70, 270)
        $Save.Size = New-Object System.Drawing.Size(90, 35)
        $Save.Font = New-Object System.Drawing.Font("Lucida Calligraphy", 10,1, 3, 1)
        $Save.TextAlign = [System.Drawing.ContentAlignment]::MiddleRight
        $Save.ImageAlign = [System.Drawing.ContentAlignment]::MiddleLeft
        $Save.Image = $saveimg
        $Save.Text = 'Save'
        $Save.Enabled=$false
        #save tooltip#
        $SaveToolTip = New-Object System.Windows.Forms.ToolTip
        $SaveToolTip.IsBalloon = $True
        $SaveToolTip.InitialDelay = 1000
        $SaveToolTip.AutoPopDelay = 9000
        $SaveToolTip.SetToolTip($Save, "Saves the current selections into a configuration file")
        $Save.add_click({ $data= @{
                                   File = $objButton2Box.Text
                                   Folder = $objButton1Box.Text
                                   Count = $objButton3Box.Text
                                   Name = $objButton4Box.Text
                                       }
                               $perm = $data | ConvertTo-Json
                               $errOutput = $($perm |  ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString -key $key |  Set-Content -Path $PCTDFOLDER\PCTDTool.cfg) 2>&1
                               if ($errOutput -eq $Null) 
                                  { Loadsaved
                                    [Microsoft.VisualBasic.Interaction]::MsgBox("Saved to configuration file and View refreshed",'OkOnly,SystemModal,Information', $Form.Text)}
                                 else
                                  {[Microsoft.VisualBasic.Interaction]::MsgBox("Something went wrong, configuration file could not be saved. check permissions to write to $PCTDFOLDER\PCTDTool.cfg. ",'OkOnly,SystemModal,Critical', $Form.Text)
                                                }
                                            
                            })
                           
                                       


        #this defines Load Button
        $Load = New-Object System.Windows.Forms.Button
        $Load.Location = New-Object System.Drawing.Point(195, 270)
        $Load.Size = New-Object System.Drawing.Size(90, 35)
        $Load.Font = New-Object System.Drawing.Font("Lucida Calligraphy", 10,1, 3, 1)
        $Load.TextAlign = [System.Drawing.ContentAlignment]::MiddleRight
        $Load.ImageAlign = [System.Drawing.ContentAlignment]::MiddleLeft
        $Load.Image = $loadimg
        $Load.Text = 'Load'
        #load tooltip#
        $LoadToolTip = New-Object System.Windows.Forms.ToolTip
        $LoadToolTip.IsBalloon = $True
        $LoadToolTip.InitialDelay = 1000
        $LoadToolTip.AutoPopDelay = 9000
        $LoadToolTip.SetToolTip($Load, "Loads onto the screen the current configuration file (if exists, if not an error message will show)")
        $Load.add_click({ if ((Test-Path -Path $PCTDFOLDER\PCTDTool.cfg -PathType Leaf) -eq "True") 
                                { Loadsaved
                                  if ($global:errOutput2 -ne $null) 
                                      {[Microsoft.VisualBasic.Interaction]::MsgBox("Cannot Load Configuration file, File currupted. Please save a new Configuration  ",'OkOnly,SystemModal,Critical', $Form.Text)} else {}
                                  }
                                 else 
                                 {[Microsoft.VisualBasic.Interaction]::MsgBox("No configuration file detected. please save a configuration at least once!",'OkOnly,SystemModal,Critical', $Form.Text)
                                    }
                                   })
        #this defines Clear Button
        $Clear.Location = New-Object System.Drawing.Point(320, 270)
        $Clear.Size = New-Object System.Drawing.Size(95, 35)
        $Clear.Font = New-Object System.Drawing.Font("Lucida Calligraphy", 10,1, 3, 1)
        $Clear.TextAlign = [System.Drawing.ContentAlignment]::MiddleRight
        $Clear.ImageAlign = [System.Drawing.ContentAlignment]::MiddleLeft
        $Clear.Image = $clearimg        
        $Clear.Text = 'Clear'
        $Clear.add_click({ $objButton1Box.Text = $null
                           $objButton2Box.Text = $null
                           $objButton3Box.Text = $null
                           $objButton4Box.Text = $null
                           })
        #clear tooltip#
        $ClearToolTip = New-Object System.Windows.Forms.ToolTip
        $ClearToolTip.IsBalloon = $True
        $ClearToolTip.InitialDelay = 1000
        $ClearToolTip.AutoPopDelay = 9000
        $ClearToolTip.SetToolTip($Clear, "Clears the current selection")




        
#check if configuration file exist and if so try to load data from it#
$existpath = Test-Path -Path $PCTDFOLDER\PCTDTool.cfg -PathType Leaf
if ($existpath -eq "True")
        { Loadsaved 
            $TabControl.ADD_SelectedIndexChanged({ if (($TabControl.SelectedTab.Text -eq "Settings") -and ($global:errOutput2 -ne $null)) 
                                       {[Microsoft.VisualBasic.Interaction]::MsgBox("Cannot Load Configuration file, File currupted. Please save a new Configuration",'OkOnly,SystemModal,Critical', $Form.Text) 
                                      }else { } })    
            }    
    else
         { #more code stating failure to populate main tab info box with config data will come here
           $TabControl.ADD_SelectedIndexChanged({ if ($TabControl.SelectedTab.Text -eq "Settings") 
                                      { if ((Test-Path -Path $PCTDFOLDER\PCTDTool.cfg -PathType Leaf) -ne "True")
                                        {[Microsoft.VisualBasic.Interaction]::MsgBox("No configuration file detected. please save a configuration at least once!",'OkOnly,SystemModal,Critical', $Form.Text)} else {}
                                    } else { } })
           }



# Picture - parameters 
$pic.BackColor = [System.Drawing.Color]::Transparent
$pic.Location = New-Object System.Drawing.Size(580, 10) 
$pic.ImageLocation = ".\LOGOanim - small.gif" 
$pic.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::AutoSize
$picToolTip = New-Object System.Windows.Forms.ToolTip
$picToolTip.IsBalloon = $True
$picToolTip.InitialDelay = 1000
$picToolTip.AutoPopDelay = 15000
$picToolTip.UseFading = "True"
$sb = New-object System.Text.StringBuilder
$sb.AppendLine('_____$$$$_________$$$$')
$sb.AppendLine('___$$$$$$$$_____$$$$$$$')
$sb.AppendLine('_$$$$$$$$$$$$_$$$$$$$$$$')
$sb.AppendLine('$$$$$$$$$$$$$$$$$$$$$$$$$')
$sb.AppendLine('$$$$$$$$$$$$$$$$$$$$$$$$$$')
$sb.AppendLine('_$$$$$$$-MAAYAN-$$$$$$$$')
$sb.AppendLine('__$$$$$$$$$$$$$$$$$$$$$$$')
$sb.AppendLine('____$$$$$$$$$$$$$$$$$$$')
$sb.AppendLine('______$$$$$$$$$$$$$$$')
$sb.AppendLine('________$$$$$$$$$$$')
$sb.AppendLine('__________$$$$$$$')
$sb.AppendLine('____________$$$')
$sb.AppendLine('_____________$')
$sb.AppendLine('To my Beloved wife.')
$sb.AppendLine('from your loving husband.')
$picToolTip.SetToolTip($pic, $sb.ToString());
$Form.Controls.Add($pic)

Function Menual {
# show embedded PDF converted to HTML 
$Help = New-Object system.Windows.Forms.Form
$Help.minimumSize = New-Object System.Drawing.Size(850, 825)
$Help.maximumSize = New-Object System.Drawing.Size(850, 825)
$Help.Text = "Help Menual" 
$Form.TopMost = "False"
$Help.TopMost = "True" 
$WebBrowser = new-object System.Windows.Forms.WebBrowser
$WebBrowser.ClientSize = $Help.ClientSize
$CurrentLocation = Get-Location
$WebBrowser.Navigate("$CurrentLocation\manual.html&embedded=true")
$Help.Controls.Add($WebBrowser)
$Help.ShowDialog()
$Help.Dispose()
$Form.TopMost = "True"

}

# Help - Parameters #
$HELP.Text = "Help"
$HELP.Location = New-Object System.Drawing.Point( 602, 345)
$HELP.size = New-Object System.Drawing.Point(50, 20)
$HELP.add_click({ Menual })
	
$Form.Controls.Add($HELP)
 
# Exit - Parameters #
$Exit.Text = "EXIT"
$Exit.Location = New-Object System.Drawing.Point(590, 375)
$Exit.add_click({
		 $Form.Close()
	}) 
$Form.Controls.Add($Exit)

$Builderlabel = New-Object System.Windows.Forms.Label
$Builderlabel.Location = New-Object System.Drawing.Point(565, 400)
$Builderlabel.Size = New-Object System.Drawing.Size(130, 30)
$Builderlabel.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",8,0,3,0)
$Builderlabel.Text = "By: Maxim Golan © "
$Form.Controls.Add($Builderlabel)


$Groupbox1.Controls.Add($ButtonAdd1)
$Groupbox1.Controls.Add($objButton1Box)
$Groupbox1.Controls.Add($objbuttonboxlabel1)
$Groupbox1.Controls.Add($ButtonAdd2)
$Groupbox1.Controls.Add($objButton2Box)
$Groupbox1.Controls.Add($objbuttonboxlabel2)
$Groupbox1.Controls.Add($ButtonAdd3)
$Groupbox1.Controls.Add($objButton3Box)
$Groupbox1.Controls.Add($objbuttonboxlabel3)
$Groupbox1.Controls.Add($ButtonAdd4)
$Groupbox1.Controls.Add($objButton4Box)
$Groupbox1.Controls.Add($objbuttonboxlabel4)
$Groupbox1.Controls.Add($Save)
$Groupbox1.Controls.Add($Load)
$Groupbox1.Controls.Add($Clear)



Function success {
[Microsoft.VisualBasic.Interaction]::MsgBox('Deploy complete, Enjoy :)','OKOnly,SystemModal,Information','PCTD Tool')
$notify = New-Object System.Windows.Forms.NotifyIcon; $notify.Icon = [System.Drawing.SystemIcons]::Information 
$notify.Visible = $true; $notify.ShowBalloonTip(0, 'Congratulations', 'PCTD Tool have successfuly deployed your program copies for testing . created by: Maxim Golan', [System.Windows.Forms.ToolTipIcon]::None)
}

Function failure {
[Microsoft.VisualBasic.Interaction]::MsgBox('Deploy failed! :(','OKOnly,SystemModal,Critical','PCTD Tool')
$notify = New-Object System.Windows.Forms.NotifyIcon; $notify.Icon = [System.Drawing.SystemIcons]::Information 
$notify.Visible = $true; $notify.ShowBalloonTip(0, 'Attention', 'PCTD Tool have failed to deploy the program check log for more details!' , [System.Windows.Forms.ToolTipIcon]::None)
}

$Form.ShowDialog()
$form.Dispose()
} #end of Function Deploy

Deploy


$tempfolder = $env:temp
Remove-Item $tempfolder\mykey.key
Remove-Item $tempfolder\extraction.tmp
Exit


