import { afterEach, describe, expect, it } from "vitest";
import { createWorkerServer } from "./server.js";

const servers: ReturnType<typeof createWorkerServer>[] = [];

afterEach(async () => {
  await Promise.all(
    servers
      .splice(0)
      .map(
        (server) =>
          new Promise<void>((resolve, reject) =>
            server.close((error) => (error ? reject(error) : resolve())),
          ),
      ),
  );
});

async function startServer() {
  const server = createWorkerServer();
  servers.push(server);
  await new Promise<void>((resolve) => server.listen(0, "127.0.0.1", resolve));
  const address = server.address();
  if (!address || typeof address === "string")
    throw new Error("Worker failed to start");
  return `http://127.0.0.1:${address.port}`;
}

describe("worker HTTP server", () => {
  it("reports readiness without exposing internal details", async () => {
    const origin = await startServer();
    const response = await fetch(`${origin}/health`);

    expect(response.status).toBe(200);
    expect(await response.json()).toEqual({
      status: "ok",
      service: "eman-bakery-worker",
    });
  });

  it("returns a controlled response for unknown routes", async () => {
    const origin = await startServer();
    const response = await fetch(`${origin}/missing`);

    expect(response.status).toBe(404);
    expect(await response.json()).toEqual({ error: "not_found" });
  });
});
