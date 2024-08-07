import sqlite3
from pathlib import Path
import locale
from deep_translator import GoogleTranslator
import socket
import os
import re
import ipaddress

from pathlib import Path

def start_module(db_name, handle_input_function):
    global DB_NAME
    DB_NAME = db_name
    setup_db_gen(DB_NAME)
    handle_filename_input(handle_input_function)


def setup_db_gen(db_name):
    global abs_dir, db_dir, db_file, osname
    abs_dir = os.path.dirname(os.path.abspath(__file__))
    db_dir = Path('dbs')
    db_file = Path(abs_dir / db_dir / db_name)
    osname = db_name.split("_")[0]


def handle_filename_input(gen_function):
    global filename
    while True:
        filename = str(input("Enter the name for batch file: "))
        if os.path.exists(filename + ".bat"):
            print("File exists. Enter another name...")
        else:
            gen_function()
            break


def process_hkcu_batch(start=True):
        batch_cycle = """
        setlocal enabledelayedexpansion

        for /f "tokens=*" %%a in ('reg query HKU ^| findstr /r /c:"HKEY_USERS\\\\S-1-5-21-[0-9]*-[0-9]*-[0-9]*-[0-9]*"') do (
            set "user=%%a"
            set "user=!user:HKEY_USERS=HKU!"
            echo Found User: !user!
            
            """ if start else """
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
        

def replace_hkcu():
    with open(filename + ".bat", 'r') as bat_file:
        replace_users_key = bat_file.read()
    updated_users_key = replace_users_key.replace('HKEY_CURRENT_USER', '!user!')
    with open(filename + ".bat", 'w') as bat_file:
        bat_file.write(updated_users_key)


def finalize_bat_file():
        with open(filename + ".bat", 'a') as bat_file:
            bat_file.write(f'echo Mission Accomplished! :)\n')
            bat_file.write(f'pause\n')
            

def write_restore_point(bat_file, db_file, filename):
        db_file_str = str(db_file)
        if any(keyword in db_file_str for keyword in ['seven', 'eightzero', 'eightone', 'ten', 'eleven']):
            bat_file.write("echo Enabling Restore Point service...\n")
            bat_file.write("powershell \"Enable-ComputerRestore -Drive 'C:\\'\"\n")
            bat_file.write("echo Creating restore point...\n")
        elif 'vista' in db_file_str:
            bat_file.write("echo Creating restore point...\n")
        else:
            bat_file.write("echo Enabling Restore Point service...\n")
            bat_file.write("sc config srservice start= auto\n")
            bat_file.write("net start srservice\n")
            bat_file.write("echo Creating restore point...\n")
        bat_file.write(f'wmic.exe /Namespace:\\\\root\\default Path SystemRestore Call CreateRestorePoint "Before install the AHWT {filename} script", 100, 7\n')


def gen_decision():
    def write_audit_policies(bat_file, db_file):
        db_file_str = str(db_file)
        if any(keyword in db_file_str for keyword in ['seven', 'eightzero', 'eightone', 'ten', 'eleven']):
            bat_file.write("echo Applying audit policies...\n")
            bat_file.write(f'auditpol /clear /y\n')
            for keyword, template in [('seven', 'Templates\\Seven\\auditpol_seven'),
                                      ('eightzero', 'Templates\\EightZero\\auditpol_eightzero'),
                                      ('eightone', 'Templates\\EightOne\\auditpol_eightone'),
                                      ('ten', 'Templates\\Ten\\auditpol_ten'),
                                      ('eleven', 'Templates\\Eleven\\auditpol_eleven')]:
                if keyword in db_file_str:
                    with open(template, 'r') as audit_file:
                        bat_file.writelines(audit_file.readlines())
                        bat_file.write(f'\n')
            bat_file.write(f'gpupdate /force\n')
            bat_file.write("auditpol /get /category:*\n")
            bat_file.write(f'pause\n')

    def write_optional_services(bat_file):
        bat_file.write("echo Disabling optional services...\n")
        for feature in ["MicrosoftWindowsPowerShellV2Root", "MicrosoftWindowsPowerShellV2", "SMB1Protocol"]:
            bat_file.write(f'powershell "Disable-WindowsOptionalFeature -Online -FeatureName {feature} -norestart"\n')
            
    def write_netconns(bat_file):
        bat_file.write("echo Blocking Win32 binaries from making network connections when they shouldn't...\n")
        if "xp" in str(db_file):
            bat_file.write(f'netsh firewall add allowedprogram program="%systemroot%\system32\\notepad.exe" name="Block Notepad.exe netconns" mode=disable profile=ALL\n')
            bat_file.write(f'netsh firewall add allowedprogram program="%systemroot%\system32\\regsvr32.exe" name="Block regsvr32.exe netconns" mode=disable profile=ALL\n')
            bat_file.write(f'netsh firewall add allowedprogram program="%systemroot%\system32\calc.exe" name="Block calc.exe netconns" mode=disable profile=ALL\n')
            bat_file.write(f'netsh firewall add allowedprogram program="%systemroot%\system32\mshta.exe" name="Block mshta.exe netconns" mode=disable profile=ALL\n')
            bat_file.write(f'netsh firewall add allowedprogram program="%systemroot%\system32\wscript.exe" name="Block wscript.exe netconns" mode=disable profile=ALL\n')
            bat_file.write(f'netsh firewall add allowedprogram program="%systemroot%\system32\cscript.exe" name="Block cscript.exe netconns" mode=disable profile=ALL\n')
            bat_file.write(f'netsh firewall add allowedprogram program="%systemroot%\system32\hh.exe" name="Block hh.exe netconns" mode=disable profile=ALL\n')
        elif "vista" in str(db_file):
            bat_file.write(f'netsh advfirewall firewall add rule name="Block regsvr32.exe netconns" program="%systemroot%\system32\\regsvr32.exe" protocol=tcp dir=out enable=yes action=block profile=any\n')
            bat_file.write(f'netsh advfirewall firewall add rule name="Block Notepad.exe netconns" program="%systemroot%\system32\\notepad.exe" protocol=tcp dir=out enable=yes action=block profile=any\n')
            bat_file.write(f'netsh advfirewall firewall add rule name="Block calc.exe netconns" program="%systemroot%\system32\calc.exe" protocol=tcp dir=out enable=yes action=block profile=any\n')
            bat_file.write(f'netsh advfirewall firewall add rule name="Block mshta.exe netconns" program="%systemroot%\system32\mshta.exe" protocol=tcp dir=out enable=yes action=block profile=any\n')
            bat_file.write(f'netsh advfirewall firewall add rule name="Block wscript.exe netconns" program="%systemroot%\system32\wscript.exe" protocol=tcp dir=out enable=yes action=block profile=any\n')
            bat_file.write(f'netsh advfirewall firewall add rule name="Block cscript.exe netconns" program="%systemroot%\system32\cscript.exe" protocol=tcp dir=out enable=yes action=block profile=any\n')
            bat_file.write(f'netsh advfirewall firewall add rule name="Block hh.exe netconns" program="%systemroot%\system32\hh.exe" protocol=tcp dir=out enable=yes action=block profile=any\n')
        elif any(keyword in str(db_file) for keyword in ['seven', 'eightzero', 'eightone']):
            bat_file.write(f'netsh advfirewall firewall add rule name="Block regsvr32.exe netconns" program="%systemroot%\system32\\regsvr32.exe" protocol=tcp dir=out enable=yes action=block profile=any\n')
            bat_file.write(f'netsh advfirewall firewall add rule name="Block Notepad.exe netconns" program="%systemroot%\system32\\notepad.exe" protocol=tcp dir=out enable=yes action=block profile=any\n')
            bat_file.write(f'netsh advfirewall firewall add rule name="Block calc.exe netconns" program="%systemroot%\system32\calc.exe" protocol=tcp dir=out enable=yes action=block profile=any\n')
            bat_file.write(f'netsh advfirewall firewall add rule name="Block mshta.exe netconns" program="%systemroot%\system32\mshta.exe" protocol=tcp dir=out enable=yes action=block profile=any\n')
            bat_file.write(f'netsh advfirewall firewall add rule name="Block wscript.exe netconns" program="%systemroot%\system32\wscript.exe" protocol=tcp dir=out enable=yes action=block profile=any\n')
            bat_file.write(f'netsh advfirewall firewall add rule name="Block cscript.exe netconns" program="%systemroot%\system32\cscript.exe" protocol=tcp dir=out enable=yes action=block profile=any\n')
            bat_file.write(f'netsh advfirewall firewall add rule name="Block hh.exe netconns" program="%systemroot%\system32\hh.exe" protocol=tcp dir=out enable=yes action=block profile=any\n')
            bat_file.write(f'netsh advfirewall firewall add rule name="Block conhost.exe netconns" program="%systemroot%\system32\conhost.exe" protocol=tcp dir=out enable=yes action=block profile=any\n')
        else:
            bat_file.write(f'netsh advfirewall firewall add rule name="Block regsvr32.exe netconns" program="%systemroot%\system32\\regsvr32.exe" protocol=tcp dir=out enable=yes action=block profile=any\n')
            bat_file.write(f'netsh advfirewall firewall add rule name="Block Notepad.exe netconns" program="%systemroot%\system32\\notepad.exe" protocol=tcp dir=out enable=yes action=block profile=any\n')
            bat_file.write(f'netsh advfirewall firewall add rule name="Block calc.exe netconns" program="%systemroot%\system32\calc.exe" protocol=tcp dir=out enable=yes action=block profile=any\n')
            bat_file.write(f'netsh advfirewall firewall add rule name="Block mshta.exe netconns" program="%systemroot%\system32\mshta.exe" protocol=tcp dir=out enable=yes action=block profile=any\n')
            bat_file.write(f'netsh advfirewall firewall add rule name="Block wscript.exe netconns" program="%systemroot%\system32\wscript.exe" protocol=tcp dir=out enable=yes action=block profile=any\n')
            bat_file.write(f'netsh advfirewall firewall add rule name="Block cscript.exe netconns" program="%systemroot%\system32\cscript.exe" protocol=tcp dir=out enable=yes action=block profile=any\n')
            bat_file.write(f'netsh advfirewall firewall add rule name="Block hh.exe netconns" program="%systemroot%\system32\hh.exe" protocol=tcp dir=out enable=yes action=block profile=any\n')
            bat_file.write(f'netsh advfirewall firewall add rule name="Block conhost.exe netconns" program="%systemroot%\system32\conhost.exe" protocol=tcp dir=out enable=yes action=block profile=any\n')
            bat_file.write(f'netsh advfirewall firewall add rule name="Block runscripthelper.exe netconns" program="%systemroot%\system32\\runscripthelper.exe" protocol=tcp dir=out enable=yes action=block profile=any\n')
            

    def write_common_content(bat_file, db_file, filename, osname):
        db_file_str = str(db_file)
        bat_file.write("@echo off\n\n")
        bat_file.write("\necho Adding commands...\n")
        write_restore_point(bat_file, db_file_str, filename)
        bat_file.write("echo Applying secedit configuration...\n")
        bat_file.write(f'secedit /configure /db "secedit_db_{osname}.sdb" /areas securitypolicy group_mgmt user_rights filestore /cfg hisecdc_{osname}.inf\n')
        bat_file.write("bcdedit /set {current} nx OptOut\n")
        if any(keyword in db_file_str for keyword in ['seven', 'eightzero', 'eightone']):
            bat_file.write("echo Installing EMET...\n")
            bat_file.write(f'msiexec /i "EMET Setup.msi" /qn /norestart\n')
        write_audit_policies(bat_file, db_file_str)
        if any(keyword in db_file_str for keyword in ['seven', 'eightzero', 'eightone', 'ten', 'eleven']):
            write_optional_services(bat_file)
        write_netconns(bat_file)
        bat_file.write(f'\necho Adding register values...\n')

    while True:
        gen_question = input("Auto or Manual generation of .bat script or script for additional software (a/m/add)?: ")
        if gen_question in ['a', 'm']:
            with open(f"{filename}.bat", 'w') as bat_file:
                write_common_content(bat_file, db_file, filename, osname)
            if gen_question == 'a':
                auto_generation()
            else:
                manual_generation()
            print(f"Your .bat script saved: {abs_dir}")
            finalize_bat_file()
            break
        elif gen_question == 'add':
            with open(f"{filename}.bat", 'w') as bat_file:
                bat_file.write("@echo off\n\n")
                bat_file.write("echo Creating restore point...\n")
                write_restore_point(bat_file, db_file, filename)
            addon_gen()
            break
        else:
            print('Invalid input. Input must be "a" for auto generating, "m" for manual generating or "add" for generating for additional software\n')


def registry_operations(profile, filename, db_file, current_lang_code):
    def prompt_user(prompt, valid_responses):
        while True:
            user_input = input(prompt).strip().lower()
            if user_input in valid_responses:
                return user_input
            print(f'Invalid input. Input must be one of {valid_responses}\n')

    def write_to_bat_file(bat_file, reg_key, reg_value, value_type, parameter):
        bat_file.write(f'echo Applying "{reg_key}" /v "{reg_value}" /t {value_type} /d "{parameter}" /f\n')
        bat_file.write(f'reg add "{reg_key}" /v "{reg_value}" /t {value_type} /d "{parameter}" /f\n')
        bat_file.flush()

    def process_registry(profile):
        with sqlite3.connect(db_file) as sqlite_conn:
            sql_request = f"SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('{profile}')"
            sql_cursor = sqlite_conn.execute(sql_request)
            records = sql_cursor.fetchall()
        
        if not records:
            return

        add_values = prompt_user(f"Do you want to add {profile} registry values? (y/n): ", ['y', 'n'])
        if add_values == 'n':
            print(f"Skipping {profile} register values... \n")
            return

        with open(filename + ".bat", 'a') as bat_file:
            bat_file.write(f'\necho Adding {profile} values... \n')
            bat_file.flush()
        
            show_params = prompt_user("Show the parameters (y/n)?: ", ['y', 'n'])
            
            if show_params == 'y':
                translate = "en" not in current_lang_code
                for record in records:
                    reg_key, reg_value, value_type, parameter, description = record
                    if translate:
                        description = GoogleTranslator(source='auto', target=current_lang_code).translate(description)
                    print(f'"{reg_key}" /v "{reg_value}" /t {value_type} /d "{parameter}" /f \n {description} \n')
                    apply_value = prompt_user("Apply (y/n)?: ", ['y', 'n'])
                    if apply_value == 'n':
                        print("Skipping this register value...\n")
                        continue
                    write_to_bat_file(bat_file, reg_key, reg_value, value_type, parameter)
            else:
                for record in records:
                    reg_key, reg_value, value_type, parameter, _ = record
                    write_to_bat_file(bat_file, reg_key, reg_value, value_type, parameter)

    process_registry(profile)


def bitlocker_reg():
    registry_operations('BitLocker', filename, db_file, current_lang_code)


def defender_reg():
    registry_operations('Defender', filename, db_file, current_lang_code)


def edge_reg():
    registry_operations('Edge', filename, db_file, current_lang_code)


def firewall_reg():
    if any(keyword in str(db_file) for keyword in ['xp', 'vista', 'seven', 'eightzero', 'eightone', 'ten', 'eleven']):
        def prompt_user(prompt, valid_responses):
            while True:
                user_input = input(prompt).strip().lower()
                if user_input in valid_responses:
                    return user_input
                print(f'Invalid input. Input must be one of {valid_responses}\n')

        def write_to_bat_file(bat_file, reg_key, reg_value, value_type, parameter):
            bat_file.write(f'echo Applying "{reg_key}" /v "{reg_value}" /t {value_type} /d "{parameter}" /f\n')
            bat_file.write(f'reg add "{reg_key}" /v "{reg_value}" /t {value_type} /d "{parameter}" /f\n')
            bat_file.flush()

        def process_firewall():
            add_values = prompt_user("Do you want to add Microsoft Firewall registry values? (y/n): ", ['y', 'n'])
            if add_values == 'n':
                print("Skipping Microsoft Firewall register values... \n")
                return

            with open(filename + ".bat", 'a') as bat_file:
                bat_file.write(f'\necho Adding Microsoft Firewall values... \n')
                bat_file.flush()

                shieldup_input = prompt_user("Apply ShieldUp Mode (Block all incoming connections, including those in the list of allowed apps) (y/n)?: ", ['y', 'n'])

                show_params = prompt_user("Show the parameters (y/n)?: ", ['y', 'n'])

                with sqlite3.connect(db_file) as sqlite_conn:
                    if any(keyword in str(db_file) for keyword in ['xp', 'vista']):
                        sql_request = """SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('Firewall')"""
                    else:
                        sql_request = ("""
                            SELECT reg_key, reg_value, value_type, parameter, description 
                            FROM Main 
                            WHERE profile IN ('Firewall') 
                            AND reg_key NOT IN (
                                'HKEY_LOCAL_MACHINE\\System\\CurrentControlSet\\Services\\SharedAccess\\Parameters\\FirewallPolicy\\StandardProfile',
                                'HKEY_LOCAL_MACHINE\\System\\CurrentControlSet\\Services\\SharedAccess\\Parameters\\FirewallPolicy\\StandardProfile\\Logging',
                                'HKEY_LOCAL_MACHINE\\Software\\Policies\\Microsoft\\WindowsFirewall\\StandardProfile',
                                'HKEY_LOCAL_MACHINE\\Software\\Policies\\Microsoft\\WindowsFirewall\\StandardProfile\\Logging'
                            )
                        """)
                    sql_cursor = sqlite_conn.execute(sql_request)
                    records = sql_cursor.fetchall()
                
                if not records:
                    return

                if show_params == 'y':
                    translate = "en" not in current_lang_code
                    for record in records:
                        reg_key, reg_value, value_type, parameter, description = record
                        if "DoNotAllowExceptions" in reg_value and shieldup_input == 'n':
                            continue
                        if translate:
                            description = GoogleTranslator(source='auto', target=current_lang_code).translate(description)
                        print(f'"{reg_key}" /v "{reg_value}" /t {value_type} /d "{parameter}" /f \n {description} \n')
                        apply_value = prompt_user("Apply (y/n)?: ", ['y', 'n'])
                        if apply_value == 'n':
                            print("Skipping this register value...\n")
                            continue
                        write_to_bat_file(bat_file, reg_key, reg_value, value_type, parameter)
                else:
                    for record in records:
                        reg_key, reg_value, value_type, parameter, _ = record
                        if "DoNotAllowExceptions" in reg_value and shieldup_input == 'n':
                            continue
                        write_to_bat_file(bat_file, reg_key, reg_value, value_type, parameter)
        
        ### Adding new FW rules ###
                        
        def write_rule(rule_name, rule):
            with open(filename + ".bat", 'a') as bat_file:
                bat_file.write(f"echo Applying rule '{rule_name}'...\n")
                bat_file.write(f"{rule}\n")
                

        def validate_program_path(program_path):
            local_path_regex = r'^[a-zA-Z]:\\(?:[^\\\/:*?"<>|\r\n]+\\)*[^\\\/:*?"<>|\r\n]+\.(exe|bat|ps1)$'
            network_path_regex = r'^\\\\[^\\\/:*?"<>|\r\n]+\\(?:[^\\\/:*?"<>|\r\n]+\\)*[^\\\/:*?"<>|\r\n]+\.(exe|bat|ps1)$'
            return re.match(local_path_regex, program_path) or re.match(network_path_regex, program_path)

        def validate_ips(ip_str, allow_localsubnet=True):
            ip_str = ip_str.replace(' ', '')  # Remove any spaces
            ips = ip_str.split(',')
            for ip in ips:
                if allow_localsubnet and ip.lower() == "localsubnet":
                    continue
                try:
                    if '-' in ip:
                        start_ip, end_ip = ip.split('-')
                        ipaddress.ip_address(start_ip.strip())
                        ipaddress.ip_address(end_ip.strip())
                    else:
                        ipaddress.ip_network(ip.strip(), strict=False)
                except ValueError:
                    return False
            return True
        
        def validate_ip_xp(ip):
            ip = ip.replace(' ', '')  # Remove any spaces
            ip_parts = ip.split(',')
            for part in ip_parts:
                if part.lower() == "localsubnet":
                    continue
                try:
                    if '/' in part:
                        ipaddress.ip_network(part, strict=False)
                    else:
                        ipaddress.ip_address(part)
                except ValueError:
                    return False
            return True
        

        def validate_ports(port_str):
            if port_str == '':
                return True
            port_str = port_str.replace(' ', '')  # Remove any spaces
            ports = port_str.split(',')
            for port in ports:
                if '-' in port:
                    start_port, end_port = port.split('-')
                    if not (start_port.isdigit() and end_port.isdigit() and 1 <= int(start_port) <= 65535 and 1 <= int(end_port) <= 65535 and int(start_port) <= int(end_port)):
                        return False
                elif not (port.isdigit() and 1 <= int(port) <= 65535):
                    return False
            return True
        
        def validate_port_xp(port):
            if port.isdigit() and 1 <= int(port) <= 65535:
                return True
            return False

        def get_valid_input(prompt, valid_options=None):
            while True:
                user_input = input(prompt).strip().lower()
                if valid_options:
                    if user_input in valid_options:
                        return user_input
                    print(f"Please enter one of the following: {', '.join(valid_options)}")
                else:
                    return user_input
                
        
        def get_valid_input_xp(prompt, valid_options, allow_empty=False, default_value=None):
            while True:
                user_input = input(prompt).strip().lower()
                if allow_empty and user_input == '':
                    return default_value
                if user_input in valid_options:
                    return user_input
                if allow_empty:
                    print(f"Please enter one of the following: {', '.join(valid_options)} or press Enter for default ({default_value.upper()})")
                else:
                    print(f"Please enter one of the following: {', '.join(valid_options)}")

        def sanitize_program_path(program_path):
            return program_path.replace(' ', '_').replace(':', '').replace('\\', '_')

        def add_firewall_rule():
            
            if "xp" in str(db_file):
                while True:
                    add_rule = get_valid_input_xp("Do you want to add a new firewall rule? (y/n): ", ['y', 'n'])
                    if add_rule == 'n':
                        print("Exiting.")
                        break

                    mode = get_valid_input_xp("Specify the action mode (enable/disable, default is ENABLE): ", ['enable', 'disable'], allow_empty=True, default_value='enable')
                    rule_type = get_valid_input_xp("What will be added - port or program? (port/program): ", ['port', 'program'])

                    port, program_path, protocol, ip_scope, ip_address = None, None, None, None, None

                    if rule_type == 'port':
                        port = input("Enter a single port number (e.g., 80): ").strip()
                        while not validate_port_xp(port):
                            print("Invalid port. Please enter a valid single port number.")
                            port = input("Enter a single port number (e.g., 80): ").strip()

                        protocol = get_valid_input_xp("Specify the protocol (TCP/UDP/ALL): ", ['tcp', 'udp', 'all']).upper()

                        ip_scope = get_valid_input_xp("Specify the scope (all/subnet/custom, default is ALL): ", ['all', 'subnet', 'custom'], allow_empty=True, default_value='all')
                        if ip_scope == 'custom':
                            ip_address = input("Enter IP addresses (comma separated, e.g., '192.168.0.1, 192.168.1.0/24, localsubnet'): ").replace(' ', '').strip()
                            while not validate_ip_xp(ip_address):
                                print("Please enter valid IP addresses (comma separated, e.g., '192.168.0.1, 192.168.1.0/24, localsubnet').")
                                ip_address = input("Enter IP addresses (comma separated, e.g., '192.168.0.1, 192.168.1.0/24, localsubnet'): ").replace(' ', '').strip()

                    if rule_type == 'program':
                        program_path = input("Enter the path to the program (.exe, .bat, .ps1): ").strip()
                        while not validate_program_path(program_path):
                            print("Please enter a valid path to the program with extension .exe, .bat, или .ps1.")
                            program_path = input("Enter the path to the program (.exe, .bat, .ps1): ").strip()

                        ip_scope = get_valid_input_xp("Specify the scope (all/subnet/custom, default is ALL): ", ['all', 'subnet', 'custom'], allow_empty=True, default_value='all')
                        if ip_scope == 'custom':
                            ip_address = input("Enter IP addresses (comma separated, e.g., '192.168.0.1, 192.168.1.0/24, localsubnet'): ").replace(' ', '').strip()
                            while not validate_ip_xp(ip_address):
                                print("Please enter valid IP addresses (comma separated, e.g., '192.168.0.1, 192.168.1.0/24, localsubnet').")
                                ip_address = input("Enter IP addresses (comma separated, e.g., '192.168.0.1, 192.168.1.0/24, localsubnet'): ").replace(' ', '').strip()

                    profile = get_valid_input_xp("For which profile will the rule be used? (all/domain/standard, default is CURRENT): ", ['all', 'domain', 'standard'], allow_empty=True, default_value='current')

                    rule_name = f"{mode}"
                    if port:
                        rule_name += f"_{port}_{protocol}"
                    if program_path:
                        sanitized_program_path = sanitize_program_path(program_path)
                        rule_name += f"_{sanitized_program_path}"
                    rule_name += f"_{profile}"

                    if rule_type == 'program':
                        command = f"netsh firewall add allowedprogram program=\"{program_path}\" name=\"{rule_name}\""
                        if mode:
                            command += f" mode={mode.upper()}"
                        if profile:
                            command += f" profile={profile.upper()}"
                        if ip_scope == 'custom' and ip_address:
                            command += f" scope=custom addresses={ip_address}"
                        elif ip_scope == 'subnet':
                            command += f" scope=subnet"
                        elif ip_scope == 'all':
                            command += f" scope=all"
                    else:
                        command = f"netsh firewall add portopening protocol={protocol} port={port} name=\"{rule_name}\""
                        if mode:
                            command += f" mode={mode.upper()}"
                        if profile:
                            command += f" profile={profile.upper()}"
                        if ip_scope == 'custom' and ip_address:
                            command += f" scope=custom addresses={ip_address}"
                        elif ip_scope == 'subnet':
                            command += f" scope=subnet"
                        elif ip_scope == 'all':
                            command += f" scope=all"

                    write_rule(rule_name, command)
                    print(f"Rule '{rule_name}' has been added to the file and will be applied later.")
                    
            else:
                while True:
                    add_rule = get_valid_input("Do you want to add a new firewall rule? (y/n): ", ['y', 'n'])
                    if add_rule == 'n':
                        print("Exiting.")
                        break

                    direction = get_valid_input("Specify the action direction (in/out): ", ['in', 'out'])
                    rule_type = get_valid_input("What will be added - IP address, port, or program? (ip/port/program): ", ['ip', 'port', 'program'])

                    ip_type, ip_addresses, local_ips, local_ports, remote_ports, program_path, protocol = None, None, None, None, None, None, None

                    if rule_type == 'ip':
                        ip_type = get_valid_input("Specify IP type (localip/remoteip): ", ['localip', 'remoteip'])
                        if ip_type == 'remoteip':
                            ip_addresses = input("Enter remote IP address(es) (or range, or with mask, or 'localsubnet'), separated by commas: ").replace(' ', '').strip()
                            while not validate_ips(ip_addresses):
                                print("Please enter valid remote IP address(es), range, network, or 'localsubnet'.")
                                ip_addresses = input("Enter remote IP address(es) (or range, or with mask, or 'localsubnet'), separated by commas: ").replace(' ', '').strip()
                        elif ip_type == 'localip':
                            local_ips = input("Enter local IP address(es) (or range, or with mask), separated by commas: ").replace(' ', '').strip()
                            while not validate_ips(local_ips, allow_localsubnet=False):
                                print("Please enter valid local IP address(es), range, or network.")
                                local_ips = input("Enter local IP address(es) (or range, or with mask), separated by commas: ").replace(' ', '').strip()

                        while True:
                            local_ports = input("Enter local port number(s) or a range (default - ANY): ").replace(' ', '').strip()
                            if local_ports == '' or validate_ports(local_ports):
                                break
                            else:
                                print("Please enter valid local port number(s) or a range (e.g., 80,443,1000-2000).")

                        if local_ports:
                            protocol = get_valid_input("Specify the protocol (TCP/UDP): ", ['tcp', 'udp']).upper()

                        while True:
                            remote_ports = input("Enter remote port number(s) or a range (default - ANY): ").replace(' ', '').strip()
                            if remote_ports == '' or validate_ports(remote_ports):
                                break
                            else:
                                print("Please enter valid remote port number(s) or a range (e.g., 80,443,1000-2000).")

                    if rule_type == 'port':
                        while True:
                            local_ports = input("Enter local port number(s) or a range (default - ANY): ").replace(' ', '').strip()
                            if local_ports == '' or validate_ports(local_ports):
                                break
                            else:
                                print("Invalid ports. Please enter valid local port number(s) or a range (e.g., 80,443,1000-2000).")
                        
                        if local_ports:
                            protocol = get_valid_input("Specify the protocol (TCP/UDP): ", ['tcp', 'udp']).upper()

                        while True:
                            remote_ports = input("Enter remote port number(s) or a range (default - ANY): ").replace(' ', '').strip()
                            if remote_ports == '' or validate_ports(remote_ports):
                                break
                            else:
                                print("Invalid ports. Please enter valid remote port number(s) or a range (e.g., 80,443,1000-2000).")

                        ip_addresses = input("Enter remote IP address(es) (or range, or with mask, or 'localsubnet'), separated by commas (default - ANY): ").replace(' ', '').strip()
                        if ip_addresses and not validate_ips(ip_addresses):
                            print("Please enter valid remote IP address(es), range, network, or 'localsubnet'.")
                            ip_addresses = input("Enter remote IP address(es) (or range, or with mask, or 'localsubnet'), separated by commas (default - ANY): ").replace(' ', '').strip()

                        local_ips = input("Enter local IP address(es) (or range, or with mask), separated by commas (default - ANY): ").replace(' ', '').strip()
                        if local_ips and not validate_ips(local_ips, allow_localsubnet=False):
                            print("Please enter valid local IP address(es), range, or network.")
                            local_ips = input("Enter local IP address(es) (or range, or with mask), separated by commas (default - ANY): ").replace(' ', '').strip()

                    if rule_type == 'program':
                        program_path = input("Enter the path to the program (.exe, .bat, .ps1): ").strip()
                        while not validate_program_path(program_path):
                            print("Please enter a valid path to the program with extension .exe, .bat, or .ps1.")
                            program_path = input("Enter the path to the program (.exe, .bat, .ps1): ").strip()

                        while True:
                            local_ports = input("Enter local port number(s) or a range (default - ANY): ").replace(' ', '').strip()
                            if local_ports == '' or validate_ports(local_ports):
                                break
                            else:
                                print("Please enter valid local port number(s) or a range (e.g., 80,443,1000-2000).")

                        if local_ports:
                            protocol = get_valid_input("Specify the protocol (TCP/UDP): ", ['tcp', 'udp']).upper()

                        while True:
                            remote_ports = input("Enter remote port number(s) or a range (default - ANY): ").replace(' ', '').strip()
                            if remote_ports == '' or validate_ports(remote_ports):
                                break
                            else:
                                print("Please enter valid remote port number(s) or a range (e.g., 80,443,1000-2000).")

                        ip_addresses = input("Enter remote IP address(es) (or range, or with mask, or 'localsubnet'), separated by commas (default - ANY): ").replace(' ', '').strip()
                        if ip_addresses and not validate_ips(ip_addresses):
                            print("Please enter valid remote IP address(es), range, network, or 'localsubnet'.")
                            ip_addresses = input("Enter remote IP address(es) (or range, or with mask, or 'localsubnet'), separated by commas (default - ANY): ").replace(' ', '').strip()

                        local_ips = input("Enter local IP address(es) (or range, or with mask), separated by commas (default - ANY): ").replace(' ', '').strip()
                        if local_ips and not validate_ips(local_ips, allow_localsubnet=False):
                            print("Please enter valid local IP address(es), range, or network.")
                            local_ips = input("Enter local IP address(es) (or range, or with mask), separated by commas (default - ANY): ").replace(' ', '').strip()

                    action = get_valid_input("Specify the action (block/allow): ", ['block', 'allow'])
                    profile = get_valid_input("For which profile will the rule be used? (domain/private/public/any): ", ['domain', 'private', 'public', 'any'])

                    rule_name = f"{action}_{direction}"
                    if ip_addresses:
                        rule_name += f"_{ip_addresses.replace(',', '_').replace('-', '_')}"
                    if local_ips:
                        rule_name += f"_{local_ips.replace(',', '_').replace('-', '_')}"
                    if local_ports:
                        rule_name += f"_{local_ports.replace(',', '_').replace('-', '_')}"
                    if remote_ports:
                        rule_name += f"_{remote_ports.replace(',', '_').replace('-', '_')}"
                    if program_path:
                        sanitized_program_path = sanitize_program_path(program_path)
                        rule_name += f"_{sanitized_program_path}"
                    rule_name += f"_{profile}"

                    command = f"netsh advfirewall firewall add rule name=\"{rule_name}\" dir={direction} action={action} profile={profile}"
                    if ip_addresses:
                        command += f' remoteip="{ip_addresses}"'
                    if local_ips:
                        command += f' localip="{local_ips}"'
                    if local_ports:
                        command += f' localport="{local_ports}" protocol={protocol}'
                    if remote_ports:
                        command += f' remoteport="{remote_ports}"'
                    if program_path:
                        command += f' program="{program_path}" enable=yes'

                    write_rule(rule_name, command)
                    print(f"Rule '{rule_name}' has been added to the file and will be applied later.")

        process_firewall()
        add_firewall_rule()

def ng_reg():
    registry_operations('Next Generation', filename, db_file, current_lang_code)
                        
                       
def iexplore_reg():
    def ask_user(prompt, valid_responses):
        while True:
            response = input(prompt).strip().lower()
            if response in valid_responses:
                return response
            print(f'Invalid input. Valid responses are: {", ".join(valid_responses)}')

    def apply_registry_values(sql_request, show_params):
        with sqlite3.connect(db_file) as sqlite_conn:
            sql_cursor = sqlite_conn.execute(sql_request)
            for record in sql_cursor:
                reg_key, reg_value, value_type, parameter, description = record
                if show_params:
                    if current_lang_code != "en":
                        description = GoogleTranslator(source='auto', target=current_lang_code).translate(description)
                    print(f'"{reg_key}" /v "{reg_value}" /t {value_type} /d "{parameter}" /f\n{description}\n')
                    apply = ask_user("Apply (y/n)?: ", ['y', 'n'])
                else:
                    apply = 'y'
                if apply == 'y':
                    with open(filename + ".bat", 'a') as bat_file:
                        bat_file.write(f'echo Applying "{reg_key}" /v "{reg_value}" /t {value_type} /d "{parameter}" /f\n')
                        bat_file.write(f'reg add "{reg_key}" /v "{reg_value}" /t {value_type} /d "{parameter}" /f\n')
                else:
                    print("Skipping this register value...\n")

    def add_registry_values():
        ie_versions = {
            'xp': ['ie6', 'ie7', 'ie8'],
            'vista': ['ie7', 'ie8', 'ie9'],
            'seven': ['ie8', 'ie9', 'ie10', 'ie11'],
            'eightzero': ['ie10', 'ie11'],
            'eightone': ['ie11'],
            'ten': ['ie11']
        }

        for os_version, versions in ie_versions.items():
            if any(keyword in str(db_file) for keyword in [os_version]):
                if os_version in ['eightone', 'ten']:
                    show_params = ask_user("Show the parameters (y/n)?: ", ['y', 'n']) == 'y'
                    profiles = "','".join(versions)
                    sql_request = f"""SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('{profiles}')"""
                    apply_registry_values(sql_request, show_params)
                    break
                else:
                    version = ask_user(f"\nWhat version of IE you want to harden? ({'/'.join(versions)})?: ", versions)
                    show_params = ask_user("Show the parameters (y/n)?: ", ['y', 'n']) == 'y'
                    profiles = "','".join(versions[:versions.index(version) + 1])
                    sql_request = f"""SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN ('{profiles}')"""
                    apply_registry_values(sql_request, show_params)
                    break

    if any(keyword in str(db_file) for keyword in ['xp', 'vista', 'seven', 'eightzero', 'eightone', 'ten']):
        print("Do you want to add Internet Explorer registry values?")
        iexplore_input = ask_user("Add (y/n)?: ", ['y', 'n'])

        if iexplore_input == 'y':
            with open(filename + ".bat", 'a') as bat_file:
                bat_file.write(f'\necho Adding Internet Explorer values... \n')

            add_registry_values()
        else:
            print("Skipping Internet Explorer register values... \n")


def manual_generation():
    def write_to_bat(command):
        with open(f"{filename}.bat", 'a') as bat_file:
            bat_file.write(command)

    def handle_input(prompt, valid_options):
        while True:
            user_input = input(prompt).strip().lower()
            if user_input in valid_options:
                return user_input
            print(f'Invalid input. Input must be one of {valid_options}\n')

    def answer_function(record_value):
        if handle_input("Apply (y/n)?: ", ['y', 'n']) == 'y':
            write_to_bat(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
            write_to_bat(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
        else:
            print("Skipping this register value...\n")

    def ntp_change(record_value):
        if handle_input("Do you want to change NTP Server (default server: time.windows.com)?\nChange (y/n)?: ", ['y', 'n']) == 'y':
            ntp_srv = input("Enter the server: ").strip()
            write_to_bat(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{ntp_srv}" /f\n')
            write_to_bat(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{ntp_srv}" /f\n')
        else:
            write_to_bat(f'echo Applying "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
            write_to_bat(f'reg add "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')

    def delete_reg(record_value):
        if handle_input("Do you want to delete this registry value?\nDelete (y/n)?: ", ['y', 'n']) == 'y':
            write_to_bat(f'echo Deleting "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]}" /d "{record_value[3]}" /f\n')
            write_to_bat(f'reg delete "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]}" /d "{record_value[3]}" /f\n')
        else:
            print("Skipping this register value...\n")

    def process_record(record):
        record_value = record
        description = record_value[4] if current_lang_code == 'en' else GoogleTranslator(source='auto', target=current_lang_code).translate(record_value[4])
        print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]}" /d "{record_value[3]}" /f \n {description} \n')
        if "NTPServer" in record_value[4]:
            ntp_change(record_value)
        elif "POSIX" not in record_value[4]:
            answer_function(record_value)
        else:
            delete_reg(record_value)

    def process_hku_records(hku_records):
        if hku_records:
            process_hkcu_batch(start=True)
            for record in hku_records:
                process_record(record)
            process_hkcu_batch(start=False)
            replace_hkcu()

    with sqlite3.connect(db_file) as sqlite_conn:
        sql_request = """SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile NOT IN ('BitLocker', 'Defender', 'Edge', 'Firewall', 'Next Generation', 'ie6', 'ie7', 'ie8', 'ie9', 'ie10', 'ie11')"""
        sql_cursor = sqlite_conn.execute(sql_request)

        hku_records = []
        for record in sql_cursor:
            if 'HKEY_CURRENT_USER' in record[0]:
                hku_records.append(record)
            else:
                process_record(record)

        process_hku_records(hku_records)

        bitlocker_reg()
        defender_reg()
        edge_reg()
        firewall_reg()
        ng_reg()
        iexplore_reg()


def auto_generation():
    def write_bat_file(record_value, filename):
        action = "Applying" if "POSIX" not in record_value[4] else "Deleting"
        command = "add" if "POSIX" not in record_value[4] else "delete"
        with open(filename + ".bat", 'a') as bat_file:
            bat_file.write(f'echo {action} "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
            bat_file.write(f'reg {command} "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')

    def process_records(sql_request, filename):
        hku_records = []
        with sqlite3.connect(db_file) as sqlite_conn:
            sql_cursor = sqlite_conn.execute(sql_request)
            for record in sql_cursor:
                if 'HKEY_CURRENT_USER' in record[0]:
                    hku_records.append(record)
                else:
                    write_bat_file(record, filename)

        if hku_records:
            process_hkcu_batch(start=True)
            for record in hku_records:
                write_bat_file(record, filename)
            process_hkcu_batch(start=False)
            replace_hkcu()

    profiles = {
        'full': "NOT IN ('BitLocker', 'Defender', 'Edge', 'Firewall', 'Next Generation', 'ie6', 'ie7', 'ie8', 'ie9', 'ie10', 'ie11')",
        'med': "NOT IN ('BitLocker', 'Defender', 'Edge', 'Firewall', 'Next Generation', 'Full', 'ie6', 'ie7', 'ie8', 'ie9', 'ie10', 'ie11')",
        'min': "NOT IN ('BitLocker', 'Defender', 'Edge', 'Firewall', 'Next Generation', 'Full', 'Med', 'ie6', 'ie7', 'ie8', 'ie9', 'ie10', 'ie11')"
    }
    
    while True:
        auto_profile = input("Enter the level of hardening (min/med/full): ").strip()
        if auto_profile in profiles:
            sql_request = f"SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile {profiles[auto_profile]}"
            process_records(sql_request, filename)
            bitlocker_reg()
            defender_reg()
            edge_reg()
            firewall_reg()
            ng_reg()
            iexplore_reg()
            break
        else:
            print('Invalid input. Input must be "min", "med" or "full" \n')


def addon_gen():
    def process_choice(choice):
        match choice:
            case 'firewall':
                firewall_reg()
            case 'iexplorer':
                iexplore_reg()
            case 'bitlocker':
                bitlocker_reg()
            case 'defender':
                defender_reg()
            case 'edge':
                edge_reg()
            case 'ng':
                ng_reg()
        print(f"Your .bat script saved: {abs_dir}")
        finalize_bat_file()

    def get_user_choice(options):
        while True:
            addon_profile = input(f"Enter the type of additional parameters you want ({'/'.join(options)}/none): ").strip().lower()
            if addon_profile in options:
                process_choice(addon_profile)
                break
            elif addon_profile == 'none':
                print("Returning...")
                os.remove(f"{filename}.bat")
                break
            else:
                print(f'Invalid input. Input must be one of {", ".join(options)} or none \n')

    if any(keyword in str(db_file) for keyword in ['xp', 'vista']):
        get_user_choice(['firewall', 'iexplorer'])
    elif any(keyword in str(db_file) for keyword in ['seven', 'eightzero', 'eightone']):
        get_user_choice(['bitlocker', 'defender', 'firewall', 'iexplorer'])
    elif any(keyword in str(db_file) for keyword in ['ten']):
        get_user_choice(['bitlocker', 'defender', 'edge', 'firewall', 'ng', 'iexplorer'])
    elif any(keyword in str(db_file) for keyword in ['eleven']):
        get_user_choice(['bitlocker', 'defender', 'edge', 'firewall', 'ng'])


def office_gen():
    def write_to_bat(content):
        with open(filename + ".bat", 'a') as bat_file:
            bat_file.write(content)

    def handle_input(prompt, valid_responses):
        while True:
            response = str(input(prompt)).strip().lower()
            if response in valid_responses:
                return response
            else:
                print(f'Invalid input. Input must be one of {", ".join(valid_responses)} \n')

    def apply_or_delete(record_value, mode, indent="", current_lang_code="en"):
        action = 'Applying'
        command = 'add'
        if any(keyword in record_value[1] for keyword in ['OutlookSecureTempFolder', 'FileExtensionsRemoveLevel1', 'FileExtensionsRemoveLevel2', 'TrustedAddins', 'allowdde']):
            action = 'Deleting'
            command = 'delete'

        if mode == 'a':
            write_to_bat(f'{indent}echo {action} "{record_value[0]}" /v "{record_value[1]}" /f\n')
            write_to_bat(f'{indent}reg {command} "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
        else:
            description = record_value[4]
            if "en" in current_lang_code:
                description = record_value[4]
            else:
                description = GoogleTranslator(source='auto', target=current_lang_code).translate(record_value[4])
            print(f'"{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]}" /d "{record_value[3]}" /f \n {description} \n')
            response = handle_input(f"{command} (y/n)?: ", ['y', 'n'])
            if response == 'y':
                write_to_bat(f'{indent}echo {action} "{record_value[0]}" /v "{record_value[1]}" /f\n')
                write_to_bat(f'{indent}reg {command} "{record_value[0]}" /v "{record_value[1]}" /t {record_value[2]} /d "{record_value[3]}" /f\n')
            else:
                print("Skipping this register value...\n")

    def write_restore_point(bat_file, os_choice, filename):
        if any(keyword in str(os_choice) for keyword in ['seven', 'eightzero', 'eightone', 'ten', 'eleven']):
            bat_file.write("echo Enabling Restore Point service...\n")
            bat_file.write("powershell \"Enable-ComputerRestore -Drive 'C:\\'\"\n")
            bat_file.write("echo Creating restore point...\n")
        elif 'vista' in str(os_choice):
            bat_file.write("echo Creating restore point...\n")
        elif 'xp' in str(os_choice):
            bat_file.write("echo Enabling Restore Point service...\n")
            bat_file.write("sc config srservice start= auto\n")
            bat_file.write("net start srservice\n")
            bat_file.write("echo Creating restore point...\n")

        bat_file.write(f'wmic.exe /Namespace:\\\\root\\default Path SystemRestore Call CreateRestorePoint "Before install the AHWT {filename} script", 100, 7\n')

    def fetch_records(profile):
        with sqlite3.connect(db_file) as sqlite_conn:
            sql_request = f"""SELECT reg_key, reg_value, value_type, parameter, description FROM Main WHERE profile IN {profile}"""
            return sqlite_conn.execute(sql_request)

    def process_records(records, hkey_type, mode='a', current_lang_code="en"):
        for record in records:
            record_value = record
            if hkey_type in record_value[0]:
                if mode == 'a':
                    apply_or_delete(record_value, mode, '\t')
                else:
                    if hkey_type == 'HKEY_LOCAL_MACHINE':
                        apply_or_delete(record_value, mode, current_lang_code=current_lang_code)
                    else:
                        apply_or_delete(record_value, mode, '\t', current_lang_code=current_lang_code)

    with open(filename + ".bat", 'w') as bat_file:
        bat_file.write("@echo off\n\n")
        bat_file.write("\necho Adding commands...\n")

    office_choice = handle_input("Enter the version of MS Office you want to harden (2003/2007/2010/2013/2016/365/none): ", ['2003', '2007', '2010', '2013', '2016', '365', 'none'])
    
    if office_choice == '2003':
        os_choices = ['xp', 'vista']
    elif office_choice in ['2007', '2010']:
        os_choices = ['xp', 'vista', 'seven', 'eightzero', 'eightone', 'ten']
    elif office_choice in ['2013', '2016']:
        os_choices = ['seven', 'eightzero', 'eightone', 'ten', 'eleven']
    elif office_choice == '365':
        os_choices = ['ten', 'eleven']
    
    if office_choice != 'none':
        if handle_input("Do you need to create the restore point before applying script? (y/n): ", ['y', 'n']) == 'y':
            os_choice = handle_input("Choose the operating system " + "(" + "/".join(os_choices) + ")" + ": ", os_choices)
            with open(filename + ".bat", 'a') as bat_file:
                write_restore_point(bat_file, os_choice, filename)
            
        mode = handle_input("Auto or Manual generation of .bat script (a/m): ", ['a', 'm'])
        profiles = {
            '2003': ('Office2003', 'OfficeHKLM'),
            '2007': ('Office2007', 'OfficeHKLM'),
            '2010': ('Office2010', 'OfficeHKLM'),
            '2013': ('Office2013', 'OfficeHKLM'),
            '2016': ('Office2016', 'OfficeHKLM'),
            '365': ('Office2016', 'Office365', 'OfficeHKLM')
        }

        records = fetch_records(profiles[office_choice])
        process_records(records, 'HKEY_LOCAL_MACHINE', mode, current_lang_code)
        
        process_hkcu_batch(start=True)
        records = fetch_records(profiles[office_choice])
        process_records(records, 'HKEY_CURRENT_USER', mode, current_lang_code)
        process_hkcu_batch(start=False)

        replace_hkcu()
        print(f"Your .bat script saved: {abs_dir}")
        write_to_bat('echo Mission Accomplished! :)\n')
        write_to_bat('pause\n')
    else:
        print("Returning...")
        os.remove(f"{filename}.bat")


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


def check_language_and_prompt_for_translation():
    current_locale = locale.getdefaultlocale()
    current_lang_code = current_locale[0].split("_")[0]
    if current_lang_code != "en":
        while True:
            user_input = input(f"The current language is '{current_lang_code}'. Do you need a translation of the parameter information? (y/n): ").strip().lower()
            if user_input in ['y', 'n']:
                break
            else:
                print("Invalid input. Please enter 'y' or 'n'.")
        if user_input.lower() == "y":
            if internet() is False:
                current_lang_code = "en"
                return current_lang_code
            else:
                print("Providing translations...")
                return current_lang_code
        else:
            print("No translation will be provided.")
            current_lang_code = "en"
            return current_lang_code
    else:
        print("The current language is English. No translation needed.")


print("""
      
    _    _   ___        _______ 
   / \  | | | \ \      / |_   _|
  / _ \ | |_| |\ \ /\ / /  | |  
 / ___ \|  _  | \ V  V /   | |  
/_/   \_|_| |_|  \_/\_/    |_|  
                                
                            
""")
print("Another Hardening Windows Tool v 1.2")

current_lang_code = check_language_and_prompt_for_translation()