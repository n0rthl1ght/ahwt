import module_xp
import module_vista
import module_seven
import module_eight
import module_eightone
import module_ten
import module_eleven
import module_office

print("""
      
    _    _   ___        _______ 
   / \  | | | \ \      / |_   _|
  / _ \ | |_| |\ \ /\ / /  | |  
 / ___ \|  _  | \ V  V /   | |  
/_/   \_|_| |_|  \_/\_/    |_|  
                                
                            
""")
print("Another Hardening Windows Tool v 1.0")

def menu():
    print("Choose operating system from list:\n")
    print("[1] Windows XP Hardening\n")
    print("[2] Windows Vista Hardening\n")
    print("[3] Windows 7 Hardening\n")
    print("[4] Windows 8 Hardening\n")
    print("[5] Windows 8.1 Hardening\n")
    print("[6] Windows 10 Hardening\n")
    print("[7] Windows 11 Hardening\n")
    print("[8] MS Office Hardening\n")
    print("[9] Exit\n")
    
while True:
    menu()
    choice = input("Your decision: ")
    match choice:
        case '1':
            module_xp.start_module()
        case '2':
            module_vista.start_module()
        case '3':
            module_seven.start_module()
        case '4':
            module_eight.start_module()
        case '5':
            module_eightone.start_module()
        case '6':
            module_ten.start_module()
        case '7':
            module_eleven.start_module()
        case '8':
            module_office.start_module()
        case '9':
            print("Have a nice day!")
            break
        case _:
            print("Wrong choice. Choose from 1 to 9...")