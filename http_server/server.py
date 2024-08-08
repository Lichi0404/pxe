import csv
from http.server import BaseHTTPRequestHandler, HTTPServer
import json

def get_credentials(ip):
    with open("credentials.csv", "r") as f:
        reader = csv.DictReader(f)
        for row in reader:
            if ip == row["ip"]:
                return row
    return {}


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/username":
            self.handle_username()
        elif self.path == "/password":
            self.handle_password()
        elif self.path == "/ip_address":
            self.handle_ip_address()
        else:
            self.send_error(404)

    def get_ip(self):
        return self.client_address[0]

    def handle_username(self):
        ip = self.get_ip()
        username = get_credentials(ip).get("username")
        if username is None:
            self.send_error(401)
            return
        self.send_response(200)
        self.end_headers()
        self.wfile.write(username.encode())

    def handle_password(self):
        ip = self.get_ip()
        password = get_credentials(ip).get("password")
        if password is None:
            self.send_error(401)
            return
        self.send_response(200)
        self.end_headers()
        self.wfile.write(password.encode())

    def handle_ip_address(self):
        with open("credentials.csv", "r") as f:
            reader = csv.DictReader(f)
            data = [[row["mac_address"], row["ip"]] for row in reader]
        data = json.dumps(data)
        self.send_response(200)
        self.end_headers()
        self.wfile.write(data.encode())


if __name__ == "__main__":
    try:
        server = HTTPServer(("10.217.35.235", 8080), Handler)
        server.serve_forever()
    except KeyboardInterrupt:
        print("\rGoodbye!")
