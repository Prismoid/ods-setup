#!/usr/bin/env python3

import json
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import urlparse


HOST = "0.0.0.0"
PORT = 5050


class RequestHandler(BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"

    def send_json(self, status_code: int, payload: dict) -> None:
        response_body = json.dumps(
            payload,
            ensure_ascii=False,
            indent=2,
        ).encode("utf-8")

        self.send_response(status_code)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(response_body)))
        self.end_headers()
        self.wfile.write(response_body)

    def read_request_body(self):
        content_length = int(self.headers.get("Content-Length", "0"))

        if content_length == 0:
            return None

        raw_body = self.rfile.read(content_length)
        text_body = raw_body.decode("utf-8", errors="replace")

        try:
            return json.loads(text_body)
        except json.JSONDecodeError:
            return text_body

    def handle_request(self) -> None:
        parsed_path = urlparse(self.path)

        if parsed_path.path != "/test":
            self.send_json(
                404,
                {
                    "ok": False,
                    "message": "Not Found",
                    "path": parsed_path.path,
                },
            )
            return

        request_body = self.read_request_body()

        self.send_json(
            200,
            {
                "ok": True,
                "method": self.command,
                "path": parsed_path.path,
                "query": parsed_path.query,
                "body": request_body,
            },
        )

    def do_GET(self) -> None:
        self.handle_request()

    def do_POST(self) -> None:
        self.handle_request()

    def do_PUT(self) -> None:
        self.handle_request()

    def do_DELETE(self) -> None:
        self.handle_request()

    def log_message(self, message_format: str, *args) -> None:
        print(
            f"{self.client_address[0]} "
            f"[{self.log_date_time_string()}] "
            f"{message_format % args}",
            flush=True,
        )


if __name__ == "__main__":
    server = ThreadingHTTPServer((HOST, PORT), RequestHandler)

    print(
        f"HTTP method test server started: "
        f"http://localhost:{PORT}/test",
        flush=True,
    )

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()
