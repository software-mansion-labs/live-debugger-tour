# LiveDebugger Tour

An interactive, step-by-step tutorial for [LiveDebugger](https://github.com/software-mansion/live-debugger) — a real-time debugging tool for Phoenix LiveView. Each tour step is a self-contained LiveView that introduces a LiveDebugger feature with a minimal, hands-on example you can inspect and debug in real time.

<img alt="LiveDebugger Tour - Start Debugging page" src="https://github.com/user-attachments/assets/16cef8e8-3f3f-4c7a-a97d-c825fc64ce02" />

## Prerequisites

- Elixir ~> 1.15
- Erlang/OTP (compatible with your Elixir version)

## Installation

```bash
# Clone the repository
git clone https://github.com/software-mansion-labs/live-debugger-tour.git
cd live-debugger-tour

# Install dependencies and set up assets
mix setup

# Start the Phoenix server
mix phx.server
```

Then visit [`localhost:4000`](http://localhost:4000) in your browser.

## What it offers

The tour walks you through LiveDebugger's core features across a series of guided steps:

1. **Start Debugging** — Explore the Node Info panel to identify process PIDs, module paths, and jump from the debugger to your code editor.
2. **Inspecting Assigns** — Navigate socket assigns state using search, pinning, and history tracking.
3. **Callback Traces** — Analyze LiveView lifecycle execution times, filter events, and manage trace memory.
4. **Dead LiveView & Exceptions** — Trigger a crash to see how the debugger displays dead process state and identifies successors.
5. **Components Tree** — Visualize complex UI hierarchies with multiple LiveComponents and the highlight feature.
6. **Async Jobs** — Observe `assign_async` behavior and background task state transitions.
7. **Streams** — See how Phoenix Streams are handled and efficiently managed by the debugger.
8. **Global Callback Traces** (coming soon) — Analyze cross-node communication between child components and parent views.
9. **Analyzing Diffs** (coming soon) — Inspect the actual data payloads sent over the wire to understand Phoenix's UI update optimizations.
10. **Resources** (coming soon) — Monitor real-time performance graphs and observe how interactions affect system resource usage.
11. **Active LiveViews** (coming soon) — See all currently running LiveView processes across the application.
12. **Settings** (coming soon) — Explore customization options for the debugger UI and connection parameters.

## Learn more

- [LiveDebugger on GitHub](https://github.com/software-mansion/live-debugger)
- [Phoenix Framework](https://www.phoenixframework.org/)
- [Phoenix LiveView](https://hexdocs.pm/phoenix_live_view)
