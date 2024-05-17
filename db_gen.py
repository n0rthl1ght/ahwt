import sqlite3
from pathlib import Path
import locale
from deep_translator import GoogleTranslator
import socket

def gen_decision():
    while True:
        gen_question = str(input("Auto or Manual generation of .bat script or script for additional software (a/m/add)?: "))
        match gen_question:
            case 'a':
                with open(filename + ".bat", 'w') as bat_file:
                    bat_file.write("@echo off\n\n")
                    bat_file.write("\necho Adding commands...\n")
                    
                    if any(keyword in str(db_file) for keyword in ['seven', 'eightzero', 'eightone', 'ten', 'eleven']):
                        bat_file.write("echo Enabling Restore Point service...\n")
                        bat_file.write("powershell \"Enable-ComputerRestore -Drive 'C:\\'\"\n")
                        bat_file.write("echo Creating restore point...\n")
                        bat_file.write(f'wmic.exe /Namespace:\\\\root\\default Path SystemRestore Call CreateRestorePoint "Before install the AHWT {filename} script", 100, 7\n')
                    elif ('vista') in str(db_file):
                        bat_file.write("echo Creating restore point...\n")
                        bat_file.write(f'wmic.exe /Namespace:\\\\root\\default Path SystemRestore Call CreateRestorePoint "Before install the AHWT {filename} script", 100, 7\n')
                    else:
                        bat_file.write("echo Enabling Restore Point service...\n")
                        bat_file.write("sc config srservice start= auto\n")
                        bat_file.write("net start srservice\n")
                        bat_file.write("echo Creating restore point...\n")
                        bat_file.write(f'wmic.exe /Namespace:\\\\root\\default Path SystemRestore Call CreateRestorePoint "Before install the AHWT {filename} script", 100, 7\n')
                    bat_file.write("echo Applying secedit configuration...\n")
                    bat_file.write(f'secedit /configure /db "secedit_db_{osname}.sdb" /areas securitypolicy group_mgmt user_rights filestore /cfg hisecdc_{osname}.inf\n')
                    bat_file.write("bcdedit /set {current} nx OptOut\n")
                
                    if any(keyword in str(db_file) for keyword in ['seven', 'eightzero', 'eightone']):
                        bat_file.write("echo Installing EMET...\n")
                        bat_file.write(f'msiexec /i "EMET Setup.msi" /qn /norestart\n')
                    if any(keyword in str(db_file) for keyword in ['seven', 'eightzero', 'eightone', 'ten', 'eleven']):
                        bat_file.write("echo Applying audit policies...\n")
                        bat_file.write(f'auditpol /clear /y\n')
                        if ('seven') in str(db_file):
                            with open('Templates\\Seven\\auditpol_seven', 'r') as audit_file:
                                lines = audit_file.readlines()
                                bat_file.writelines(lines)
                                bat_file.write(f'\n')
                        if ('eightzero') in str(db_file):
                            with open('Templates\\EightZero\\auditpol_eightzero', 'r') as audit_file:
                                lines = audit_file.readlines()
                                bat_file.writelines(lines)
                                bat_file.write(f'\n')
                        if ('eightone') in str(db_file):
                            with open('Templates\\EightOne\\auditpol_eightone', 'r') as audit_file:
                                lines = audit_file.readlines()
                                bat_file.writelines(lines)
                                bat_file.write(f'\n')
                        if ('ten') in str(db_file):
                            with open('Templates\\Ten\\auditpol_ten', 'r') as audit_file:
                                lines = audit_file.readlines()
                                bat_file.writelines(lines)
                                bat_file.write(f'\n')
                        if ('eleven') in str(db_file):
                            with open('Templates\\Eleven\\auditpol_eleven', 'r') as audit_file:
                                lines = audit_file.readlines()
                                bat_file.writelines(lines)
                                bat_file.write(f'\n')
                        bat_file.write(f'gpupdate /force\n')
                        bat_file.write("auditpol /get /category:*\n")
                        bat_file.write(f'pause\n')
                        bat_file.write("echo Disabling optional services...\n")
                        bat_file.write(f'powershell "Disable-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2Root -norestart"\n')
                        bat_file.write(f'powershell "Disable-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2 -norestart"\n')
                        bat_file.write(f'powershell "Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -norestart"\n')
                    bat_file.write(f'\necho Adding register values...\n')
                auto_generation()
                print(f"Your .bat script saved: {abs_dir}")
                with open(filename + ".bat", 'a') as bat_file:
                    bat_file.write(f'echo Mission Accomplished! :)\n')
                    bat_file.write(f'pause\n')
                break
            case 'm':
                with open(filename + ".bat", 'w') as bat_file:
                    bat_file.write("@echo off\n\n")
                    bat_file.write("\necho Adding commands...\n")
                    
                    if any(keyword in str(db_file) for keyword in ['seven', 'eightzero', 'eightone', 'ten', 'eleven']):
                        bat_file.write("echo Enabling Restore Point service...\n")
                        bat_file.write("powershell \"Enable-ComputerRestore -Drive 'C:\\'\"\n")
                        bat_file.write("echo Creating restore point...\n")
                        bat_file.write(f'wmic.exe /Namespace:\\\\root\\default Path SystemRestore Call CreateRestorePoint "Before install the AHWT {filename} script", 100, 7\n')
                    elif ('vista') in str(db_file):
                        bat_file.write("echo Creating restore point...\n")
                        bat_file.write(f'wmic.exe /Namespace:\\\\root\\default Path SystemRestore Call CreateRestorePoint "Before install the AHWT {filename} script", 100, 7\n')
                    else:
                        bat_file.write("echo Enabling Restore Point service...\n")
                        bat_file.write("sc config srservice start= auto\n")
                        bat_file.write("net start srservice\n")
                        bat_file.write("echo Creating restore point...\n")
                        bat_file.write(f'wmic.exe /Namespace:\\\\root\\default Path SystemRestore Call CreateRestorePoint "Before install the AHWT {filename} script", 100, 7\n')
                    bat_file.write("echo Applying secedit configuration...\n")
                    bat_file.write(f'secedit /configure /db "secedit_db_{osname}.sdb" /areas securitypolicy group_mgmt user_rights filestore /cfg hisecdc_{osname}.inf\n')
                    bat_file.write("bcdedit /set {current} nx OptOut\n")
                
                    if any(keyword in str(db_file) for keyword in ['seven', 'eightzero', 'eightone']):
                        bat_file.write("echo Installing EMET...\n")
                        bat_file.write(f'msiexec /i "EMET Setup.msi" /qn /norestart\n')
                    if any(keyword in str(db_file) for keyword in ['seven', 'eightzero', 'eightone', 'ten', 'eleven']):
                        bat_file.write("echo Applying audit policies...\n")
                        bat_file.write(f'auditpol /clear /y\n')
                        if ('seven') in str(db_file):
                            with open('Templates\\Seven\\auditpol_seven', 'r') as audit_file:
                                lines = audit_file.readlines()
                                bat_file.writelines(lines)
                                bat_file.write(f'\n')
                        if ('eightzero') in str(db_file):
                            with open('Templates\\EightZero\\auditpol_eightzero', 'r') as audit_file:
                                lines = audit_file.readlines()
                                bat_file.writelines(lines)
                                bat_file.write(f'\n')
                        if ('eightone') in str(db_file):
                            with open('Templates\\EightOne\\auditpol_eightone', 'r') as audit_file:
                                lines = audit_file.readlines()
                                bat_file.writelines(lines)
                                bat_file.write(f'\n')
                        if ('ten') in str(db_file):
                            with open('Templates\\Ten\\auditpol_ten', 'r') as audit_file:
                                lines = audit_file.readlines()
                                bat_file.writelines(lines)
                                bat_file.write(f'\n')
                        if ('eleven') in str(db_file):
                            with open('Templates\\Eleven\\auditpol_eleven', 'r') as audit_file:
                                lines = audit_file.readlines()
                                bat_file.writelines(lines)
                        bat_file.write(f'gpupdate /force\n')
                        bat_file.write("auditpol /get /category:*\n")
                        bat_file.write(f'pause\n')
                        bat_file.write("echo Disabling optional services...\n")
                        bat_file.write(f'powershell "Disable-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2Root -norestart"\n')
                        bat_file.write(f'powershell "Disable-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2 -norestart"\n')
                        bat_file.write(f'powershell "Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -norestart"\n')
                    bat_file.write(f'\necho Adding register values...\n')
                manual_generation()
                print(f"Your .bat script saved: {abs_dir}")
                with open(filename + ".bat", 'a') as bat_file:
                    bat_file.write(f'echo Mission Accomplished! :)\n')
                    bat_file.write(f'pause\n')
                break
            case "add":
                addon_gen()
                break
            case _:
                print('Invalid input. Input must be "a" for auto generating, "m" for manual generating or "add" for generating for additional software\n')
    
    
def bitlocker_reg():
    if any(keyword in str(db_file) for keyword in ['seven', 'eightzero', 'eightone', 'ten', 'eleven']):     
            print("Do you want to add BitLocker registry values?")
            while True:
                bitlocker_input = str(input("\n Add (y/n)?: "))
                match bitlocker_input:
                    case 'y':
                        with open(filename + ".bat", 'a') as bat_file:
                            bat_file.write(f'\necho Adding BitLocker values... \n')
                        while True:
                            show_input = str(input("\n Show the parameters (y/n)?: "))
                            match show_input:
                                case 'n':
                                    with sqlite3.connect(db_file) as sqlite_conn:
                                        sql_request = """SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('BitLocker')"""
                                        sql_cursor = sqlite_conn.execute(sql_request)
                                        for record in sql_cursor:         
                                            record_value = record
                                            with open(filename + ".bat", 'a') as bat_file:
                                                bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                    break
                                case 'y':
                                    if internet() is False or "en" in current_lang_code:
                                        with sqlite3.connect(db_file) as sqlite_conn:
                                            sql_request = """SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('BitLocker')"""
                                            sql_cursor = sqlite_conn.execute(sql_request)
                                            for record in sql_cursor:         
                                                record_value = record
                                                print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f \n {record_value[4]} \n')
                                                while True:
                                                    answer_input = str(input("Apply (y/n)?: "))
                                                    match answer_input:
                                                        case 'y':
                                                            with open(filename + ".bat", 'a') as bat_file:
                                                                bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                                bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                            break
                                                        case 'n':
                                                            print("Skipping this register value...\n")
                                                            break
                                                        case _:
                                                            print('Invalid input. Input must be "y" or "n"\n')
                                            
                                    else:
                                        with sqlite3.connect(db_file) as sqlite_conn:
                                            sql_request = """SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('BitLocker')"""
                                            sql_cursor = sqlite_conn.execute(sql_request)
                                            for record in sql_cursor:         
                                                record_value = record
                                                translated = GoogleTranslator(source='auto', target=current_lang_code).translate(record_value[4])
                                                print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f \n {translated} \n')
                                                while True:
                                                    answer_input = str(input("Apply (y/n)?: "))
                                                    match answer_input:
                                                        case 'y':
                                                            with open(filename + ".bat", 'a') as bat_file:
                                                                bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                                bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                            break
                                                        case 'n':
                                                            print("Skipping this register value...\n")
                                                            break
                                                        case _:
                                                            print('Invalid input. Input must be "y" or "n"\n')
                                    break
                                case _:
                                    print('Invalid input. Input must be "y" or "n"\n')
                        break
                    case 'n':
                        print("Skipping BitLocker register values... \n")
                        break
                    case _:
                        print('Invalid input. Input must be "y" or "n" \n')

                 
    
def defender_reg():
    if any(keyword in str(db_file) for keyword in ['vista', 'seven', 'eightzero', 'eightone', 'ten', 'eleven']):     
            print("Do you want to add Defender registry values?")
            while True:
                defender_input = str(input("\n Add (y/n)?: "))
                match defender_input:
                    case 'y':
                        with open(filename + ".bat", 'a') as bat_file:
                            bat_file.write(f'\necho Adding Defender values... \n')
                        while True:
                            show_input = str(input("\n Show the parameters (y/n)?: "))
                            match show_input:
                                case 'n':
                                    with sqlite3.connect(db_file) as sqlite_conn:
                                        sql_request = """SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('Defender')"""
                                        sql_cursor = sqlite_conn.execute(sql_request)
                                        for record in sql_cursor:         
                                            record_value = record
                                            with open(filename + ".bat", 'a') as bat_file:
                                                bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                    break
                                case 'y':
                                    if internet() is False or "en" in current_lang_code:
                                        with sqlite3.connect(db_file) as sqlite_conn:
                                            sql_request = """SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('Defender')"""
                                            sql_cursor = sqlite_conn.execute(sql_request)
                                            for record in sql_cursor:         
                                                record_value = record
                                                print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f \n {record_value[4]} \n')
                                                while True:
                                                    answer_input = str(input("Apply (y/n)?: "))
                                                    match answer_input:
                                                        case 'y':
                                                            with open(filename + ".bat", 'a') as bat_file:
                                                                bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                                bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                            break
                                                        case 'n':
                                                            print("Skipping this register value...\n")
                                                            break
                                                        case _:
                                                            print('Invalid input. Input must be "y" or "n"\n')
                                            
                                    else:
                                        with sqlite3.connect(db_file) as sqlite_conn:
                                            sql_request = """SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('Defender')"""
                                            sql_cursor = sqlite_conn.execute(sql_request)
                                            for record in sql_cursor:         
                                                record_value = record
                                                translated = GoogleTranslator(source='auto', target=current_lang_code).translate(record_value[4])
                                                print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f \n {translated} \n')
                                                while True:
                                                    answer_input = str(input("Apply (y/n)?: "))  
                                                    match answer_input:  
                                                        case 'y':
                                                            with open(filename + ".bat", 'a') as bat_file:
                                                                bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                                bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                            break
                                                        case 'n':
                                                            print("Skipping this register value...\n")
                                                            break
                                                        case _:
                                                            print('Invalid input. Input must be "y" or "n"\n')
                                    break
                                case _:
                                    print('Invalid input. Input must be "y" or "n"\n')
                        break
                    case 'n':
                        print("Skipping Defender register values... \n")
                        break
                    case _:
                        print('Invalid input. Input must be "y" or "n" \n')


    
def edge_reg():
    if any(keyword in str(db_file) for keyword in ['ten', 'eleven']):
            print("Do you want to add Microsoft Edge registry values?")
            while True:
                edge_input = str(input("\n Add (y/n)?: "))
                match edge_input:
                    case 'y':
                        with open(filename + ".bat", 'a') as bat_file:
                            bat_file.write(f'\necho Adding Microsoft Edge values... \n')
                        while True:
                            show_input = str(input("\n Show the parameters (y/n)?: "))
                            match show_input:
                                case 'n':
                                    with sqlite3.connect(db_file) as sqlite_conn:
                                        sql_request = """SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('Edge')"""
                                        sql_cursor = sqlite_conn.execute(sql_request)
                                        for record in sql_cursor:         
                                            record_value = record
                                            with open(filename + ".bat", 'a') as bat_file:
                                                bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                    break
                                case 'y':
                                    if internet() is False or "en" in current_lang_code:
                                        with sqlite3.connect(db_file) as sqlite_conn:
                                            sql_request = """SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('Edge')"""
                                            sql_cursor = sqlite_conn.execute(sql_request)
                                            for record in sql_cursor:         
                                                record_value = record
                                                print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f \n {record_value[4]} \n')
                                                while True:
                                                    answer_input = str(input("Apply (y/n)?: "))
                                                    match answer_input:
                                                        case 'y':
                                                            with open(filename + ".bat", 'a') as bat_file:
                                                                bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                                bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                            break
                                                        case 'n':
                                                            print("Skipping this register value...\n")
                                                            break
                                                        case _:
                                                            print('Invalid input. Input must be "y" or "n"\n')
                                            
                                    else:
                                        with sqlite3.connect(db_file) as sqlite_conn:
                                            sql_request = """SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('Edge')"""
                                            sql_cursor = sqlite_conn.execute(sql_request)
                                            for record in sql_cursor:         
                                                record_value = record
                                                translated = GoogleTranslator(source='auto', target=current_lang_code).translate(record_value[4])
                                                print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f \n {translated} \n')
                                                while True:
                                                    answer_input = str(input("Apply (y/n)?: "))
                                                    match answer_input:
                                                        case 'y':
                                                            with open(filename + ".bat", 'a') as bat_file:
                                                                bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                                bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                            break
                                                        case 'n':
                                                            print("Skipping this register value...\n")
                                                            break
                                                        case _:
                                                            print('Invalid input. Input must be "y" or "n"\n')
                                    break
                                case _:
                                    print('Invalid input. Input must be "y" or "n"\n')
                        break
                    case 'n':
                        print("Skipping Microsoft Edge register values... \n")
                        break
                    case _:
                        print('Invalid input. Input must be "y" or "n" \n')
        
        
def firewall_reg():
           
    if any(keyword in str(db_file) for keyword in ['xp', 'vista','seven', 'eightzero', 'eightone', 'ten', 'eleven']):     
            print("Do you want to add Microsoft Firewall registry values?")
            while True:
                firewall_input = str(input("\n Add (y/n)?: "))
                match firewall_input:
                    case 'y':
                        with open(filename + ".bat", 'a') as bat_file:
                            bat_file.write(f'\necho Adding Microsoft Firewall values... \n')
                        while True:
                            show_input = str(input("\n Show the parameters (y/n)?: "))
                            match show_input:
                                case 'n':
                                    while True:
                                        shieldup_input = str(input("Apply ShieldUp Mode (Block all incoming connections, including those in the list of allowed apps) (y/n)?: "))
                                        match shieldup_input:
                                            case 'y':
                                                print("Adding ShieldUp register values...")
                                                break
                                            case 'n':
                                                print("Skipping ShieldUp register values...\n")
                                                break
                                            case _:
                                                print('Invalid input. Input must be "y" or "n"\n')
                                    with sqlite3.connect(db_file) as sqlite_conn:
                                        if any(keyword in str(db_file) for keyword in ['xp', 'vista']):
                                            sql_request = """SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('Firewall')"""
                                        else:
                                            sql_request = ("""
                                                    SELECT reg_key, reg_value, value_type, parameter, description 
                                                    FROM Main 
                                                    WHERE profile IN ('Firewall') 
                                                    AND reg_key NOT IN ('HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile')
                                                    AND reg_key NOT IN ('HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile\Logging')
                                                    AND reg_key NOT IN ('HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\WindowsFirewall\StandardProfile')
                                                    AND reg_key NOT IN ('HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\WindowsFirewall\StandardProfile\Logging')
                                                    """)
                                        sql_cursor = sqlite_conn.execute(sql_request)
                                        for record in sql_cursor:         
                                            record_value = record
                                            if "DoNotAllowExceptions" in record_value[1]:
                                                if shieldup_input == 'y':
                                                    with open(filename + ".bat", 'a') as bat_file:
                                                        bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                        bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                continue
                                            with open(filename + ".bat", 'a') as bat_file:
                                                bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                    break
                                case 'y':
                                    if internet() is False or "en" in current_lang_code:
                                        with sqlite3.connect(db_file) as sqlite_conn:
                                            if any(keyword in str(db_file) for keyword in ['xp', 'vista']):
                                                sql_request = """SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('Firewall')"""
                                            else:
                                                sql_request = ("""
                                                    SELECT reg_key, reg_value, value_type, parameter, description 
                                                    FROM Main 
                                                    WHERE profile IN ('Firewall') 
                                                    AND reg_key NOT IN ('HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile')
                                                    AND reg_key NOT IN ('HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile\Logging')
                                                    AND reg_key NOT IN ('HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\WindowsFirewall\StandardProfile')
                                                    AND reg_key NOT IN ('HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\WindowsFirewall\StandardProfile\Logging')
                                                    """)
                                            sql_cursor = sqlite_conn.execute(sql_request)
                                            for record in sql_cursor:         
                                                record_value = record
                                                print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f \n {record_value[4]} \n')
                                                while True:
                                                    answer_input = str(input("Apply (y/n)?: "))
                                                    match answer_input:
                                                        case 'y':
                                                            with open(filename + ".bat", 'a') as bat_file:
                                                                bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                                bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                            break
                                                        case 'n':
                                                            print("Skipping this register value...\n")
                                                            break
                                                        case _:
                                                            print('Invalid input. Input must be "y" or "n"\n')
                                        
                                    else:
                                        with sqlite3.connect(db_file) as sqlite_conn:
                                            if any(keyword in str(db_file) for keyword in ['xp', 'vista']):
                                                sql_request = """SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('Firewall')"""
                                            else:
                                                sql_request = ("""
                                                    SELECT reg_key, reg_value, value_type, parameter, description 
                                                    FROM Main 
                                                    WHERE profile IN ('Firewall') 
                                                    AND reg_key NOT IN ('HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile')
                                                    AND reg_key NOT IN ('HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile\Logging')
                                                    AND reg_key NOT IN ('HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\WindowsFirewall\StandardProfile')
                                                    AND reg_key NOT IN ('HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\WindowsFirewall\StandardProfile\Logging')
                                                    """)
                                            sql_cursor = sqlite_conn.execute(sql_request)
                                            for record in sql_cursor:         
                                                record_value = record
                                                translated = GoogleTranslator(source='auto', target=current_lang_code).translate(record_value[4])
                                                print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f \n {translated} \n')
                                                while True:
                                                    answer_input = str(input("Apply (y/n)?: "))
                                                    match answer_input:
                                                        case 'y':
                                                            with open(filename + ".bat", 'a') as bat_file:
                                                                bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                                bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                            break
                                                        case 'n':
                                                            print("Skipping this register value...\n")
                                                            break
                                                        case _:
                                                            print('Invalid input. Input must be "y" or "n"\n')
                                    break
                                case _:
                                    print('Invalid input. Input must be "y" or "n"\n')
                        break
                    case 'n':
                        print("Skipping Microsoft Firewall register values... \n")
                        break
                    case _:
                        print('Invalid input. Input must be "y" or "n" \n')

        
        
def ng_reg():
    if any(keyword in str(db_file) for keyword in ['ten', 'eleven']):
            print("Do you want to add Next Generation security registry values?")
            while True:
                ng_input = str(input("\n Add (y/n)?: "))
                match ng_input:
                    case 'y':
                        with open(filename + ".bat", 'a') as bat_file:
                            bat_file.write(f'\necho Adding Next Generation security values... \n')
                        while True:
                            show_input = str(input("\n Show the parameters (y/n)?: "))
                            match show_input:
                                case 'n':
                                    with sqlite3.connect(db_file) as sqlite_conn:
                                        sql_request = """SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('Next Generation')"""
                                        sql_cursor = sqlite_conn.execute(sql_request)
                                        for record in sql_cursor:         
                                            record_value = record
                                            with open(filename + ".bat", 'a') as bat_file:
                                                bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                    break
                                case 'y':
                                    if internet() is False or "en" in current_lang_code:
                                        with sqlite3.connect(db_file) as sqlite_conn:
                                            sql_request = """SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('Next Generation')"""
                                            sql_cursor = sqlite_conn.execute(sql_request)
                                            for record in sql_cursor:         
                                                record_value = record
                                                print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f \n {record_value[4]} \n')
                                                while True:
                                                    answer_input = str(input("Apply (y/n)?: "))
                                                    match answer_input:
                                                        case 'y':
                                                            with open(filename + ".bat", 'a') as bat_file:
                                                                bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                                bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                            break
                                                        case 'n':
                                                            print("Skipping this register value...\n")
                                                            break
                                                        case _:
                                                            print('Invalid input. Input must be "y" or "n"\n')
                                    
                                    else:
                                        with sqlite3.connect(db_file) as sqlite_conn:
                                            sql_request = """SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('Next Generation')"""
                                            sql_cursor = sqlite_conn.execute(sql_request)
                                            for record in sql_cursor:         
                                                record_value = record
                                                translated = GoogleTranslator(source='auto', target=current_lang_code).translate(record_value[4])
                                                print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f \n {translated} \n')
                                                while True:
                                                    answer_input = str(input("Apply (y/n)?: "))
                                                    match answer_input:
                                                        case 'y':
                                                            with open(filename + ".bat", 'a') as bat_file:
                                                                bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                                bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                            break
                                                        case 'n':
                                                            print("Skipping this register value...\n")
                                                            break
                                                        case _:
                                                            print('Invalid input. Input must be "y" or "n"\n')
                                    break
                                case _:
                                    print('Invalid input. Input must be "y" or "n"\n')
                        break
                    case 'n':
                        print("Skipping Next Generation security register values... \n")
                        break
                    case _:
                        print('Invalid input. Input must be "y" or "n" \n')
                        
                        
def iexplore_reg():
           
    if any(keyword in str(db_file) for keyword in ['xp', 'vista','seven', 'eightzero', 'eightone', 'ten']):     
        print("Do you want to add Internet Explorer registry values?")
        while True:
            iexplore_input = str(input("\n Add (y/n)?: "))
            match iexplore_input:
                case 'y':
                    with open(filename + ".bat", 'a') as bat_file:
                        bat_file.write(f'\necho Adding Internet Explorer values... \n')
                    while True:
                        show_input = str(input("\n Show the parameters (y/n)?: "))
                        match show_input:
                            case 'n':

                                if any(keyword in str(db_file) for keyword in ['xp']):
                                    while True:
                                        choose_input = str(input("\nWhat version of IE you want to harden? (ie6/ie7/ie8)?: "))
                                        match choose_input:
                                            case 'ie6':
                                                with sqlite3.connect(db_file) as sqlite_conn:
                                                    sql_request = ("""SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('ie6')""")
                                                    sql_cursor = sqlite_conn.execute(sql_request)
                                                    for record in sql_cursor:         
                                                        record_value = record
                                                        with open(filename + ".bat", 'a') as bat_file:
                                                            bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                            bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                break
                                            case 'ie7':
                                                with sqlite3.connect(db_file) as sqlite_conn:
                                                    sql_request = ("""SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('ie6', 'ie7')""")
                                                    sql_cursor = sqlite_conn.execute(sql_request)
                                                    for record in sql_cursor:         
                                                        record_value = record
                                                        with open(filename + ".bat", 'a') as bat_file:
                                                            bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                            bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                break
                                            case 'ie8':
                                                with sqlite3.connect(db_file) as sqlite_conn:
                                                    sql_request = ("""SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('ie6', 'ie7', 'ie8')""")
                                                    sql_cursor = sqlite_conn.execute(sql_request)
                                                    for record in sql_cursor:         
                                                        record_value = record
                                                        with open(filename + ".bat", 'a') as bat_file:
                                                            bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                            bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                break
                                            case _:
                                                print('Invalid input. Input must be "ie6", "ie7" or "ie8" \n')
                                if any(keyword in str(db_file) for keyword in ['vista']):
                                    while True:
                                        choose_input = str(input("\nWhat version of IE you want to harden? (ie7/ie8/ie9)?: "))
                                        match choose_input:
                                            case 'ie7':
                                                with sqlite3.connect(db_file) as sqlite_conn:
                                                    sql_request = ("""SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('ie7')""")
                                                    sql_cursor = sqlite_conn.execute(sql_request)
                                                    for record in sql_cursor:         
                                                        record_value = record
                                                        with open(filename + ".bat", 'a') as bat_file:
                                                            bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                            bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                break
                                            case 'ie8':
                                                with sqlite3.connect(db_file) as sqlite_conn:
                                                    sql_request = ("""SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('ie7', 'ie8')""")
                                                    sql_cursor = sqlite_conn.execute(sql_request)
                                                    for record in sql_cursor:         
                                                        record_value = record
                                                        with open(filename + ".bat", 'a') as bat_file:
                                                            bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                            bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                break
                                            case 'ie9':
                                                with sqlite3.connect(db_file) as sqlite_conn:
                                                    sql_request = ("""SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('ie7', 'ie8', 'ie9')""")
                                                    sql_cursor = sqlite_conn.execute(sql_request)
                                                    for record in sql_cursor:         
                                                        record_value = record
                                                        with open(filename + ".bat", 'a') as bat_file:
                                                            bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                            bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                break
                                            case _:
                                                print('Invalid input. Input must be "ie7", "ie8" or "ie9" \n')
                                                
                                if any(keyword in str(db_file) for keyword in ['seven']):
                                    while True:
                                        choose_input = str(input("\nWhat version of IE you want to harden? (ie8/ie9/ie10/ie11)?: "))
                                        match choose_input:
                                            case 'ie8':
                                                with sqlite3.connect(db_file) as sqlite_conn:
                                                    sql_request = ("""SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('ie8')""")
                                                    sql_cursor = sqlite_conn.execute(sql_request)
                                                    for record in sql_cursor:         
                                                        record_value = record
                                                        with open(filename + ".bat", 'a') as bat_file:
                                                            bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                            bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                break
                                            case 'ie9':
                                                with sqlite3.connect(db_file) as sqlite_conn:
                                                    sql_request = ("""SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('ie8', 'ie9')""")
                                                    sql_cursor = sqlite_conn.execute(sql_request)
                                                    for record in sql_cursor:         
                                                        record_value = record
                                                        with open(filename + ".bat", 'a') as bat_file:
                                                            bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                            bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                break
                                            case 'ie10':
                                                with sqlite3.connect(db_file) as sqlite_conn:
                                                    sql_request = ("""SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('ie8', 'ie9', 'ie10')""")
                                                    sql_cursor = sqlite_conn.execute(sql_request)
                                                    for record in sql_cursor:         
                                                        record_value = record
                                                        with open(filename + ".bat", 'a') as bat_file:
                                                            bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                            bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                break
                                            case 'ie11':
                                                with sqlite3.connect(db_file) as sqlite_conn:
                                                    sql_request = ("""SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('ie8', 'ie9', 'ie10', 'ie11')""")
                                                    sql_cursor = sqlite_conn.execute(sql_request)
                                                    for record in sql_cursor:         
                                                        record_value = record
                                                        with open(filename + ".bat", 'a') as bat_file:
                                                            bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                            bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                break
                                            case _:
                                                print('Invalid input. Input must be "ie8", "ie9", "ie10" or "ie11" \n')
                                                
                                if any(keyword in str(db_file) for keyword in ['eightzero']):
                                    while True:
                                        choose_input = str(input("\nWhat version of IE you want to harden? (ie10/ie11)?: "))
                                        match choose_input:
                                            case 'ie10':
                                                with sqlite3.connect(db_file) as sqlite_conn:
                                                    sql_request = ("""SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('ie10')""")
                                                    sql_cursor = sqlite_conn.execute(sql_request)
                                                    for record in sql_cursor:         
                                                        record_value = record
                                                        with open(filename + ".bat", 'a') as bat_file:
                                                            bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                            bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                break
                                            case 'ie11':
                                                with sqlite3.connect(db_file) as sqlite_conn:
                                                    sql_request = ("""SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('ie10', 'ie11')""")
                                                    sql_cursor = sqlite_conn.execute(sql_request)
                                                    for record in sql_cursor:         
                                                        record_value = record
                                                        with open(filename + ".bat", 'a') as bat_file:
                                                            bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                            bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                break
                                            case _:
                                                print('Invalid input. Input must be "ie10" or "ie11" \n')
                                                
                                if any(keyword in str(db_file) for keyword in ['eightone']):
                                    with sqlite3.connect(db_file) as sqlite_conn:
                                        sql_request = ("""SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('ie11')""")
                                        sql_cursor = sqlite_conn.execute(sql_request)
                                        for record in sql_cursor:         
                                            record_value = record
                                            with open(filename + ".bat", 'a') as bat_file:
                                                bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                
                                if any(keyword in str(db_file) for keyword in ['ten']):
                                    with sqlite3.connect(db_file) as sqlite_conn:
                                        sql_request = ("""SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('ie11')""")
                                        sql_cursor = sqlite_conn.execute(sql_request)
                                        for record in sql_cursor:         
                                            record_value = record
                                            with open(filename + ".bat", 'a') as bat_file:
                                                bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                
                                break

                            case 'y':
                                if internet() is False or "en" in current_lang_code:
                                    if any(keyword in str(db_file) for keyword in ['xp']):
                                        while True:
                                            choose_input = str(input("\nWhat version of IE you want to harden? (ie6/ie7/ie8)?: "))
                                            match choose_input:
                                                case 'ie6':
                                                    with sqlite3.connect(db_file) as sqlite_conn:
                                                        sql_request = ("""SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('ie6')""")
                                                        sql_cursor = sqlite_conn.execute(sql_request)
                                                        for record in sql_cursor:         
                                                            record_value = record
                                                            print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f \n {record_value[4]} \n')
                                                            while True:
                                                                answer_input = str(input("Apply (y/n)?: "))
                                                                match answer_input:
                                                                    case 'y':
                                                                        with open(filename + ".bat", 'a') as bat_file:
                                                                            bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                                            bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                                        break
                                                                    case 'n':
                                                                        print("Skipping this register value...\n")
                                                                        break
                                                                    case _:
                                                                        print('Invalid input. Input must be "y" or "n"\n')
                                                    break
                                                case 'ie7':
                                                    with sqlite3.connect(db_file) as sqlite_conn:
                                                        sql_request = ("""SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('ie6', 'ie7')""")
                                                        sql_cursor = sqlite_conn.execute(sql_request)
                                                        for record in sql_cursor:         
                                                            record_value = record
                                                            print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f \n {record_value[4]} \n')
                                                            while True:
                                                                answer_input = str(input("Apply (y/n)?: "))
                                                                match answer_input:
                                                                    case 'y':
                                                                        with open(filename + ".bat", 'a') as bat_file:
                                                                            bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                                            bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                                        break
                                                                    case 'n':
                                                                        print("Skipping this register value...\n")
                                                                        break
                                                                    case _:
                                                                        print('Invalid input. Input must be "y" or "n"\n')
                                                    break
                                                case 'ie8':
                                                    with sqlite3.connect(db_file) as sqlite_conn:
                                                        sql_request = ("""SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('ie6', 'ie7', 'ie8')""")
                                                        sql_cursor = sqlite_conn.execute(sql_request)
                                                        for record in sql_cursor:         
                                                            record_value = record
                                                            print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f \n {record_value[4]} \n')
                                                            while True:
                                                                answer_input = str(input("Apply (y/n)?: "))
                                                                match answer_input:
                                                                    case 'y':
                                                                        with open(filename + ".bat", 'a') as bat_file:
                                                                            bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                                            bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                                        break
                                                                    case 'n':
                                                                        print("Skipping this register value...\n")
                                                                        break
                                                                    case _:
                                                                        print('Invalid input. Input must be "y" or "n"\n')
                                                    break
                                                case _:
                                                    print('Invalid input. Input must be "ie6", "ie7" or "ie8" \n')
                                    if any(keyword in str(db_file) for keyword in ['vista']):
                                        while True:
                                            choose_input = str(input("\nWhat version of IE you want to harden? (ie7/ie8/ie9)?: "))
                                            match choose_input:
                                                case 'ie7':
                                                    with sqlite3.connect(db_file) as sqlite_conn:
                                                        sql_request = ("""SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('ie7')""")
                                                        sql_cursor = sqlite_conn.execute(sql_request)
                                                        for record in sql_cursor:         
                                                            record_value = record
                                                            print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f \n {record_value[4]} \n')
                                                            while True:
                                                                answer_input = str(input("Apply (y/n)?: "))
                                                                match answer_input:
                                                                    case 'y':
                                                                        with open(filename + ".bat", 'a') as bat_file:
                                                                            bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                                            bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                                        break
                                                                    case 'n':
                                                                        print("Skipping this register value...\n")
                                                                        break
                                                                    case _:
                                                                        print('Invalid input. Input must be "y" or "n"\n')
                                                    break
                                                case 'ie8':
                                                    with sqlite3.connect(db_file) as sqlite_conn:
                                                        sql_request = ("""SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('ie7', 'ie8')
                                                                    AND profile IN ("{choose_input}")""")
                                                        sql_cursor = sqlite_conn.execute(sql_request)
                                                        for record in sql_cursor:         
                                                            record_value = record
                                                            print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f \n {record_value[4]} \n')
                                                            while True:
                                                                answer_input = str(input("Apply (y/n)?: "))
                                                                match answer_input:
                                                                    case 'y':
                                                                        with open(filename + ".bat", 'a') as bat_file:
                                                                            bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                                            bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                                        break
                                                                    case 'n':
                                                                        print("Skipping this register value...\n")
                                                                        break
                                                                    case _:
                                                                        print('Invalid input. Input must be "y" or "n"\n')
                                                    break
                                                case 'ie9':
                                                    with sqlite3.connect(db_file) as sqlite_conn:
                                                        sql_request = ("""SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('ie7', 'ie8', 'ie9')""")
                                                        sql_cursor = sqlite_conn.execute(sql_request)
                                                        for record in sql_cursor:         
                                                            record_value = record
                                                            print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f \n {record_value[4]} \n')
                                                            while True:
                                                                answer_input = str(input("Apply (y/n)?: "))
                                                                match answer_input:
                                                                    case 'y':
                                                                        with open(filename + ".bat", 'a') as bat_file:
                                                                            bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                                            bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                                        break
                                                                    case 'n':
                                                                        print("Skipping this register value...\n")
                                                                        break
                                                                    case _:
                                                                        print('Invalid input. Input must be "y" or "n"\n')
                                                    break
                                                case _:
                                                    print('Invalid input. Input must be "ie7", "ie8" or "ie9" \n')
                                                    
                                    if any(keyword in str(db_file) for keyword in ['seven']):
                                        while True:
                                            choose_input = str(input("\nWhat version of IE you want to harden? (ie8/ie9/ie10/ie11)?: "))
                                            match choose_input:
                                                case 'ie8':
                                                    with sqlite3.connect(db_file) as sqlite_conn:
                                                        sql_request = ("""SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('ie8')""")
                                                        sql_cursor = sqlite_conn.execute(sql_request)
                                                        for record in sql_cursor:         
                                                            record_value = record
                                                            print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f \n {record_value[4]} \n')
                                                            while True:
                                                                answer_input = str(input("Apply (y/n)?: "))
                                                                match answer_input:
                                                                    case 'y':
                                                                        with open(filename + ".bat", 'a') as bat_file:
                                                                            bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                                            bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                                        break
                                                                    case 'n':
                                                                        print("Skipping this register value...\n")
                                                                        break
                                                                    case _:
                                                                        print('Invalid input. Input must be "y" or "n"\n')
                                                    break
                                                case 'ie9':
                                                    with sqlite3.connect(db_file) as sqlite_conn:
                                                        sql_request = ("""SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('ie8', 'ie9')""")
                                                        sql_cursor = sqlite_conn.execute(sql_request)
                                                        for record in sql_cursor:         
                                                            record_value = record
                                                            print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f \n {record_value[4]} \n')
                                                            while True:
                                                                answer_input = str(input("Apply (y/n)?: "))
                                                                match answer_input:
                                                                    case 'y':
                                                                        with open(filename + ".bat", 'a') as bat_file:
                                                                            bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                                            bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                                        break
                                                                    case 'n':
                                                                        print("Skipping this register value...\n")
                                                                        break
                                                                    case _:
                                                                        print('Invalid input. Input must be "y" or "n"\n')
                                                    break
                                                case 'ie10':
                                                    with sqlite3.connect(db_file) as sqlite_conn:
                                                        sql_request = ("""SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('ie8', 'ie9', 'ie10')""")
                                                        sql_cursor = sqlite_conn.execute(sql_request)
                                                        for record in sql_cursor:         
                                                            record_value = record
                                                            print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f \n {record_value[4]} \n')
                                                            while True:
                                                                answer_input = str(input("Apply (y/n)?: "))
                                                                match answer_input:
                                                                    case 'y':
                                                                        with open(filename + ".bat", 'a') as bat_file:
                                                                            bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                                            bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                                        break
                                                                    case 'n':
                                                                        print("Skipping this register value...\n")
                                                                        break
                                                                    case _:
                                                                        print('Invalid input. Input must be "y" or "n"\n')
                                                    break
                                                case 'ie11':
                                                    with sqlite3.connect(db_file) as sqlite_conn:
                                                        sql_request = ("""SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('ie8', 'ie9', 'ie10', 'ie11')""")
                                                        sql_cursor = sqlite_conn.execute(sql_request)
                                                        for record in sql_cursor:         
                                                            record_value = record
                                                            print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f \n {record_value[4]} \n')
                                                            while True:
                                                                answer_input = str(input("Apply (y/n)?: "))
                                                                match answer_input:
                                                                    case 'y':
                                                                        with open(filename + ".bat", 'a') as bat_file:
                                                                            bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                                            bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                                        break
                                                                    case 'n':
                                                                        print("Skipping this register value...\n")
                                                                        break
                                                                    case _:
                                                                        print('Invalid input. Input must be "y" or "n"\n')
                                                    break
                                                case _:
                                                    print('Invalid input. Input must be "ie8", "ie9", "ie10" or "ie11" \n')
                                                    
                                    if any(keyword in str(db_file) for keyword in ['eightzero']):
                                        while True:
                                            choose_input = str(input("\nWhat version of IE you want to harden? (ie10/ie11)?: "))
                                            match choose_input:
                                                case 'ie10':
                                                    with sqlite3.connect(db_file) as sqlite_conn:
                                                        sql_request = ("""SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('ie10')""")
                                                        sql_cursor = sqlite_conn.execute(sql_request)
                                                        for record in sql_cursor:         
                                                            record_value = record
                                                            print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f \n {record_value[4]} \n')
                                                            while True:
                                                                answer_input = str(input("Apply (y/n)?: "))
                                                                match answer_input:
                                                                    case 'y':
                                                                        with open(filename + ".bat", 'a') as bat_file:
                                                                            bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                                            bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                                        break
                                                                    case 'n':
                                                                        print("Skipping this register value...\n")
                                                                        break
                                                                    case _:
                                                                        print('Invalid input. Input must be "y" or "n"\n')
                                                    break
                                                case 'ie11':
                                                    with sqlite3.connect(db_file) as sqlite_conn:
                                                        sql_request = ("""SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('ie10', 'ie11')""")
                                                        sql_cursor = sqlite_conn.execute(sql_request)
                                                        for record in sql_cursor:         
                                                            record_value = record
                                                            print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f \n {record_value[4]} \n')
                                                            while True:
                                                                answer_input = str(input("Apply (y/n)?: "))
                                                                match answer_input:
                                                                    case 'y':
                                                                        with open(filename + ".bat", 'a') as bat_file:
                                                                            bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                                            bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                                        break
                                                                    case 'n':
                                                                        print("Skipping this register value...\n")
                                                                        break
                                                                    case _:
                                                                        print('Invalid input. Input must be "y" or "n"\n')
                                                    break
                                                case _:
                                                    print('Invalid input. Input must be "ie10" or "ie11" \n')
                                                    
                                    if any(keyword in str(db_file) for keyword in ['eightone']):
                                        with sqlite3.connect(db_file) as sqlite_conn:
                                            sql_request = ("""SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('ie11')""")
                                            sql_cursor = sqlite_conn.execute(sql_request)
                                            for record in sql_cursor:         
                                                record_value = record
                                                print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f \n {record_value[4]} \n')
                                                while True:
                                                    answer_input = str(input("Apply (y/n)?: "))
                                                    match answer_input:
                                                        case 'y':
                                                            with open(filename + ".bat", 'a') as bat_file:
                                                                bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                                bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                            break
                                                        case 'n':
                                                            print("Skipping this register value...\n")
                                                            break
                                                        case _:
                                                            print('Invalid input. Input must be "y" or "n"\n')
                                                    
                                    if any(keyword in str(db_file) for keyword in ['ten']):
                                        with sqlite3.connect(db_file) as sqlite_conn:
                                            sql_request = ("""SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('ie11')""")
                                            sql_cursor = sqlite_conn.execute(sql_request)
                                            for record in sql_cursor:         
                                                record_value = record
                                                print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f \n {record_value[4]} \n')
                                                while True:
                                                    answer_input = str(input("Apply (y/n)?: "))
                                                    match answer_input:
                                                        case 'y':
                                                            with open(filename + ".bat", 'a') as bat_file:
                                                                bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                                bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                            break
                                                        case 'n':
                                                            print("Skipping this register value...\n")
                                                            break
                                                        case _:
                                                            print('Invalid input. Input must be "y" or "n"\n')
                                    
                                else:
                                    if any(keyword in str(db_file) for keyword in ['xp']):
                                        while True:
                                            choose_input = str(input("\nWhat version of IE you want to harden? (ie6/ie7/ie8)?: "))
                                            match choose_input:
                                                case 'ie6':
                                                    with sqlite3.connect(db_file) as sqlite_conn:
                                                        sql_request = ("""SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('ie6')""")
                                                        sql_cursor = sqlite_conn.execute(sql_request)
                                                        for record in sql_cursor:         
                                                            record_value = record
                                                            translated = GoogleTranslator(source='auto', target=current_lang_code).translate(record_value[4])
                                                            print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f \n {translated} \n')
                                                            while True:
                                                                answer_input = str(input("Apply (y/n)?: "))
                                                                match answer_input:
                                                                    case 'y':
                                                                        with open(filename + ".bat", 'a') as bat_file:
                                                                            bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                                            bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                                        break
                                                                    case 'n':
                                                                        print("Skipping this register value...\n")
                                                                        break
                                                                    case _:
                                                                        print('Invalid input. Input must be "y" or "n"\n')
                                                    break
                                                case 'ie7':
                                                    with sqlite3.connect(db_file) as sqlite_conn:
                                                        sql_request = ("""SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('ie6', 'ie7')""")
                                                        sql_cursor = sqlite_conn.execute(sql_request)
                                                        for record in sql_cursor:         
                                                            record_value = record
                                                            translated = GoogleTranslator(source='auto', target=current_lang_code).translate(record_value[4])
                                                            print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f \n {translated} \n')
                                                            while True:
                                                                answer_input = str(input("Apply (y/n)?: "))
                                                                match answer_input:
                                                                    case 'y':
                                                                        with open(filename + ".bat", 'a') as bat_file:
                                                                            bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                                            bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                                        break
                                                                    case 'n':
                                                                        print("Skipping this register value...\n")
                                                                        break
                                                                    case _:
                                                                        print('Invalid input. Input must be "y" or "n"\n')
                                                    break
                                                case 'ie8':
                                                    with sqlite3.connect(db_file) as sqlite_conn:
                                                        sql_request = ("""SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('ie6', 'ie7', 'ie8')""")
                                                        sql_cursor = sqlite_conn.execute(sql_request)
                                                        for record in sql_cursor:         
                                                            record_value = record
                                                            translated = GoogleTranslator(source='auto', target=current_lang_code).translate(record_value[4])
                                                            print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f \n {translated} \n')
                                                            while True:
                                                                answer_input = str(input("Apply (y/n)?: "))
                                                                match answer_input:
                                                                    case 'y':
                                                                        with open(filename + ".bat", 'a') as bat_file:
                                                                            bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                                            bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                                        break
                                                                    case 'n':
                                                                        print("Skipping this register value...\n")
                                                                        break
                                                                    case _:
                                                                        print('Invalid input. Input must be "y" or "n"\n')
                                                    break
                                                case _:
                                                    print('Invalid input. Input must be "ie6", "ie7" or "ie8" \n')
                                    if any(keyword in str(db_file) for keyword in ['vista']):
                                        while True:
                                            choose_input = str(input("\nWhat version of IE you want to harden? (ie7/ie8/ie9)?: "))
                                            match choose_input:
                                                case 'ie7':
                                                    with sqlite3.connect(db_file) as sqlite_conn:
                                                        sql_request = ("""SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('ie7')""")
                                                        sql_cursor = sqlite_conn.execute(sql_request)
                                                        for record in sql_cursor:         
                                                            record_value = record
                                                            translated = GoogleTranslator(source='auto', target=current_lang_code).translate(record_value[4])
                                                            print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f \n {translated} \n')
                                                            while True:
                                                                answer_input = str(input("Apply (y/n)?: "))
                                                                match answer_input:
                                                                    case 'y':
                                                                        with open(filename + ".bat", 'a') as bat_file:
                                                                            bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                                            bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                                        break
                                                                    case 'n':
                                                                        print("Skipping this register value...\n")
                                                                        break
                                                                    case _:
                                                                        print('Invalid input. Input must be "y" or "n"\n')
                                                    break
                                                case 'ie8':
                                                    with sqlite3.connect(db_file) as sqlite_conn:
                                                        sql_request = ("""SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('ie7', 'ie8')""")
                                                        sql_cursor = sqlite_conn.execute(sql_request)
                                                        for record in sql_cursor:         
                                                            record_value = record
                                                            translated = GoogleTranslator(source='auto', target=current_lang_code).translate(record_value[4])
                                                            print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f \n {translated} \n')
                                                            while True:
                                                                answer_input = str(input("Apply (y/n)?: "))
                                                                match answer_input:
                                                                    case 'y':
                                                                        with open(filename + ".bat", 'a') as bat_file:
                                                                            bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                                            bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                                        break
                                                                    case 'n':
                                                                        print("Skipping this register value...\n")
                                                                        break
                                                                    case _:
                                                                        print('Invalid input. Input must be "y" or "n"\n')
                                                    break
                                                case 'ie9':
                                                    with sqlite3.connect(db_file) as sqlite_conn:
                                                        sql_request = ("""SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('ie7', 'ie8', 'ie9')""")
                                                        sql_cursor = sqlite_conn.execute(sql_request)
                                                        for record in sql_cursor:         
                                                            record_value = record
                                                            translated = GoogleTranslator(source='auto', target=current_lang_code).translate(record_value[4])
                                                            print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f \n {translated} \n')
                                                            while True:
                                                                answer_input = str(input("Apply (y/n)?: "))
                                                                match answer_input:
                                                                    case 'y':
                                                                        with open(filename + ".bat", 'a') as bat_file:
                                                                            bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                                            bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                                        break
                                                                    case 'n':
                                                                        print("Skipping this register value...\n")
                                                                        break
                                                                    case _:
                                                                        print('Invalid input. Input must be "y" or "n"\n')
                                                    break
                                                case _:
                                                    print('Invalid input. Input must be "ie7", "ie8" or "ie9" \n')
                                                    
                                    if any(keyword in str(db_file) for keyword in ['seven']):
                                        while True:
                                            choose_input = str(input("\nWhat version of IE you want to harden? (ie8/ie9/ie10/ie11)?: "))
                                            match choose_input:
                                                case 'ie8':
                                                    with sqlite3.connect(db_file) as sqlite_conn:
                                                        sql_request = ("""SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('ie8')""")
                                                        sql_cursor = sqlite_conn.execute(sql_request)
                                                        for record in sql_cursor:         
                                                            record_value = record
                                                            translated = GoogleTranslator(source='auto', target=current_lang_code).translate(record_value[4])
                                                            print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f \n {translated} \n')
                                                            while True:
                                                                answer_input = str(input("Apply (y/n)?: "))
                                                                match answer_input:
                                                                    case 'y':
                                                                        with open(filename + ".bat", 'a') as bat_file:
                                                                            bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                                            bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                                        break
                                                                    case 'n':
                                                                        print("Skipping this register value...\n")
                                                                        break
                                                                    case _:
                                                                        print('Invalid input. Input must be "y" or "n"\n')
                                                    break
                                                case 'ie9':
                                                    with sqlite3.connect(db_file) as sqlite_conn:
                                                        sql_request = ("""SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('ie8', 'ie9')""")
                                                        sql_cursor = sqlite_conn.execute(sql_request)
                                                        for record in sql_cursor:         
                                                            record_value = record
                                                            translated = GoogleTranslator(source='auto', target=current_lang_code).translate(record_value[4])
                                                            print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f \n {translated} \n')
                                                            while True:
                                                                answer_input = str(input("Apply (y/n)?: "))
                                                                match answer_input:
                                                                    case 'y':
                                                                        with open(filename + ".bat", 'a') as bat_file:
                                                                            bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                                            bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                                        break
                                                                    case 'n':
                                                                        print("Skipping this register value...\n")
                                                                        break
                                                                    case _:
                                                                        print('Invalid input. Input must be "y" or "n"\n')
                                                    break
                                                case 'ie10':
                                                    with sqlite3.connect(db_file) as sqlite_conn:
                                                        sql_request = ("""SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('ie8', 'ie9', 'ie10')""")
                                                        sql_cursor = sqlite_conn.execute(sql_request)
                                                        for record in sql_cursor:         
                                                            record_value = record
                                                            translated = GoogleTranslator(source='auto', target=current_lang_code).translate(record_value[4])
                                                            print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f \n {translated} \n')
                                                            while True:
                                                                answer_input = str(input("Apply (y/n)?: "))
                                                                match answer_input:
                                                                    case 'y':
                                                                        with open(filename + ".bat", 'a') as bat_file:
                                                                            bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                                            bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                                        break
                                                                    case 'n':
                                                                        print("Skipping this register value...\n")
                                                                        break
                                                                    case _:
                                                                        print('Invalid input. Input must be "y" or "n"\n')
                                                    break
                                                case 'ie11':
                                                    with sqlite3.connect(db_file) as sqlite_conn:
                                                        sql_request = ("""SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('ie8', 'ie9', 'ie10', 'ie11')""")
                                                        sql_cursor = sqlite_conn.execute(sql_request)
                                                        for record in sql_cursor:         
                                                            record_value = record
                                                            translated = GoogleTranslator(source='auto', target=current_lang_code).translate(record_value[4])
                                                            print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f \n {translated} \n')
                                                            while True:
                                                                answer_input = str(input("Apply (y/n)?: "))
                                                                match answer_input:
                                                                    case 'y':
                                                                        with open(filename + ".bat", 'a') as bat_file:
                                                                            bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                                            bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                                        break
                                                                    case 'n':
                                                                        print("Skipping this register value...\n")
                                                                        break
                                                                    case _:
                                                                        print('Invalid input. Input must be "y" or "n"\n')
                                                    break
                                                case _:
                                                    print('Invalid input. Input must be "ie8", "ie9", "ie10" or "ie11" \n')
                                                    
                                    if any(keyword in str(db_file) for keyword in ['eightzero']):
                                        while True:
                                            choose_input = str(input("\nWhat version of IE you want to harden? (ie10/ie11)?: "))
                                            match choose_input:
                                                case 'ie10':
                                                    with sqlite3.connect(db_file) as sqlite_conn:
                                                        sql_request = ("""SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('ie10')""")
                                                        sql_cursor = sqlite_conn.execute(sql_request)
                                                        for record in sql_cursor:         
                                                            record_value = record
                                                            translated = GoogleTranslator(source='auto', target=current_lang_code).translate(record_value[4])
                                                            print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f \n {translated} \n')
                                                            while True:
                                                                answer_input = str(input("Apply (y/n)?: "))
                                                                match answer_input:
                                                                    case 'y':
                                                                        with open(filename + ".bat", 'a') as bat_file:
                                                                            bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                                            bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                                        break
                                                                    case 'n':
                                                                        print("Skipping this register value...\n")
                                                                        break
                                                                    case _:
                                                                        print('Invalid input. Input must be "y" or "n"\n')
                                                    break
                                                case 'ie11':
                                                    with sqlite3.connect(db_file) as sqlite_conn:
                                                        sql_request = ("""SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('ie10', 'ie11')""")
                                                        sql_cursor = sqlite_conn.execute(sql_request)
                                                        for record in sql_cursor:         
                                                            record_value = record
                                                            translated = GoogleTranslator(source='auto', target=current_lang_code).translate(record_value[4])
                                                            print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f \n {translated} \n')
                                                            while True:
                                                                answer_input = str(input("Apply (y/n)?: "))
                                                                match answer_input:
                                                                    case 'y':
                                                                        with open(filename + ".bat", 'a') as bat_file:
                                                                            bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                                            bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                                        break
                                                                    case 'n':
                                                                        print("Skipping this register value...\n")
                                                                        break
                                                                    case _:
                                                                        print('Invalid input. Input must be "y" or "n"\n')
                                                    break
                                                case _:
                                                    print('Invalid input. Input must be "ie10" or "ie11" \n')
                                                    
                                    if any(keyword in str(db_file) for keyword in ['eightone']):
                                        with sqlite3.connect(db_file) as sqlite_conn:
                                            sql_request = ("""SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('ie11')""")
                                            sql_cursor = sqlite_conn.execute(sql_request)
                                            for record in sql_cursor:         
                                                record_value = record
                                                translated = GoogleTranslator(source='auto', target=current_lang_code).translate(record_value[4])
                                                print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f \n {translated} \n')
                                                while True:
                                                    answer_input = str(input("Apply (y/n)?: "))
                                                    match answer_input:
                                                        case 'y':
                                                            with open(filename + ".bat", 'a') as bat_file:
                                                                bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                                bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                            break
                                                        case 'n':
                                                            print("Skipping this register value...\n")
                                                            break
                                                        case _:
                                                            print('Invalid input. Input must be "y" or "n"\n')
                                                    
                                    if any(keyword in str(db_file) for keyword in ['ten']):
                                        with sqlite3.connect(db_file) as sqlite_conn:
                                            sql_request = ("""SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('ie11')""")
                                            sql_cursor = sqlite_conn.execute(sql_request)
                                            for record in sql_cursor:         
                                                record_value = record
                                                translated = GoogleTranslator(source='auto', target=current_lang_code).translate(record_value[4])
                                                print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f \n {translated} \n')
                                                while True:
                                                    answer_input = str(input("Apply (y/n)?: "))
                                                    match answer_input:
                                                        case 'y':
                                                            with open(filename + ".bat", 'a') as bat_file:
                                                                bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                                bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                            break
                                                        case 'n':
                                                            print("Skipping this register value...\n")
                                                            break
                                                        case _:
                                                            print('Invalid input. Input must be "y" or "n"\n')
                                                            
                                break
                            case _:
                                print('Invalid input. Input must be "y" or "n"\n')
                    break
                case 'n':
                    print("Skipping Internet Explorer register values... \n")
                    break
                case _:
                    print('Invalid input. Input must be "y" or "n" \n')


def manual_generation():
    def answer_function():
        while True:
            answer_input = str(input("Apply (y/n)?: "))
            match answer_input:
                case 'y':
                    with open(filename + ".bat", 'a') as bat_file:
                        bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                        bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                    break
                case 'n':
                    print("Skipping this register value...\n")
                    break
                case _:
                    print('Invalid input. Input must be "y" or "n"\n')
    
    def ntp_change():
        while True:
            print("Do you want to change NTP Server (default server: time.windows.com)?")
            ntp_input = str(input("\n Change (y/n)?: "))
            match ntp_input:
                case 'n':
                    with open(filename + ".bat", 'a') as bat_file:
                        bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                        bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                    break
                case 'y':
                    ntp_srv = str(input("Enter the server: "))
                    with open(filename + ".bat", 'a') as bat_file:
                        bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{ntp_srv}" /f\n')
                        bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{ntp_srv}" /f\n')
                    break
                case _:
                    print('Invalid input. Input must be "y" or "n" \n')
            
    
    def delete_reg():
        while True:
            print("Do you want to delete this registry value?")
            delete_input = str(input("\n Delete (y/n)?: "))
            match delete_input:
                case 'y':
                    with open(filename + ".bat", 'a') as bat_file:
                        bat_file.write(f'echo Deleting "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                        bat_file.write(f'reg delete "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                    break
                case 'n':
                    print("Skipping this register value... \n")
                    break
                case _:
                    print('Invalid input. Input must be "y" or "n" \n')
                
           
    with sqlite3.connect(db_file) as sqlite_conn:
        sql_request = """SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile NOT IN ('BitLocker', 'Defender', 'Edge', 'Firewall', 'Next Generation')"""
        sql_cursor = sqlite_conn.execute(sql_request)
        if internet() is False or "en" in current_lang_code:
            for record in sql_cursor:         
                record_value = record
                print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f \n {record_value[4]} \n')
                if "NTPServer" in record_value[4]:
                    ntp_change()
                    continue
                if "POSIX" not in record_value[4]:
                    answer_function()
                else:
                    delete_reg()
            bitlocker_reg()
            defender_reg()
            edge_reg()
            firewall_reg()
            ng_reg()
            iexplore_reg()
        else:
            for record in sql_cursor:         
                record_value = record
                translated = GoogleTranslator(source='auto', target=current_lang_code).translate(record_value[4])
                print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f \n {translated} \n')
                if "NTPServer" in record_value[4]:
                    ntp_change()
                    continue
                if "POSIX" not in record_value[4]:
                    answer_function()
                else:
                    delete_reg()
            bitlocker_reg()
            defender_reg()
            edge_reg()
            firewall_reg()
            ng_reg()
            iexplore_reg()

            
            
def auto_generation():
    while True:
        auto_profile = str(input("Enter the level of hardening (min/med/full): "))
        match auto_profile:
            case 'full':
                with sqlite3.connect(db_file) as sqlite_conn:
                    sql_request = """SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile NOT IN ('BitLocker', 'Defender', 'Edge', 'Firewall', 'Next Generation', 'ie6', 'ie7', 'ie8', 'ie9', 'ie10', 'ie11')"""
                    sql_cursor = sqlite_conn.execute(sql_request)
                    for record in sql_cursor:         
                        record_value = record
                        if "POSIX" not in record_value[4]:
                            with open(filename + ".bat", 'a') as bat_file:
                                bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                        else:
                            with open(filename + ".bat", 'a') as bat_file:
                                bat_file.write(f'echo Deleting "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                bat_file.write(f'reg delete "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                bitlocker_reg()
                defender_reg()
                edge_reg()
                firewall_reg()
                ng_reg()
                iexplore_reg()
                break
            case 'med':
                with sqlite3.connect(db_file) as sqlite_conn:
                    sql_request = """SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile NOT IN ('BitLocker', 'Defender', 'Edge', 'Firewall', 'Next Generation', 'Full', 'ie6', 'ie7', 'ie8', 'ie9', 'ie10', 'ie11')"""
                    sql_cursor = sqlite_conn.execute(sql_request)
                    for record in sql_cursor:         
                        record_value = record
                        if "POSIX" not in record_value[4]:
                            with open(filename + ".bat", 'a') as bat_file:
                                bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                        else:
                            with open(filename + ".bat", 'a') as bat_file:
                                bat_file.write(f'echo Deleting "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                bat_file.write(f'reg delete "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                    bitlocker_reg()
                    defender_reg()
                    edge_reg()
                    firewall_reg()
                    ng_reg()
                    iexplore_reg()
                break
            case 'min':
                with sqlite3.connect(db_file) as sqlite_conn:
                    sql_request = """SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile NOT IN ('BitLocker', 'Defender', 'Edge', 'Firewall', 'Next Generation', 'Full', 'Med', 'ie6', 'ie7', 'ie8', 'ie9', 'ie10', 'ie11')"""
                    sql_cursor = sqlite_conn.execute(sql_request)
                    for record in sql_cursor:         
                        record_value = record
                        if "POSIX" not in record_value[4]:
                            with open(filename + ".bat", 'a') as bat_file:
                                bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                        else:
                            with open(filename + ".bat", 'a') as bat_file:
                                bat_file.write(f'echo Deleting "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                bat_file.write(f'reg delete "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                    bitlocker_reg()
                    defender_reg()
                    edge_reg()
                    firewall_reg()
                    ng_reg()
                    iexplore_reg()
                break
            case _:
                print('Invalid input. Input must be "min", "med" or "full" \n')
            

def addon_gen():
    if any(keyword in str(db_file) for keyword in ['xp', 'vista']):
        while True:
            addon_profile = str(input("Enter the type of additional parameters you want (firewall/iexplorer/none): "))
            match addon_profile:
                case 'firewall':
                    with open(filename + ".bat", 'w') as bat_file:
                        bat_file.write("@echo off\n\n")
                        bat_file.write("echo Creating restore point...\n")
                        bat_file.write(f'wmic.exe /Namespace:\\\\root\default Path SystemRestore Call CreateRestorePoint "Before install the AHWT {filename} script", 100, 7\n')
                    firewall_reg()
                    print(f"Your .bat script saved: {abs_dir}")
                    with open(filename + ".bat", 'a') as bat_file:
                        bat_file.write(f'echo Mission Accomplished! :)\n')
                        bat_file.write(f'pause\n')
                    break
                case 'iexplorer':
                    with open(filename + ".bat", 'w') as bat_file:
                        bat_file.write("@echo off\n\n")
                        bat_file.write("echo Creating restore point...\n")
                        bat_file.write(f'wmic.exe /Namespace:\\\\root\default Path SystemRestore Call CreateRestorePoint "Before install the AHWT {filename} script", 100, 7\n')
                    iexplore_reg()
                    print(f"Your .bat script saved: {abs_dir}")
                    with open(filename + ".bat", 'a') as bat_file:
                        bat_file.write(f'echo Mission Accomplished! :)\n')
                        bat_file.write(f'pause\n')
                    break
                case 'none':
                    print("Returning...")
                    break
                case _:
                    print('Invalid input. Input must be "firewall", "iexplorer" or "none" \n')
    if any(keyword in str(db_file) for keyword in ['seven', 'eightzero', 'eightone']):
        while True:
            addon_profile = str(input("Enter the type of additional parameters you want (bitlocker/defender/firewall/iexplorer/none): "))
            match addon_profile:
                case 'bitlocker':
                    with open(filename + ".bat", 'w') as bat_file:
                        bat_file.write("@echo off\n\n")
                        bat_file.write("echo Creating restore point...\n")
                        bat_file.write(f'wmic.exe /Namespace:\\\\root\\default Path SystemRestore Call CreateRestorePoint "Before install the AHWT {filename} script", 100, 7\n')
                    bitlocker_reg()
                    print(f"Your .bat script saved: {abs_dir}")
                    with open(filename + ".bat", 'a') as bat_file:
                        bat_file.write(f'echo Mission Accomplished! :)\n')
                        bat_file.write(f'pause\n')
                    break
                case 'defender':
                    with open(filename + ".bat", 'w') as bat_file:
                        bat_file.write("@echo off\n\n")
                        bat_file.write("echo Creating restore point...\n")
                        bat_file.write(f'wmic.exe /Namespace:\\\\root\\default Path SystemRestore Call CreateRestorePoint "Before install the AHWT {filename} script", 100, 7\n')
                    defender_reg()
                    print(f"Your .bat script saved: {abs_dir}")
                    with open(filename + ".bat", 'a') as bat_file:
                        bat_file.write(f'echo Mission Accomplished! :)\n')
                        bat_file.write(f'pause\n')
                    break
                case 'firewall':
                    with open(filename + ".bat", 'w') as bat_file:
                        bat_file.write("@echo off\n\n")
                        bat_file.write("echo Creating restore point...\n")
                        bat_file.write(f'wmic.exe /Namespace:\\\\root\\default Path SystemRestore Call CreateRestorePoint "Before install the AHWT {filename} script", 100, 7\n')
                    firewall_reg()
                    print(f"Your .bat script saved: {abs_dir}")
                    with open(filename + ".bat", 'a') as bat_file:
                        bat_file.write(f'echo Mission Accomplished! :)\n')
                        bat_file.write(f'pause\n')
                    break
                case 'iexplorer':
                    with open(filename + ".bat", 'w') as bat_file:
                        bat_file.write("@echo off\n\n")
                        bat_file.write("echo Creating restore point...\n")
                        bat_file.write(f'wmic.exe /Namespace:\\\\root\default Path SystemRestore Call CreateRestorePoint "Before install the AHWT {filename} script", 100, 7\n')
                    iexplore_reg()
                    print(f"Your .bat script saved: {abs_dir}")
                    with open(filename + ".bat", 'a') as bat_file:
                        bat_file.write(f'echo Mission Accomplished! :)\n')
                        bat_file.write(f'pause\n')
                    break
                case 'none':
                    print("Returning...")
                    break
                case _:
                    print('Invalid input. Input must be "bitlocker", "defender", "firewall", "iexplorer" or "none" \n')
    if any(keyword in str(db_file) for keyword in ['ten', 'eleven']):
        while True:
            addon_profile = str(input("Enter the type of additional parameters you want (bitlocker/defender/edge/firewall/ng/iexplorer/none): "))
            match addon_profile:
                case 'bitlocker':
                    with open(filename + ".bat", 'w') as bat_file:
                        bat_file.write("@echo off\n\n")
                        bat_file.write("echo Creating restore point...\n")
                        bat_file.write(f'wmic.exe /Namespace:\\\\root\\default Path SystemRestore Call CreateRestorePoint "Before install the AHWT {filename} script", 100, 7\n')
                    bitlocker_reg()
                    print(f"Your .bat script saved: {abs_dir}")
                    with open(filename + ".bat", 'a') as bat_file:
                        bat_file.write(f'echo Mission Accomplished! :)\n')
                        bat_file.write(f'pause\n')
                    break
                case 'defender':
                    with open(filename + ".bat", 'w') as bat_file:
                        bat_file.write("@echo off\n\n")
                        bat_file.write("echo Creating restore point...\n")
                        bat_file.write(f'wmic.exe /Namespace:\\\\root\\default Path SystemRestore Call CreateRestorePoint "Before install the AHWT {filename} script", 100, 7\n')
                    defender_reg()
                    print(f"Your .bat script saved: {abs_dir}")
                    with open(filename + ".bat", 'a') as bat_file:
                        bat_file.write(f'echo Mission Accomplished! :)\n')
                        bat_file.write(f'pause\n')
                    break
                case 'edge':
                    with open(filename + ".bat", 'w') as bat_file:
                        bat_file.write("@echo off\n\n")
                        bat_file.write("echo Creating restore point...\n")
                        bat_file.write(f'wmic.exe /Namespace:\\\\root\\default Path SystemRestore Call CreateRestorePoint "Before install the AHWT {filename} script", 100, 7\n')
                    edge_reg()
                    print(f"Your .bat script saved: {abs_dir}")
                    with open(filename + ".bat", 'a') as bat_file:
                        bat_file.write(f'echo Mission Accomplished! :)\n')
                        bat_file.write(f'pause\n')
                    break
                case 'firewall':
                    with open(filename + ".bat", 'w') as bat_file:
                        bat_file.write("@echo off\n\n")
                        bat_file.write("echo Creating restore point...\n")
                        bat_file.write(f'wmic.exe /Namespace:\\\\root\\default Path SystemRestore Call CreateRestorePoint "Before install the AHWT {filename} script", 100, 7\n')
                    firewall_reg()
                    print(f"Your .bat script saved: {abs_dir}")
                    with open(filename + ".bat", 'a') as bat_file:
                        bat_file.write(f'echo Mission Accomplished! :)\n')
                        bat_file.write(f'pause\n')
                    break
                case "ng":
                    with open(filename + ".bat", 'w') as bat_file:
                        bat_file.write("@echo off\n\n")
                        bat_file.write("echo Creating restore point...\n")
                        bat_file.write(f'wmic.exe /Namespace:\\\\root\\default Path SystemRestore Call CreateRestorePoint "Before install the AHWT {filename} script", 100, 7\n')
                    ng_reg()
                    print(f"Your .bat script saved: {abs_dir}")
                    with open(filename + ".bat", 'a') as bat_file:
                        bat_file.write(f'echo Mission Accomplished! :)\n')
                        bat_file.write(f'pause\n')
                    break
                case 'iexplorer':
                    with open(filename + ".bat", 'w') as bat_file:
                        bat_file.write("@echo off\n\n")
                        bat_file.write("echo Creating restore point...\n")
                        bat_file.write(f'wmic.exe /Namespace:\\\\root\default Path SystemRestore Call CreateRestorePoint "Before install the AHWT {filename} script", 100, 7\n')
                    iexplore_reg()
                    print(f"Your .bat script saved: {abs_dir}")
                    with open(filename + ".bat", 'a') as bat_file:
                        bat_file.write(f'echo Mission Accomplished! :)\n')
                        bat_file.write(f'pause\n')
                    break
                case 'none':
                    print("Returning...")
                    break
                case _:
                    print('Invalid input. Input must be "bitlocker", "defender", "edge", "firewall", "ng", "iexplorer" or "none" \n')


def office_gen():  
    
    def answer_function():
        while True:
            answer_input = str(input("Apply (y/n)?: "))
            match answer_input:
                case 'y':
                    with open(filename + ".bat", 'a') as bat_file:
                        bat_file.write(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                        bat_file.write(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                    break
                case 'n':
                    print("Skipping this register value...\n")
                    break
                case _:
                    print('Invalid input. Input must be "y" or "n"\n')
               
                    
    def answer_function_hkcu():
        while True:
            answer_input = str(input("Apply (y/n)?: "))
            match answer_input:
                case 'y':
                    with open(filename + ".bat", 'a') as bat_file:
                        bat_file.write(f'    echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                        bat_file.write(f'    reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                    break
                case 'n':
                    print("Skipping this register value...\n")
                    break
                case _:
                    print('Invalid input. Input must be "y" or "n"\n')
                    
    
    def delete_reg():
        while True:
            print("Do you want to delete this registry value?")
            delete_input = str(input("\n Delete (y/n)?: "))
            match delete_input:
                case 'y':
                    with open(filename + ".bat", 'a') as bat_file:
                        bat_file.write(f'echo Deleting "{record_value[0]}" /v "{record_value[1]}" /f\n')
                        bat_file.write(f'reg delete "{record_value[0]}" /v "{record_value[1]}" /f\n')
                    break
                case 'n':
                    print("Skipping this register value... \n")
                    break
                case _:
                    print('Invalid input. Input must be "y" or "n" \n')
                    
    
    def delete_reg_hkcu():
        while True:
            print("Do you want to delete this registry value?")
            delete_input = str(input("\n Delete (y/n)?: "))
            match delete_input:
                case 'y':
                    with open(filename + ".bat", 'a') as bat_file:
                        bat_file.write(f'    echo Deleting "{record_value[0]}" /v "{record_value[1]}" /f\n')
                        bat_file.write(f'    reg delete "{record_value[0]}" /v "{record_value[1]}" /f\n')
                    break
                case 'n':
                    print("Skipping this register value... \n")
                    break
                case _:
                    print('Invalid input. Input must be "y" or "n" \n')
    
    def hkcu_before_param():
        batch_cycle = """
        @echo off
        setlocal enabledelayedexpansion

        for /f "tokens=*" %%a in ('reg query HKU ^| findstr /r /c:"HKEY_USERS\\\\S-1-5-21-[0-9]*-[0-9]*-[0-9]*-[0-9]*"') do (
            set "user=%%a"
            set "user=!user:HKEY_USERS=HKU!"
            echo Found User: !user!
            
            """
        with open(filename + ".bat", 'a') as bat_file:
            bat_file.writelines(batch_cycle)
            
    def hkcu_after_param():
        batch_cycle = """
        
            reg add "!user!\\Software\\Microsoft\\Office\\11.0\\Common" /v QMEnable /t REG_DWORD /d 0 /f
            if errorlevel 1 (
                echo An error occurred while adding the parameter for !user!
                exit /b 1
            )
            echo Parameter added for !user!
        )

        echo All users in HKU have been successfully processed.

        endlocal
        
        
        """
        with open(filename + ".bat", 'a') as bat_file:
            bat_file.write(batch_cycle)
        replace_hkcu()
    
    
    def replace_hkcu():
        with open(filename + ".bat", 'r') as bat_file:
            replace_users_key = bat_file.read()
        
        updated_users_key = replace_users_key.replace('HKEY_CURRENT_USER', '!user!')
        
        with open(filename + ".bat", 'w') as bat_file:
            bat_file.write(updated_users_key)
    
    with open(filename + ".bat", 'w') as bat_file:
        bat_file.write("@echo off\n\n")
        bat_file.write("\necho Adding commands...\n\n")
        
    while True:
        restore_choice = str(input("Do you need to create the restore point before applying script? (y/n): "))
        match restore_choice:
            case 'y':
                while True:
                    os_restore_choice = str(input("Choose the operating system (xp/vista/seven/eight/eightone/ten/eleven): "))
                    match os_restore_choice:
                        case 'xp':
                            with open(filename + ".bat", 'a') as bat_file:
                                bat_file.write("echo Enabling Restore Point service...\n")
                                bat_file.write("sc config srservice start= auto\n")
                                bat_file.write("net start srservice\n")
                                bat_file.write("echo Creating restore point...\n")
                                bat_file.write(f'wmic.exe /Namespace:\\\\root\\default Path SystemRestore Call CreateRestorePoint "Before install the AHWT {filename} script", 100, 7\n')
                                bat_file.write("echo Adding main parameters...\n")
                            break
                        case 'vista':
                            with open(filename + ".bat", 'a') as bat_file:
                                bat_file.write("echo Creating restore point...\n")
                                bat_file.write(f'wmic.exe /Namespace:\\\\root\\default Path SystemRestore Call CreateRestorePoint "Before install the AHWT {filename} script", 100, 7\n')
                                bat_file.write("echo Adding main parameters...\n")
                            break
                        case 'seven' | 'eight' | 'eightone' | 'ten' | 'eleven':
                            with open(filename + ".bat", 'a') as bat_file:
                                bat_file.write("echo Enabling Restore Point service...\n")
                                bat_file.write("powershell \"Enable-ComputerRestore -Drive 'C:\\'\"\n")
                                bat_file.write("echo Creating restore point...\n")
                                bat_file.write(f'wmic.exe /Namespace:\\\\root\\default Path SystemRestore Call CreateRestorePoint "Before install the AHWT {filename} script", 100, 7\n')
                                bat_file.write("echo Adding main parameters...\n")
                            break
                        case _:
                            print('Invalid input. Input must be "xp", "vista", "seven", "eight", "eightone", "ten" or "eleven" \n')
                break   
            case 'n':
                print("Skipping creating restore point...")
                break
            case _:
                print('Invalid input. Input must be "y" or "n" \n')
                
    while True:
        office_choice = str(input("Enter the version of MS Office you want to harden (2003/2007/2010/2013/2016/365/none): "))
        match office_choice:
            case '2003':
                while True:
                    gen_choice = str(input("Auto or Manual generation of .bat script (a/m): "))
                    match gen_choice:
                        case 'a':
                            hkcu_before_param()
                            with sqlite3.connect(db_file) as sqlite_conn:
                                sql_request = """SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('Office2003', 'OfficeHKLM')"""
                                sql_cursor = sqlite_conn.execute(sql_request)
                                for record in sql_cursor:         
                                    record_value = record
                                    if ('HKEY_CURRENT_USER' in record_value[0]):
                                        if ('OutlookSecureTempFolder' in record_value[1]):
                                            with open(filename + ".bat", 'a') as bat_file:
                                                bat_file.write(f'\techo Deleting "{record_value[0]}" /v "{record_value[1]}" /f\n')
                                                bat_file.write(f'\treg delete "{record_value[0]}" /v "{record_value[1]}" /f\n')
                                        else:
                                            with open(filename + ".bat", 'a') as bat_file:
                                                bat_file.write(f'\techo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                bat_file.write(f'\treg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                            hkcu_after_param()
                            with sqlite3.connect(db_file) as sqlite_conn:
                                sql_request = """SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('Office2003', 'OfficeHKLM')"""
                                sql_cursor = sqlite_conn.execute(sql_request)
                                for record in sql_cursor:         
                                    record_value = record
                                    if ('HKEY_LOCAL_MACHINE' in record_value[0]):
                                        if ('OutlookSecureTempFolder' in record_value[1]):
                                            with open(filename + ".bat", 'a') as bat_file:
                                                bat_file.write(f'\techo Deleting "{record_value[0]}" /v "{record_value[1]}" /f\n')
                                                bat_file.write(f'\treg delete "{record_value[0]}" /v "{record_value[1]}" /f\n')
                                        else:
                                            with open(filename + ".bat", 'a') as bat_file:
                                                bat_file.write(f'\techo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                bat_file.write(f'\treg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                            print(f"Your .bat script saved: {abs_dir}")
                            with open(filename + ".bat", 'a') as bat_file:
                                bat_file.write(f'echo Mission Accomplished! :)\n')
                                bat_file.write(f'pause\n')
                            break
                        case 'm':
                            hkcu_before_param()
                            with sqlite3.connect(db_file) as sqlite_conn:
                                sql_request = """SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('Office2003', 'OfficeHKLM')"""
                                sql_cursor = sqlite_conn.execute(sql_request)
                                if internet() is False or "en" in current_lang_code:
                                    for record in sql_cursor:         
                                        record_value = record
                                        if ('HKEY_LOCAL_MACHINE' not in record_value[0]):
                                            print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f \n {record_value[4]} \n')
                                        if ('HKEY_CURRENT_USER' in record_value[0]):
                                            if ('OutlookSecureTempFolder' in record_value[1]):
                                                delete_reg_hkcu()
                                            else:
                                                answer_function_hkcu()
                                else:
                                    for record in sql_cursor:         
                                        record_value = record
                                        if ('HKEY_LOCAL_MACHINE' not in record_value[0]):
                                            translated = GoogleTranslator(source='auto', target=current_lang_code).translate(record_value[4])
                                            print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f \n {translated} \n')
                                        if ('HKEY_CURRENT_USER' in record_value[0]):
                                            if ('OutlookSecureTempFolder' in record_value[1]):
                                                delete_reg_hkcu()
                                            else:
                                                answer_function_hkcu()
                            hkcu_after_param()
                            with sqlite3.connect(db_file) as sqlite_conn:
                                sql_request = """SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('Office2003', 'OfficeHKLM')"""
                                sql_cursor = sqlite_conn.execute(sql_request)
                                if internet() is False or "en" in current_lang_code:
                                    for record in sql_cursor:         
                                        record_value = record
                                        if ('HKEY_CURRENT_USER' not in record_value[0]):
                                            print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f \n {record_value[4]} \n')
                                        if ('HKEY_LOCAL_MACHINE' in record_value[0]):
                                            if ('OutlookSecureTempFolder' in record_value[1]):
                                                delete_reg()
                                            else:
                                                answer_function()
                                else:
                                    for record in sql_cursor:         
                                        record_value = record
                                        if ('HKEY_CURRENT_USER' not in record_value[0]):
                                            translated = GoogleTranslator(source='auto', target=current_lang_code).translate(record_value[4])
                                            print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f \n {translated} \n')
                                        if ('HKEY_LOCAL_MACHINE' in record_value[0]):
                                            if ('OutlookSecureTempFolder' in record_value[1]):
                                                delete_reg()
                                            else:
                                                answer_function()
                            print(f"Your .bat script saved: {abs_dir}")
                            with open(filename + ".bat", 'a') as bat_file:
                                bat_file.write(f'echo Mission Accomplished! :)\n')
                                bat_file.write(f'pause\n')
                            break
                        case _:
                            print('Invalid input. Input must be "a" or "m" \n')
            case '2007':
                while True:
                    gen_choice = str(input("Auto or Manual generation of .bat script (a/m): "))
                    match gen_choice:
                        case 'a':
                            hkcu_before_param()
                            with sqlite3.connect(db_file) as sqlite_conn:
                                sql_request = """SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('Office2007', 'OfficeHKLM')"""
                                sql_cursor = sqlite_conn.execute(sql_request)
                                for record in sql_cursor:         
                                    record_value = record
                                    if ('HKEY_CURRENT_USER' in record_value[0]):
                                        if ("TrustedAddins" in record_value[0]) or (any(keyword in record_value[1] for keyword in ['OutlookSecureTempFolder', 'FileExtensionsRemoveLevel1', 'FileExtensionsRemoveLevel2'])):
                                            with open(filename + ".bat", 'a') as bat_file:
                                                bat_file.write(f'\techo Deleting "{record_value[0]}" /v "{record_value[1]}" /f\n')
                                                bat_file.write(f'\treg delete "{record_value[0]}" /v "{record_value[1]}" /f\n')
                                        else:
                                            with open(filename + ".bat", 'a') as bat_file:
                                                bat_file.write(f'\techo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                bat_file.write(f'\treg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                            hkcu_after_param()
                            with sqlite3.connect(db_file) as sqlite_conn:
                                sql_request = """SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('Office2007', 'OfficeHKLM')"""
                                sql_cursor = sqlite_conn.execute(sql_request)
                                for record in sql_cursor:         
                                    record_value = record
                                    if ('HKEY_LOCAL_MACHINE' in record_value[0]):
                                        if ("TrustedAddins" in record_value[0]) or (any(keyword in record_value[1] for keyword in ['OutlookSecureTempFolder', 'FileExtensionsRemoveLevel1', 'FileExtensionsRemoveLevel2'])):
                                            with open(filename + ".bat", 'a') as bat_file:
                                                bat_file.write(f'\techo Deleting "{record_value[0]}" /v "{record_value[1]}" /f\n')
                                                bat_file.write(f'\treg delete "{record_value[0]}" /v "{record_value[1]}" /f\n')
                                        else:
                                            with open(filename + ".bat", 'a') as bat_file:
                                                bat_file.write(f'\techo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                bat_file.write(f'\treg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                            print(f"Your .bat script saved: {abs_dir}")
                            with open(filename + ".bat", 'a') as bat_file:
                                bat_file.write(f'echo Mission Accomplished! :)\n')
                                bat_file.write(f'pause\n')
                            break
                        case 'm':
                            hkcu_before_param()
                            with sqlite3.connect(db_file) as sqlite_conn:
                                sql_request = """SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('Office2007', 'OfficeHKLM')"""
                                sql_cursor = sqlite_conn.execute(sql_request)
                                if internet() is False or "en" in current_lang_code:
                                    for record in sql_cursor:         
                                        record_value = record
                                        if ('HKEY_LOCAL_MACHINE' not in record_value[0]):
                                            print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f \n {record_value[4]} \n')
                                        if ('HKEY_CURRENT_USER' in record_value[0]):
                                            if ("TrustedAddins" in record_value[0]) or (any(keyword in record_value[1] for keyword in ['OutlookSecureTempFolder', 'FileExtensionsRemoveLevel1', 'FileExtensionsRemoveLevel2'])):
                                                delete_reg_hkcu()
                                            else:
                                                answer_function_hkcu()
                                else:
                                    for record in sql_cursor:         
                                        record_value = record
                                        if ('HKEY_LOCAL_MACHINE' not in record_value[0]):
                                            translated = GoogleTranslator(source='auto', target=current_lang_code).translate(record_value[4])
                                            print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f \n {translated} \n')
                                        if ('HKEY_CURRENT_USER' in record_value[0]):
                                            if ("TrustedAddins" in record_value[0]) or (any(keyword in record_value[1] for keyword in ['OutlookSecureTempFolder', 'FileExtensionsRemoveLevel1', 'FileExtensionsRemoveLevel2'])):
                                                delete_reg_hkcu()
                                            else:
                                                answer_function_hkcu()
                            hkcu_after_param()
                            with sqlite3.connect(db_file) as sqlite_conn:
                                sql_request = """SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('Office2007', 'OfficeHKLM')"""
                                sql_cursor = sqlite_conn.execute(sql_request)
                                if internet() is False or "en" in current_lang_code:
                                    for record in sql_cursor:         
                                        record_value = record
                                        if ('HKEY_CURRENT_USER' not in record_value[0]):
                                            print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f \n {record_value[4]} \n')
                                        if ('HKEY_LOCAL_MACHINE' in record_value[0]):
                                            if ("TrustedAddins" in record_value[0]) or (any(keyword in record_value[1] for keyword in ['OutlookSecureTempFolder', 'FileExtensionsRemoveLevel1', 'FileExtensionsRemoveLevel2'])):
                                                delete_reg()
                                            else:
                                                answer_function()
                                else:
                                    for record in sql_cursor:         
                                        record_value = record
                                        if ('HKEY_CURRENT_USER' not in record_value[0]):
                                            translated = GoogleTranslator(source='auto', target=current_lang_code).translate(record_value[4])
                                            print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f \n {translated} \n')
                                        if ('HKEY_LOCAL_MACHINE' in record_value[0]):
                                            if ("TrustedAddins" in record_value[0]) or (any(keyword in record_value[1] for keyword in ['OutlookSecureTempFolder', 'FileExtensionsRemoveLevel1', 'FileExtensionsRemoveLevel2'])):
                                                delete_reg()
                                            else:
                                                answer_function()
                            print(f"Your .bat script saved: {abs_dir}")
                            with open(filename + ".bat", 'a') as bat_file:
                                bat_file.write(f'echo Mission Accomplished! :)\n')
                                bat_file.write(f'pause\n')
                            break
                        case _:
                            print('Invalid input. Input must be "a" or "m" \n')
            case '2010':
                while True:
                    gen_choice = str(input("Auto or Manual generation of .bat script (a/m): "))
                    match gen_choice:
                        case 'a':
                            hkcu_before_param()
                            with sqlite3.connect(db_file) as sqlite_conn:
                                sql_request = """SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('Office2010', 'OfficeHKLM')"""
                                sql_cursor = sqlite_conn.execute(sql_request)
                                for record in sql_cursor:         
                                    record_value = record
                                    if ('HKEY_CURRENT_USER' in record_value[0]):
                                        if ("TrustedAddins" in record_value[0]) or (any(keyword in record_value[1] for keyword in ['OutlookSecureTempFolder', 'FileExtensionsRemoveLevel1', 'FileExtensionsRemoveLevel2'])):
                                            with open(filename + ".bat", 'a') as bat_file:
                                                bat_file.write(f'\techo Deleting "{record_value[0]}" /v "{record_value[1]}" /f\n')
                                                bat_file.write(f'\treg delete "{record_value[0]}" /v "{record_value[1]}" /f\n')
                                        else:
                                            with open(filename + ".bat", 'a') as bat_file:
                                                bat_file.write(f'\techo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                bat_file.write(f'\treg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                            hkcu_after_param()
                            with sqlite3.connect(db_file) as sqlite_conn:
                                sql_request = """SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('Office2010', 'OfficeHKLM')"""
                                sql_cursor = sqlite_conn.execute(sql_request)
                                for record in sql_cursor:         
                                    record_value = record
                                    if ('HKEY_LOCAL_MACHINE' in record_value[0]):
                                        if ("TrustedAddins" in record_value[0]) or (any(keyword in record_value[1] for keyword in ['OutlookSecureTempFolder', 'FileExtensionsRemoveLevel1', 'FileExtensionsRemoveLevel2'])):
                                            with open(filename + ".bat", 'a') as bat_file:
                                                bat_file.write(f'\techo Deleting "{record_value[0]}" /v "{record_value[1]}" /f\n')
                                                bat_file.write(f'\treg delete "{record_value[0]}" /v "{record_value[1]}" /f\n')
                                        else:
                                            with open(filename + ".bat", 'a') as bat_file:
                                                bat_file.write(f'\techo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                bat_file.write(f'\treg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                            print(f"Your .bat script saved: {abs_dir}")
                            with open(filename + ".bat", 'a') as bat_file:
                                bat_file.write(f'echo Mission Accomplished! :)\n')
                                bat_file.write(f'pause\n')
                            break
                        case 'm':
                            hkcu_before_param()
                            with sqlite3.connect(db_file) as sqlite_conn:
                                sql_request = """SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('Office2010', 'OfficeHKLM')"""
                                sql_cursor = sqlite_conn.execute(sql_request)
                                if internet() is False or "en" in current_lang_code:
                                    for record in sql_cursor:         
                                        record_value = record
                                        if ('HKEY_LOCAL_MACHINE' not in record_value[0]):
                                            print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f \n {record_value[4]} \n')
                                        if ('HKEY_CURRENT_USER' in record_value[0]):
                                            if ("TrustedAddins" in record_value[0]) or (any(keyword in record_value[1] for keyword in ['OutlookSecureTempFolder', 'FileExtensionsRemoveLevel1', 'FileExtensionsRemoveLevel2'])):
                                                delete_reg_hkcu()
                                            else:
                                                answer_function_hkcu()
                                else:
                                    for record in sql_cursor:         
                                        record_value = record
                                        if ('HKEY_LOCAL_MACHINE' not in record_value[0]):
                                            translated = GoogleTranslator(source='auto', target=current_lang_code).translate(record_value[4])
                                            print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f \n {record_value[4]} \n')
                                        if ('HKEY_CURRENT_USER' in record_value[0]):
                                            if ("TrustedAddins" in record_value[0]) or (any(keyword in record_value[1] for keyword in ['OutlookSecureTempFolder', 'FileExtensionsRemoveLevel1', 'FileExtensionsRemoveLevel2'])):
                                                delete_reg_hkcu()
                                            else:
                                                answer_function_hkcu()
                            hkcu_after_param()
                            with sqlite3.connect(db_file) as sqlite_conn:
                                sql_request = """SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('Office2010', 'OfficeHKLM')"""
                                sql_cursor = sqlite_conn.execute(sql_request)
                                if internet() is False or "en" in current_lang_code:
                                    for record in sql_cursor:         
                                        record_value = record
                                        if ('HKEY_CURRENT_USER' not in record_value[0]):
                                            print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f \n {record_value[4]} \n')
                                        if ('HKEY_LOCAL_MACHINE' in record_value[0]):
                                            if ("TrustedAddins" in record_value[0]) or (any(keyword in record_value[1] for keyword in ['OutlookSecureTempFolder', 'FileExtensionsRemoveLevel1', 'FileExtensionsRemoveLevel2'])):
                                                delete_reg()
                                            else:
                                                answer_function()
                                else:
                                    for record in sql_cursor:         
                                        record_value = record
                                        if ('HKEY_CURRENT_USER' not in record_value[0]):
                                            translated = GoogleTranslator(source='auto', target=current_lang_code).translate(record_value[4])
                                            print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f \n {record_value[4]} \n')
                                        if ('HKEY_LOCAL_MACHINE' in record_value[0]):
                                            if ("TrustedAddins" in record_value[0]) or (any(keyword in record_value[1] for keyword in ['OutlookSecureTempFolder', 'FileExtensionsRemoveLevel1', 'FileExtensionsRemoveLevel2'])):
                                                delete_reg()
                                            else:
                                                answer_function()
                            print(f"Your .bat script saved: {abs_dir}")
                            with open(filename + ".bat", 'a') as bat_file:
                                bat_file.write(f'echo Mission Accomplished! :)\n')
                                bat_file.write(f'pause\n')
                            break
                        case _:
                            print('Invalid input. Input must be "a" or "m" \n')
            case '2013':
                while True:
                    gen_choice = str(input("Auto or Manual generation of .bat script (a/m): "))
                    match gen_choice:
                        case 'a':
                            hkcu_before_param()
                            with sqlite3.connect(db_file) as sqlite_conn:
                                sql_request = """SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('Office2013', 'OfficeHKLM')"""
                                sql_cursor = sqlite_conn.execute(sql_request)
                                for record in sql_cursor:         
                                    record_value = record
                                    if ('HKEY_CURRENT_USER' in record_value[0]):
                                        if ("TrustedAddins" in record_value[0]) or (any(keyword in record_value[1] for keyword in ['OutlookSecureTempFolder', 'FileExtensionsRemoveLevel1', 'FileExtensionsRemoveLevel2', 'allowdde'])):
                                            with open(filename + ".bat", 'a') as bat_file:
                                                bat_file.write(f'\techo Deleting "{record_value[0]}" /v "{record_value[1]}" /f\n')
                                                bat_file.write(f'\treg delete "{record_value[0]}" /v "{record_value[1]}" /f\n')
                                        else:
                                            with open(filename + ".bat", 'a') as bat_file:
                                                bat_file.write(f'\techo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                bat_file.write(f'\treg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                            hkcu_after_param()
                            with sqlite3.connect(db_file) as sqlite_conn:
                                sql_request = """SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('Office2013', 'OfficeHKLM')"""
                                sql_cursor = sqlite_conn.execute(sql_request)
                                for record in sql_cursor:         
                                    record_value = record
                                    if ('HKEY_LOCAL_MACHINE' in record_value[0]):
                                        if ("TrustedAddins" in record_value[0]) or (any(keyword in record_value[1] for keyword in ['OutlookSecureTempFolder', 'FileExtensionsRemoveLevel1', 'FileExtensionsRemoveLevel2', 'allowdde'])):
                                            with open(filename + ".bat", 'a') as bat_file:
                                                bat_file.write(f'\techo Deleting "{record_value[0]}" /v "{record_value[1]}" /f\n')
                                                bat_file.write(f'\treg delete "{record_value[0]}" /v "{record_value[1]}" /f\n')
                                        else:
                                            with open(filename + ".bat", 'a') as bat_file:
                                                bat_file.write(f'\techo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                bat_file.write(f'\treg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                            print(f"Your .bat script saved: {abs_dir}")
                            with open(filename + ".bat", 'a') as bat_file:
                                bat_file.write(f'echo Mission Accomplished! :)\n')
                                bat_file.write(f'pause\n')
                            break
                        case 'm':
                            hkcu_before_param()
                            with sqlite3.connect(db_file) as sqlite_conn:
                                sql_request = """SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('Office2013', 'OfficeHKLM')"""
                                sql_cursor = sqlite_conn.execute(sql_request)
                                if internet() is False or "en" in current_lang_code:
                                    for record in sql_cursor:         
                                        record_value = record
                                        if ('HKEY_LOCAL_MACHINE' not in record_value[0]):
                                            print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f \n {record_value[4]} \n')
                                        if ('HKEY_CURRENT_USER' in record_value[0]):
                                            if ("TrustedAddins" in record_value[0]) or (any(keyword in record_value[1] for keyword in ['OutlookSecureTempFolder', 'FileExtensionsRemoveLevel1', 'FileExtensionsRemoveLevel2', 'allowdde'])):
                                                delete_reg_hkcu()
                                            else:
                                                answer_function_hkcu()
                                else:
                                    for record in sql_cursor:         
                                        record_value = record
                                        if ('HKEY_LOCAL_MACHINE' not in record_value[0]):
                                            translated = GoogleTranslator(source='auto', target=current_lang_code).translate(record_value[4])
                                            print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f \n {translated} \n')
                                        if ('HKEY_CURRENT_USER' in record_value[0]):
                                            if ("TrustedAddins" in record_value[0]) or (any(keyword in record_value[1] for keyword in ['OutlookSecureTempFolder', 'FileExtensionsRemoveLevel1', 'FileExtensionsRemoveLevel2', 'allowdde'])):
                                                delete_reg_hkcu()
                                            else:
                                                answer_function_hkcu()
                            hkcu_after_param()
                            with sqlite3.connect(db_file) as sqlite_conn:
                                sql_request = """SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('Office2013', 'OfficeHKLM')"""
                                sql_cursor = sqlite_conn.execute(sql_request)
                                if internet() is False or "en" in current_lang_code:
                                    for record in sql_cursor:         
                                        record_value = record
                                        if ('HKEY_CURRENT_USER' not in record_value[0]):
                                            print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f \n {record_value[4]} \n')
                                        if ('HKEY_LOCAL_MACHINE' in record_value[0]):
                                            if ("TrustedAddins" in record_value[0]) or (any(keyword in record_value[1] for keyword in ['OutlookSecureTempFolder', 'FileExtensionsRemoveLevel1', 'FileExtensionsRemoveLevel2', 'allowdde'])):
                                                delete_reg()
                                            else:
                                                answer_function()
                                else:
                                    for record in sql_cursor:         
                                        record_value = record
                                        if ('HKEY_CURRENT_USER' not in record_value[0]):
                                            translated = GoogleTranslator(source='auto', target=current_lang_code).translate(record_value[4])
                                            print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f \n {record_value[4]} \n')
                                        if ('HKEY_LOCAL_MACHINE' in record_value[0]):
                                            if ("TrustedAddins" in record_value[0]) or (any(keyword in record_value[1] for keyword in ['OutlookSecureTempFolder', 'FileExtensionsRemoveLevel1', 'FileExtensionsRemoveLevel2', 'allowdde'])):
                                                delete_reg()
                                            else:
                                                answer_function()
                            print(f"Your .bat script saved: {abs_dir}")
                            with open(filename + ".bat", 'a') as bat_file:
                                bat_file.write(f'echo Mission Accomplished! :)\n')
                                bat_file.write(f'pause\n')
                            break
                        case _:
                            print('Invalid input. Input must be "a" or "m" \n')
            case '2016':
                while True:
                    gen_choice = str(input("Auto or Manual generation of .bat script (a/m): "))
                    match gen_choice:
                        case 'a':
                            hkcu_before_param()
                            with sqlite3.connect(db_file) as sqlite_conn:
                                sql_request = """SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('Office2016', 'OfficeHKLM')"""
                                sql_cursor = sqlite_conn.execute(sql_request)
                                for record in sql_cursor:         
                                    record_value = record
                                    if ('HKEY_CURRENT_USER' in record_value[0]):
                                        if ("TrustedAddins" in record_value[0]) or (any(keyword in record_value[1] for keyword in ['OutlookSecureTempFolder', 'FileExtensionsRemoveLevel1', 'FileExtensionsRemoveLevel2', 'allowdde'])):
                                            with open(filename + ".bat", 'a') as bat_file:
                                                bat_file.write(f'\techo Deleting "{record_value[0]}" /v "{record_value[1]}" /f\n')
                                                bat_file.write(f'\treg delete "{record_value[0]}" /v "{record_value[1]}" /f\n')
                                        else:
                                            with open(filename + ".bat", 'a') as bat_file:
                                                bat_file.write(f'\techo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                bat_file.write(f'\treg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                            hkcu_after_param()
                            with sqlite3.connect(db_file) as sqlite_conn:
                                sql_request = """SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('Office2016', 'OfficeHKLM')"""
                                sql_cursor = sqlite_conn.execute(sql_request)
                                for record in sql_cursor:         
                                    record_value = record
                                    if ('HKEY_LOCAL_MACHINE' in record_value[0]):
                                        if ("TrustedAddins" in record_value[0]) or (any(keyword in record_value[1] for keyword in ['OutlookSecureTempFolder', 'FileExtensionsRemoveLevel1', 'FileExtensionsRemoveLevel2', 'allowdde'])):
                                            with open(filename + ".bat", 'a') as bat_file:
                                                bat_file.write(f'\techo Deleting "{record_value[0]}" /v "{record_value[1]}" /f\n')
                                                bat_file.write(f'\treg delete "{record_value[0]}" /v "{record_value[1]}" /f\n')
                                        else:
                                            with open(filename + ".bat", 'a') as bat_file:
                                                bat_file.write(f'\techo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                bat_file.write(f'\treg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                            print(f"Your .bat script saved: {abs_dir}")
                            with open(filename + ".bat", 'a') as bat_file:
                                bat_file.write(f'echo Mission Accomplished! :)\n')
                                bat_file.write(f'pause\n')
                            break
                        case 'm':
                            hkcu_before_param()
                            with sqlite3.connect(db_file) as sqlite_conn:
                                sql_request = """SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('Office2016', 'OfficeHKLM')"""
                                sql_cursor = sqlite_conn.execute(sql_request)
                                if internet() is False or "en" in current_lang_code:
                                    for record in sql_cursor:         
                                        record_value = record
                                        if ('HKEY_LOCAL_MACHINE' not in record_value[0]):
                                            print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f \n {record_value[4]} \n')
                                        if ('HKEY_CURRENT_USER' in record_value[0]):
                                            if ("TrustedAddins" in record_value[0]) or (any(keyword in record_value[1] for keyword in ['OutlookSecureTempFolder', 'FileExtensionsRemoveLevel1', 'FileExtensionsRemoveLevel2', 'allowdde'])):
                                                delete_reg_hkcu()
                                            else:
                                                answer_function_hkcu()
                                else:
                                    for record in sql_cursor:         
                                        record_value = record                                        
                                        if ('HKEY_LOCAL_MACHINE' not in record_value[0]):
                                            translated = GoogleTranslator(source='auto', target=current_lang_code).translate(record_value[4])
                                            print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f \n {record_value[4]} \n')
                                        if ('HKEY_CURRENT_USER' in record_value[0]):
                                            if ("TrustedAddins" in record_value[0]) or (any(keyword in record_value[1] for keyword in ['OutlookSecureTempFolder', 'FileExtensionsRemoveLevel1', 'FileExtensionsRemoveLevel2', 'allowdde'])):
                                                delete_reg_hkcu()
                                            else:
                                                answer_function_hkcu()
                            hkcu_after_param()
                            with sqlite3.connect(db_file) as sqlite_conn:
                                sql_request = """SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('Office2016', 'OfficeHKLM')"""
                                sql_cursor = sqlite_conn.execute(sql_request)
                                if internet() is False or "en" in current_lang_code:
                                    for record in sql_cursor:         
                                        record_value = record
                                        if ('HKEY_CURRENT_USER' not in record_value[0]):
                                            print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f \n {record_value[4]} \n')
                                        if ('HKEY_LOCAL_MACHINE' in record_value[0]):
                                            if ("TrustedAddins" in record_value[0]) or (any(keyword in record_value[1] for keyword in ['OutlookSecureTempFolder', 'FileExtensionsRemoveLevel1', 'FileExtensionsRemoveLevel2', 'allowdde'])):
                                                delete_reg()
                                            else:
                                                answer_function()
                                else:
                                    for record in sql_cursor:         
                                        record_value = record                                        
                                        if ('HKEY_CURRENT_USER' not in record_value[0]):
                                            translated = GoogleTranslator(source='auto', target=current_lang_code).translate(record_value[4])
                                            print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f \n {record_value[4]} \n')
                                        if ('HKEY_LOCAL_MACHINE' in record_value[0]):
                                            if ("TrustedAddins" in record_value[0]) or (any(keyword in record_value[1] for keyword in ['OutlookSecureTempFolder', 'FileExtensionsRemoveLevel1', 'FileExtensionsRemoveLevel2', 'allowdde'])):
                                                delete_reg()
                                            else:
                                                answer_function()
                            print(f"Your .bat script saved: {abs_dir}")
                            with open(filename + ".bat", 'a') as bat_file:
                                bat_file.write(f'echo Mission Accomplished! :)\n')
                                bat_file.write(f'pause\n')
                            break
                        case _:
                            print('Invalid input. Input must be "a" or "m" \n')
            case '365':
                while True:
                    gen_choice = str(input("Auto or Manual generation of .bat script (a/m): "))
                    match gen_choice:
                        case 'a':
                            hkcu_before_param()
                            with sqlite3.connect(db_file) as sqlite_conn:
                                sql_request = """SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('Office2016', 'Office365', 'OfficeHKLM')"""
                                sql_cursor = sqlite_conn.execute(sql_request)
                                for record in sql_cursor:         
                                    record_value = record
                                    if ('HKEY_CURRENT_USER' in record_value[0]):
                                        if ("TrustedAddins" in record_value[0]) or (any(keyword in record_value[1] for keyword in ['OutlookSecureTempFolder', 'FileExtensionsRemoveLevel1', 'FileExtensionsRemoveLevel2', 'allowdde'])):
                                            with open(filename + ".bat", 'a') as bat_file:
                                                bat_file.write(f'\techo Deleting "{record_value[0]}" /v "{record_value[1]}" /f\n')
                                                bat_file.write(f'\treg delete "{record_value[0]}" /v "{record_value[1]}" /f\n')
                                        else:
                                            with open(filename + ".bat", 'a') as bat_file:
                                                bat_file.write(f'\techo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                bat_file.write(f'\treg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                            hkcu_after_param()
                            with sqlite3.connect(db_file) as sqlite_conn:
                                sql_request = """SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('Office2016', 'Office365', 'OfficeHKLM')"""
                                sql_cursor = sqlite_conn.execute(sql_request)
                                for record in sql_cursor:         
                                    record_value = record
                                    if ('HKEY_LOCAL_MACHINE' in record_value[0]):
                                        if ("TrustedAddins" in record_value[0]) or (any(keyword in record_value[1] for keyword in ['OutlookSecureTempFolder', 'FileExtensionsRemoveLevel1', 'FileExtensionsRemoveLevel2', 'allowdde'])):
                                            with open(filename + ".bat", 'a') as bat_file:
                                                bat_file.write(f'\techo Deleting "{record_value[0]}" /v "{record_value[1]}" /f\n')
                                                bat_file.write(f'\treg delete "{record_value[0]}" /v "{record_value[1]}" /f\n')
                                        else:
                                            with open(filename + ".bat", 'a') as bat_file:
                                                bat_file.write(f'\techo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                                                bat_file.write(f'\treg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
                            print(f"Your .bat script saved: {abs_dir}")
                            with open(filename + ".bat", 'a') as bat_file:
                                bat_file.write(f'echo Mission Accomplished! :)\n')
                                bat_file.write(f'pause\n')
                            break
                        case 'm':
                            hkcu_before_param()
                            with sqlite3.connect(db_file) as sqlite_conn:
                                sql_request = """SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('Office2016', 'Office365', 'OfficeHKLM')"""
                                sql_cursor = sqlite_conn.execute(sql_request)
                                if internet() is False or "en" in current_lang_code:
                                    for record in sql_cursor:         
                                        record_value = record
                                        if ('HKEY_LOCAL_MACHINE' not in record_value[0]):
                                            print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f \n {record_value[4]} \n')
                                        if ('HKEY_CURRENT_USER' in record_value[0]):
                                            if ("TrustedAddins" in record_value[0]) or (any(keyword in record_value[1] for keyword in ['OutlookSecureTempFolder', 'FileExtensionsRemoveLevel1', 'FileExtensionsRemoveLevel2', 'allowdde'])):
                                                delete_reg_hkcu()
                                            else:
                                                answer_function_hkcu()
                                else:
                                    for record in sql_cursor:         
                                        record_value = record                                        
                                        if ('HKEY_LOCAL_MACHINE' not in record_value[0]):
                                            translated = GoogleTranslator(source='auto', target=current_lang_code).translate(record_value[4])
                                            print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f \n {record_value[4]} \n')
                                        if ('HKEY_CURRENT_USER' in record_value[0]):
                                            if ("TrustedAddins" in record_value[0]) or (any(keyword in record_value[1] for keyword in ['OutlookSecureTempFolder', 'FileExtensionsRemoveLevel1', 'FileExtensionsRemoveLevel2', 'allowdde'])):
                                                delete_reg_hkcu()
                                            else:
                                                answer_function_hkcu()
                            hkcu_after_param()
                            with sqlite3.connect(db_file) as sqlite_conn:
                                sql_request = """SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('Office2016', 'Office365', 'OfficeHKLM')"""
                                sql_cursor = sqlite_conn.execute(sql_request)
                                if internet() is False or "en" in current_lang_code:
                                    for record in sql_cursor:         
                                        record_value = record
                                        if ('HKEY_CURRENT_USER' not in record_value[0]):
                                            print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f \n {record_value[4]} \n')
                                        if ('HKEY_LOCAL_MACHINE' in record_value[0]):
                                            if ("TrustedAddins" in record_value[0]) or (any(keyword in record_value[1] for keyword in ['OutlookSecureTempFolder', 'FileExtensionsRemoveLevel1', 'FileExtensionsRemoveLevel2', 'allowdde'])):
                                                delete_reg()
                                            else:
                                                answer_function()
                                else:
                                    for record in sql_cursor:         
                                        record_value = record                                        
                                        if ('HKEY_CURRENT_USER' not in record_value[0]):
                                            translated = GoogleTranslator(source='auto', target=current_lang_code).translate(record_value[4])
                                            print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f \n {record_value[4]} \n')
                                        if ('HKEY_LOCAL_MACHINE' in record_value[0]):
                                            if ("TrustedAddins" in record_value[0]) or (any(keyword in record_value[1] for keyword in ['OutlookSecureTempFolder', 'FileExtensionsRemoveLevel1', 'FileExtensionsRemoveLevel2', 'allowdde'])):
                                                delete_reg()
                                            else:
                                                answer_function()
                            print(f"Your .bat script saved: {abs_dir}")
                            with open(filename + ".bat", 'a') as bat_file:
                                bat_file.write(f'echo Mission Accomplished! :)\n')
                                bat_file.write(f'pause\n')
                            break
                        case _:
                            print('Invalid input. Input must be "a" or "m" \n')
            case 'none':
                print("Returning...")
                break
            case _:
                print('Invalid input. Input must be "2003", "2007", "2010", "2013", "2016", "365" or "none" \n')
        break
                
                
            
def internet(host="8.8.8.8", port=53, timeout=5):
    """
    Checking host: 8.8.8.8 (google-public-dns-a.google.com)
    """
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    try:
        sock.settimeout(timeout)
        sock.connect((host, port))
        return True
    except socket.error as ex:
        print("No internet connection. All descriptions will be on English.\n")
        return False
    finally:
        sock.close()
        
    

current_locale = locale.getdefaultlocale()
current_lang_code = current_locale[0].split("_")[0]