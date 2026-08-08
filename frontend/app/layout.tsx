import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Eman Bakery Wholesale",
  description:
    "Wholesale ordering, ledger, and dispatch operations for Eman Bakery.",
};

export default function RootLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en" dir="ltr">
      <body>{children}</body>
    </html>
  );
}
