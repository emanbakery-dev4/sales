import {
  createServer,
  type IncomingMessage,
  type ServerResponse,
} from "node:http";

export function requestHandler(
  request: IncomingMessage,
  response: ServerResponse,
) {
  if (request.method === "GET" && request.url === "/health") {
    response.writeHead(200, { "content-type": "application/json" });
    response.end(
      JSON.stringify({ status: "ok", service: "eman-bakery-worker" }),
    );
    return;
  }

  response.writeHead(404, { "content-type": "application/json" });
  response.end(JSON.stringify({ error: "not_found" }));
}

export function createWorkerServer() {
  return createServer(requestHandler);
}
