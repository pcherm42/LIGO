#This guy removes all foldfold files for the bad channels, checks all days for zeros, deletes those days, and writes the name to a dag file


with open("foldfold_resub.txt", "r") as f:
    lines = f.readlines()

channels = []
locations = []

for line in lines:
    locations.append(line.split()[1])
    channels.append(line.split()[0])
