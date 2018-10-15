﻿######################################################################## 
# Code Generated By: SAPIEN Technologies, Inc., PrimalForms 2009 v1.1.16.0 
# Generated On: 12/12/2011 6:44 AM 
# Generated By: jlarkins 
######################################################################## 
 
#---------------------------------------------- 
#region Application Functions 
#---------------------------------------------- 
 
function OnApplicationLoad { 
    #Note: This function runs before the form is created 
    #Note: To get the script directory in the Packager use: Split-Path $hostinvocation.MyCommand.path 
    #Note: To get the console output in the Packager (Windows Mode) use: $ConsoleOutput (Type: System.Collections.ArrayList) 
    #Important: Form controls cannot be accessed in this function 
    #TODO: Add snapins and custom code to validate the application load 
     
    return $true #return true for success or false for failure 
} 
 
function OnApplicationExit { 
    #Note: This function runs after the form is closed 
    #TODO: Add custom code to clean up and unload snapins when the application exits 
     
    $script:ExitCode = 0 #Set the exit code for the Packager 
} 
 
#endregion 
 
#---------------------------------------------- 
# Generated Form Function 
#---------------------------------------------- 
function GenerateForm { 
 
    #---------------------------------------------- 
    #region Import Assemblies 
    #---------------------------------------------- 
    [void][reflection.assembly]::Load("System.Windows.Forms, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089") 
    [void][reflection.assembly]::Load("System.Drawing, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a") 
    [void][reflection.assembly]::Load("mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089") 
    [void][reflection.assembly]::Load("System.Data, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089") 
    [void][reflection.assembly]::Load("System, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089") 
    #endregion 
     
    #---------------------------------------------- 
    #region Generated Form Objects 
    #---------------------------------------------- 
    [System.Windows.Forms.Application]::EnableVisualStyles() 
    $form1 = New-Object System.Windows.Forms.Form 
    $Pwdchkbx = New-Object System.Windows.Forms.CheckBox 
    $PwdTxtBx = New-Object System.Windows.Forms.TextBox 
    $PwdLbl = New-Object System.Windows.Forms.Label 
    $label2 = New-Object System.Windows.Forms.Label 
    $combobox1 = New-Object System.Windows.Forms.ComboBox 
    $button1 = New-Object System.Windows.Forms.Button 
    $rsltsbox1 = New-Object System.Windows.Forms.TextBox 
    $cnclBtn = New-Object System.Windows.Forms.Button 
    $okbtn = New-Object System.Windows.Forms.Button 
    $label1 = New-Object System.Windows.Forms.Label 
    $txtbox1 = New-Object System.Windows.Forms.TextBox 
    $InitialFormWindowState = New-Object System.Windows.Forms.FormWindowState 
    #endregion Generated Form Objects 
 
    #---------------------------------------------- 
    # User Generated Script 
    #---------------------------------------------- 
 
     
     
     
     
    $FormEvent_Load={ 
        #TODO: Initialize Form Controls here 
         
    } 
     
     
     
     
    $handler_=[System.Windows.Forms.KeyPressEventHandler]{ 
    #Event Argument: $_ = [System.Windows.Forms.KeyPressEventArgs] 
    #TODO: Place custom script here 
     
    } 
     
    $handler_txtbox1_KeyPress=[System.Windows.Forms.KeyPressEventHandler]{ 
    #Event Argument: $_ = [System.Windows.Forms.KeyPressEventArgs] 
    #TODO: Place custom script here 
     
     
    } 
     
    $handler_okbtn_Click={ 
    $domain = $combobox1.Text 
    $samaccountname = $txtbox1.text 
        Function Get-UTCAge { 
            #get date time of the last password change 
                Param([int64]$Last=0) 
                if ($Last -eq 0) { 
                    write 0 
                } else { 
                    #clock starts counting from 1/1/1601. 
                    [datetime]$utc="1/1/1601" 
                    #calculate the number of days based on the int64 number 
                    $i=$Last/864000000000 
                     
                    #Add the number of days to 1/1/1601 
                    #and write the result to the pipeline 
                    write ($utc.AddDays($i)) 
                } 
            } # end Get-UTCAge function 
             
        Function Get-PwdAge { 
         
          Param([int64]$LastSet=0) 
             
            if ($LastSet -eq 0) { 
                write "0" 
            } else { 
                #get the date the password was last changed 
                [datetime]$ChangeDate=Get-UTCAge $LastSet 
                 
                #get the current date and time 
                [datetime]$RightNow=Get-Date 
                 
                #write the difference in days 
                write $RightNow.Subtract($ChangeDate).Days 
            } 
        } #end Get-PwdAge function 
             
              
        #main code 
        #define some constants 
         
        New-Variable ADS_UF_ACCOUNTDISABLE 0x0002 -Option Constant 
        New-Variable ADS_UF_PASSWD_CANT_CHANGE 0x0040 -Option Constant 
        New-Variable ADS_UF_DONT_EXPIRE_PASSWD 0x10000 -Option Constant 
        New-Variable ADS_UF_PASSWD_EXPIRED 0x800000 -Option Constant 
         
        #define our searcher object 
        $searchroot=([ADSI]"LDAP://$domain") 
        $Searcher = New-Object DirectoryServices.DirectorySearcher($SearchRoot)  
         
         
        # find the user 
        $filter="(&(objectCategory=person)(objectClass=user)(samaccountname=$samaccountname))" 
        $searcher.filter=$filter 
         
        #get the user information 
         
        $user=$searcher.findOne()  
         
        if (-not $user.path) { 
            $rsltsbox1.Text = "Could not find $samaccountname" 
            Return 
        } 
         
        $user | ForEach-Object { 
         
        #get password properties from useraccountcontrol field 
            if ($_.properties.item("useraccountcontrol")[0] -band $ADS_UF_DONT_EXPIRE_PASSWD) { 
                $pwdNeverExpires=$True 
             } 
             else { 
                $pwdNeverExpires=$False 
             } 
              
             #Password expired should be calculated from a computed UAC value 
             $user=$_.GetDirectoryEntry() 
             $user.psbase.refreshcache("msDS-User-Account-Control-Computed") 
             [int]$computed=$user.psbase.properties.item("msDS-User-Account-Control-Computed").value 
                 
             if ($computed -band $ADS_UF_PASSWD_EXPIRED) { 
                $pwdExpired=$True 
             } 
             else { 
                $pwdExpired=$False 
             } 
              
            #account lockedout 
            if ($_.properties.item("lockoutTime")[0]) { 
                $lockedout=$True 
            } 
            else {  
               $lockedout=$False 
            } 
             #check if user can change their password 
             if ($_.properties.item("useraccountcontrol")[0] -band $ADS_UF_PASSWD_CANT_CHANGE) { 
                $pwdChangeAllowed=$False 
             } 
             else { 
                $pwdChangeAllowed=$True 
             } 
    # Collect Property Values and write to results box 
             
    $value = "Name: $($_.properties.item("name")[0]) 
DN: $($_.properties.item("distinguishedname")[0]) 
Description: $( $_.properties.item("description")[0]) 
Email: $( $_.properties.item("mail")[0]) 
AccountCreated: $( $_.properties.item("whencreated")[0]) 
AccountModified: $( $_.properties.item("WhenChanged")[0]) 
LastLogon: $(Get-UTCAge $_.properties.item("lastlogon")[0]) 
Password Last Changed: $(Get-UTCAge $_.properties.item("pwdlastset")[0]) 
PasswordExpired: $pwdExpired 
Password Age: $(Get-PwdAge $_.properties.item("pwdlastset")[0]) 
PasswordNeverExpires: $pwdNeverExpires 
PasswordChangeAllowed: $pwdChangeAllowed 
BadPasswordTime: $(Get-UTCAge $_.properties.item("BadPassWordTime")[0]) 
Lockout: $lockedout 
" 
         
             
            $rsltsbox1.Text = $value 
            } 
            # Change password for user 
            if ($Pwdchkbx.Checked) 
            { 
             
            function CreatePassword([int]$length) 
             
            { 
             
               $specialCharacters = "$@#!" 
             
               $lowerCase = "abcdefghijklmnopqrstuvwxyz" 
             
               $upperCase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ" 
             
               $numbers = "1234567890" 
             
               $res = "" 
             
               $rnd = New-Object System.Random 
             
               do 
             
               { 
             
                   $flag = $rnd.Next(4);  
             
                   if ($flag -eq 0) 
             
                   {$res += $specialCharacters[$rnd.Next($specialCharacters.Length)]; 
             
                   } elseif ($flag -eq 1) 
             
                   {$res += $lowerCase[$rnd.Next($lowerCase.Length)]; 
             
                   } elseif ($flag -eq 2) 
             
                   {$res += $upperCase[$rnd.Next($upperCase.Length)]; 
             
                   } else 
             
                   {$res += $numbers[$rnd.Next($numbers.Length)]; 
             
                   } 
             
               } while (0 -lt $length--) 
             
               return $res 
                  
            } 
                $Pwd = CreatePassword 6 
             
                [adsi]$user="WinNT://$domain/$samaccountname"  
                $user.SetPassword("$pwd") 
                $user.SetInfo() 
                $PwdTxtBx.Text = "$pwd" 
                 
                } 
                } 
             
     
     
     
     
    $CancelBtn={ 
    $form1.Close 
     
    } 
     
    $username={ 
    #TODO: Place custom script here 
     
    } 
     
     
     
    $handler_unlockbtn_Click={ 
    #TODO: Place custom script here 
        $ds = new-object DirectoryServices.DirectorySearcher([ADSI]"LDAP://$domain") 
        $ds.filter = "(&(objectCategory=person)(objectClass=user)(samAccountName=$samaccountname))"  
        $dn = $ds.findOne()  
        $user = [ADSI]$dn.path 
        $user.lockoutTime = 0 
        $user.SetInfo() 
        $rsltsbox1.AppendText("Account Unlocked `r`n") 
     
     
    } 
     
    #---------------------------------------------- 
    # Generated Events 
    #---------------------------------------------- 
     
    $Form_StateCorrection_Load= 
    { 
        #Correct the initial state of the form to prevent the .Net maximized form issue 
        $form1.WindowState = $InitialFormWindowState 
    } 
     
    #---------------------------------------------- 
    #region Generated Form Code 
    #---------------------------------------------- 
    # 
    # form1 
    # 
    $form1.Controls.Add($Pwdchkbx) 
    $form1.Controls.Add($PwdTxtBx) 
    $form1.Controls.Add($PwdLbl) 
    $form1.Controls.Add($label2) 
    $form1.Controls.Add($combobox1) 
    $form1.Controls.Add($button1) 
    $form1.Controls.Add($rsltsbox1) 
    $form1.Controls.Add($cnclBtn) 
    $form1.Controls.Add($okbtn) 
    $form1.Controls.Add($label1) 
    $form1.Controls.Add($txtbox1) 
    $form1.AcceptButton = $okbtn 
    $form1.CancelButton = $cnclBtn 
    $form1.ClientSize = New-Object System.Drawing.Size(552,383) 
    $form1.DataBindings.DefaultDataSourceUpdateMode = [System.Windows.Forms.DataSourceUpdateMode]::OnValidation  
    #$form1.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon("C:\Users\jlarkins\Desktop\Vista Icons\vista-stock-icons-by-lokas-software\ico\computer.ico") 
    $form1.KeyPreview = $True 
    $form1.Name = "form1" 
    $form1.Text = "Password Report" 
    $form1.add_Load($FormEvent_Load) 
    # 
    # Pwdchkbx 
    # 
    $Pwdchkbx.DataBindings.DefaultDataSourceUpdateMode = [System.Windows.Forms.DataSourceUpdateMode]::OnValidation  
    $Pwdchkbx.Location = New-Object System.Drawing.Point(336,38) 
    $Pwdchkbx.Name = "Pwdchkbx" 
    $Pwdchkbx.Size = New-Object System.Drawing.Size(119,24) 
    $Pwdchkbx.TabIndex = 3 
    $Pwdchkbx.Text = "Reset Password" 
    $Pwdchkbx.UseVisualStyleBackColor = $True 
    # 
    # PwdTxtBx 
    # 
    $PwdTxtBx.BackColor = [System.Drawing.Color]::FromArgb(255,255,255,255) 
    $PwdTxtBx.DataBindings.DefaultDataSourceUpdateMode = [System.Windows.Forms.DataSourceUpdateMode]::OnValidation  
    $PwdTxtBx.Location = New-Object System.Drawing.Point(12,353) 
    $PwdTxtBx.Name = "PwdTxtBx" 
    $PwdTxtBx.ReadOnly = $True 
    $PwdTxtBx.Size = New-Object System.Drawing.Size(145,20) 
    $PwdTxtBx.TabIndex = 8 
    $PwdTxtBx.TabStop = $False 
    # 
    # PwdLbl 
    # 
    $PwdLbl.DataBindings.DefaultDataSourceUpdateMode = [System.Windows.Forms.DataSourceUpdateMode]::OnValidation  
    $PwdLbl.Location = New-Object System.Drawing.Point(12,335) 
    $PwdLbl.Name = "PwdLbl" 
    $PwdLbl.Size = New-Object System.Drawing.Size(100,14) 
    $PwdLbl.TabIndex = 7 
    $PwdLbl.Text = "Password" 
    # 
    # label2 
    # 
    $label2.DataBindings.DefaultDataSourceUpdateMode = [System.Windows.Forms.DataSourceUpdateMode]::OnValidation  
    $label2.Font = New-Object System.Drawing.Font("Calibri",9.75,1,3,1) 
    $label2.Location = New-Object System.Drawing.Point(12,20) 
    $label2.Name = "label2" 
    $label2.Size = New-Object System.Drawing.Size(100,16) 
    $label2.TabIndex = 6 
    $label2.Text = "Select Domain" 
    # 
    # combobox1 
    # 
    $combobox1.DataBindings.DefaultDataSourceUpdateMode = [System.Windows.Forms.DataSourceUpdateMode]::OnValidation  
    $combobox1.FormattingEnabled = $True 
    [void]$combobox1.Items.Add("ddor.local") 
    [void]$combobox1.Items.Add("myDomain1") 
    $combobox1.Location = New-Object System.Drawing.Point(12,39) 
    $combobox1.Name = "combobox1" 
    $combobox1.Size = New-Object System.Drawing.Size(121,21) 
    $combobox1.TabIndex = 0 
    # 
    # button1 
    # 
    $button1.DataBindings.DefaultDataSourceUpdateMode = [System.Windows.Forms.DataSourceUpdateMode]::OnValidation  
    $button1.Location = New-Object System.Drawing.Point(465,35) 
    $button1.Name = "button1" 
    $button1.Size = New-Object System.Drawing.Size(75,23) 
    $button1.TabIndex = 4 
    $button1.TabStop = $False 
    $button1.Text = "Unlock" 
    $button1.UseVisualStyleBackColor = $True 
    $button1.add_Click($handler_unlockbtn_Click) 
    # 
    # rsltsbox1 
    # 
    $rsltsbox1.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right  
    $rsltsbox1.BackColor = [System.Drawing.Color]::FromArgb(255,255,255,255) 
    $rsltsbox1.DataBindings.DefaultDataSourceUpdateMode = [System.Windows.Forms.DataSourceUpdateMode]::OnValidation  
    $rsltsbox1.Font = New-Object System.Drawing.Font("Calibri",9.75,1,3,1) 
    $rsltsbox1.Location = New-Object System.Drawing.Point(12,66) 
    $rsltsbox1.Multiline = $True 
    $rsltsbox1.Name = "rsltsbox1" 
    $rsltsbox1.ReadOnly = $True 
    $rsltsbox1.Size = New-Object System.Drawing.Size(528,262) 
    $rsltsbox1.TabIndex = 3 
    $rsltsbox1.TabStop = $False 
    # 
    # cnclBtn 
    # 
    $cnclBtn.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right  
    $cnclBtn.DataBindings.DefaultDataSourceUpdateMode = [System.Windows.Forms.DataSourceUpdateMode]::OnValidation  
    $cnclBtn.DialogResult = [System.Windows.Forms.DialogResult]::Cancel  
    $cnclBtn.Location = New-Object System.Drawing.Point(386,353) 
    $cnclBtn.Name = "cnclBtn" 
    $cnclBtn.Size = New-Object System.Drawing.Size(68,23) 
    $cnclBtn.TabIndex = 5 
    $cnclBtn.Text = "Close" 
    $cnclBtn.UseVisualStyleBackColor = $True 
    # 
    # okbtn 
    # 
    $okbtn.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right  
    $okbtn.CausesValidation = $False 
    $okbtn.DataBindings.DefaultDataSourceUpdateMode = [System.Windows.Forms.DataSourceUpdateMode]::OnValidation  
    $okbtn.Location = New-Object System.Drawing.Point(468,353) 
    $okbtn.Name = "okbtn" 
    $okbtn.Size = New-Object System.Drawing.Size(68,23) 
    $okbtn.TabIndex = 4 
    $okbtn.Text = "OK" 
    $okbtn.UseVisualStyleBackColor = $True 
    $okbtn.add_Click($handler_okbtn_Click) 
    # 
    # label1 
    # 
    $label1.DataBindings.DefaultDataSourceUpdateMode = [System.Windows.Forms.DataSourceUpdateMode]::OnValidation  
    $label1.Font = New-Object System.Drawing.Font("Calibri",9.75,1,3,1) 
    $label1.Location = New-Object System.Drawing.Point(139,20) 
    $label1.Name = "label1" 
    $label1.Size = New-Object System.Drawing.Size(100,15) 
    $label1.TabIndex = 1 
    $label1.Text = "Enter Username" 
    # 
    # txtbox1 
    # 
    $txtbox1.DataBindings.DefaultDataSourceUpdateMode = [System.Windows.Forms.DataSourceUpdateMode]::OnValidation  
    $txtbox1.Location = New-Object System.Drawing.Point(139,38) 
    $txtbox1.Name = "txtbox1" 
    $txtbox1.Size = New-Object System.Drawing.Size(190,20) 
    $txtbox1.TabIndex = 1 
    #endregion Generated Form Code 
 
    #---------------------------------------------- 
 
    #Save the initial state of the form 
    $InitialFormWindowState = $form1.WindowState 
    #Init the OnLoad event to correct the initial state of the form 
    $form1.add_Load($Form_StateCorrection_Load) 
    #Show the Form 
    return $form1.ShowDialog() 
 
} #End Function 
 
#Call OnApplicationLoad to initialize 
if(OnApplicationLoad -eq $true) 
{ 
    #Create the form 
    GenerateForm | Out-Null 
    #Perform cleanup 
    OnApplicationExit 
} 