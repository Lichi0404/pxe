import csv

with open('credentials.csv', 'w', newline='') as file:
        writer = csv.writer(file)
        field = ["mac_address", "ip", "username", "password"]
                
        writer.writerow(field)
        writer.writerow(["10:62:e5:a3:b1:44", "10.217.35.144", "user1", "password1"])
        writer.writerow(["c8:d9:d2:d7:b4:c6", "10.217.35.145", "user2", "password2"])
