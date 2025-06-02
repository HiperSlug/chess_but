from http.server import BaseHTTPRequestHandler, HTTPServer

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b"OK")

def run():
    server = HTTPServer(('0.0.0.0', 8080), Handler)
    print("Health check server running on port 1111")
    server.serve_forever()


run()
