# When to Compile Python to .pyd — Guidance & Caveats

A practical reference for deciding *whether* to compile Python code into
compiled extensions (`.pyd` on Windows), and the trade-offs involved.

> **Scope:** General engineering guidance only. This is **not** security,
> legal, or agency-policy advice. For credential handling, IP protection,
> or data security, follow your organization's applicable policies.

---

## TL;DR — Decision Table

| Goal | Good fit? | Notes |
|------|-----------|-------|
| Speed up CPU-bound / numerical code | ✅ Excellent | The original purpose of extensions |
| Wrap an existing C / C++ library | ✅ Excellent | Native interop |
| Prevent **casual** edits to delivered code | 🟡 Reasonable | With realistic expectations |
| **Protect credentials / secrets** | 🔴 **No** | Compiling is NOT encryption — keep secrets out of code |
| General glue / I/O / orchestration code | 🔴 Usually not | Build complexity rarely worth it |

---

## When Compiling IS Worthwhile

### 1. Performance (the primary purpose)
Compiling shines for **CPU-bound hot paths**:
- Tight numerical loops
- Array / matrix processing
- Coordinate transforms, grid interpolation, geodesy math
- Any inner loop that dominates runtime

Pure-Python overhead disappears once the hot code is C/C++/Cython.
*If the bottleneck is I/O or network, compiling won't help — profile first.*

### 2. Wrapping C / C++ Libraries
Exposing an existing native library to Python is a classic, legitimate
use of extensions.

### 3. Modest Tamper-Resistance for Delivered Code
A `.pyd` is meaningfully harder to *casually* edit than a `.py`. Good for:
- Preventing accidental edits by end users
- Stopping "helpful" unsanctioned modifications on delivery
- Raising the effort bar for casual tinkering

---

## Where to Be Cautious

### ⚠️ Compiling Is NOT Security / Encryption
Compiling changes the *format*, not the *secrecy*, of what's inside.
- **Embedded strings remain present in the binary.** Running `strings` on a
  `.pyd` (or opening it in a hex editor) will often dump readable text with
  **no decompiling required**.
- Tools like Ghidra make deeper analysis straightforward for anyone motivated.
- "Few will bother to decompile" is a **bet on attacker effort**, not a
  security control. It holds until the one person who *does* bother.

### 🔴 Don't Rely on Compiling to Protect Credentials
**Credentials embedded in a `.pyd` are still present in the binary.** The
robust patterns keep secrets *out of the code entirely*:

| Pattern | Tool / Mechanism |
|---------|------------------|
| Environment variables | Read at runtime |
| External config file | `.env` + `python-dotenv` (keep out of version control!) |
| OS credential store | Windows Credential Manager via `keyring` |
| Secrets manager | Organization-provided vault/secrets service |

> **Bottom line:** Keep secrets out of the source. Then the artifact format
> doesn't affect their safety. Follow your organization's policy.

### 🟡 Nuance: Private, Non-Circulated Bootstrapping
A `.pyd` may reasonably serve as a **private, one-time seeding tool** — e.g.,
a personally-run module that writes credentials into the OS credential store
(Windows Credential Manager via `keyring`), after which the real code reads
from that store. In this pattern:
- The binary is **never circulated**.
- It runs **only inside the sanctioned environment**.
- The **durable** credential storage is the OS store, not the binary.
- The binary is ideally **removed or secured** once seeding is complete.

This is defensible because the compiled file is *transport*, not the security
model. It is **not** a license to embed secrets in **distributed** binaries or
to treat compilation as encryption.

### 🟡 "Protecting Logic / IP" — Realistic Expectations
For shielding delivered *logic* from modification, `.pyd` is a reasonable,
pragmatic choice — with honest limits:
- ✅ Stops accidental edits and casual tinkering.
- ⚠️ Does **not** provide true IP protection against a determined
  reverse-engineer. Both Python bytecode and compiled extensions can be analyzed.
- Consider pairing the `.pyd` with a **license + explicit "do not modify"
  documentation**, rather than assuming the binary is a hard barrier.

---

## Other Practical Caveats

### ABI Lock-In
A `.pyd` is tied to the **exact Python minor version** that built it
(e.g., a 3.11 build only imports into 3.11). Building and target Python
**must match**. (Exception: the Stable ABI / `Py_LIMITED_API`, a deliberate
opt-in with C-API restrictions.)

### Runtime DLL Dependencies (C++ especially)
C++ `.pyd`s depend on runtime DLLs (`libstdc++-6.dll`, `libgcc_s_seh-1.dll`).
These resolve automatically **inside** the build env, but must **travel with
the .pyd or be on PATH** if distributed or run outside that environment.
Test the standalone scenario before shipping.

### Build Complexity Cost
Every compiled module adds a toolchain dependency, a build step to maintain,
and platform-specific artifacts (a win-amd64 `.pyd` won't run on Linux/macOS).
For code that isn't performance-critical and isn't sensitive, the maintenance
cost usually outweighs the benefit. **Compile deliberately, not by default.**

---

## Rule of Thumb

> Compile for **speed** and **native interop** without hesitation.
> Compile for **tamper-resistance** with realistic expectations.
> Keep proper **secret management** and real **security controls** separate
> from the compilation decision.