#solid question-asker
def ask_user():
    yes = ["y","Y","yes","Yes"]
    no = ["n","N","no","No"]
    check = str(input("Question ? (y/n): ")).lower().strip()
    try:
        if check in yes:
            return True
        elif check in no:
            return False
        else:
            print('Invalid Input')
            return ask_user()
    except Exception as error:
        print("Please enter valid inputs")
        print(error)
        return ask_user()

#implementation looks like:
ask = ask_user()
if ask:
    print("Sweet")
else:
    print("Nah")