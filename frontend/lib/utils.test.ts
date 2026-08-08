import { describe, expect, it } from "vitest";
import { cn } from "./utils";

describe("cn", () => {
  it("merges Tailwind utility classes deterministically", () => {
    expect(cn("p-2", false && "hidden", "p-4")).toBe("p-4");
  });
});
