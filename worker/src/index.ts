import { loadConfig } from "./config.js";
import { createWorkerServer } from "./server.js";

const config = loadConfig();
const server = createWorkerServer();

server.listen(config.PORT, "0.0.0.0");

function shutdown() {
  server.close(() => process.exit(0));
}
process.on("SIGINT", shutdown);
process.on("SIGTERM", shutdown);
