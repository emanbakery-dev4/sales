import { describe, expect, it } from "vitest";
import { loadConfig } from "./config.js";

describe("loadConfig", () => {
  it("provides safe local defaults", () => {
    expect(loadConfig({})).toEqual({ NODE_ENV: "development", PORT: 3001 });
  });
});
