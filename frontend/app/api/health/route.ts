import { NextResponse } from "next/server";

export function GET() {
  return NextResponse.json(
    { status: "ok", service: "eman-bakery-frontend" },
    { headers: { "cache-control": "no-store" } },
  );
}
