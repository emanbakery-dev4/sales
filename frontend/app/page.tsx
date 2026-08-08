import { ArrowRight, ShieldCheck, Sparkles } from "lucide-react";

export default function Home() {
  return (
    <main className="mx-auto flex min-h-screen max-w-6xl items-center px-6 py-16 lg:px-10">
      <section className="w-full rounded-[var(--radius-overlay)] border border-white/10 bg-surface/80 p-8 shadow-card backdrop-blur md:p-14">
        <div className="mb-10 inline-flex items-center gap-2 rounded-full border border-brand/20 bg-brand/10 px-4 py-2 text-sm text-brand-bright">
          <Sparkles aria-hidden="true" className="size-4" /> Wholesale
          operations, crafted carefully
        </div>
        <p className="mb-3 text-sm font-semibold uppercase tracking-[0.24em] text-brand">
          Eman Bakery
        </p>
        <h1 className="max-w-3xl font-display text-5xl leading-tight md:text-7xl">
          Fresh orders. Clear ledgers. Confident dispatch.
        </h1>
        <p className="mt-7 max-w-2xl text-lg leading-8 text-muted">
          A secure operations platform for Eman Bakery&apos;s customers, staff,
          managers, and delivery team.
        </p>
        <div className="mt-10 flex flex-wrap gap-4">
          <span className="inline-flex items-center gap-2 rounded-control bg-gradient-to-r from-brand to-brand-bright px-5 py-3 font-semibold text-canvas shadow-glow">
            Platform foundation ready{" "}
            <ArrowRight aria-hidden="true" className="size-4" />
          </span>
          <span className="inline-flex items-center gap-2 rounded-control border border-white/10 px-5 py-3 text-muted">
            <ShieldCheck aria-hidden="true" className="size-4 text-success" />{" "}
            Enterprise security by design
          </span>
        </div>
      </section>
    </main>
  );
}
