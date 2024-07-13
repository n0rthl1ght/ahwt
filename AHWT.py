import db_gen


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
            db_gen.start_module("xp_params.db", db_gen.gen_decision)
        case '2':
            db_gen.start_module("vista_params.db", db_gen.gen_decision)
        case '3':
            db_gen.start_module("seven_params.db", db_gen.gen_decision)
        case '4':
            db_gen.start_module("eightzero_params.db", db_gen.gen_decision)
        case '5':
            db_gen.start_module("eightone_params.db", db_gen.gen_decision)
        case '6':
            db_gen.start_module("ten_params.db", db_gen.gen_decision)
        case '7':
            db_gen.start_module("eleven_params.db", db_gen.gen_decision)
        case '8':
            db_gen.start_module("office.db", db_gen.office_gen)
        case '9':
            print("Have a nice day!")
            break
        case _:
            print("Wrong choice. Choose from 1 to 9...")
            