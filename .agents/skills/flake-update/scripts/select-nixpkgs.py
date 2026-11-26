#!/usr/bin/env python3
"""Pick the newest nixpkgs revision this flake's hosts can take from cache.nixos.org.

  select-nixpkgs.py select     write .flake-update/nixpkgs.{json,md}; changes nothing
  select-nixpkgs.py apply      apply .flake-update/nixpkgs.json and commit
  select-nixpkgs.py pin ATTR   take ATTR from the newest old-enough revision that has it cached

Candidates are nixpkgs-unstable channel advances at least --min-age-hours old
and newer than the locked revision. For each, newest first, every host's
derivation graph is walked against cache.nixos.org the way `nix build --dry-run`
does, so the result doesn't depend on what's in the local store. Anything that
would be built is compared by name with the same walk at the locked revision:
this repo's own derivations appear in both and cancel out, and what's left are
upstream packages Hydra didn't build. A candidate with none is taken. A
candidate whose only blockers are top-level packages is taken with each of
those packages pinned to its own nixpkgs input at a revision where it is
cached. Otherwise the next candidate is tried, and if none work nixpkgs stays.
"""

import argparse
import concurrent.futures
import datetime as dt
import json
import re
import subprocess
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path

CACHE = "https://cache.nixos.org"
BRANCH = "nixpkgs-unstable"
HYDRA_JOB = "https://hydra.nixos.org/job/nixpkgs/unstable/{attr}.{system}"
MARKER = "# TODO: Remove workaround:"
NIX = ["nix", "--extra-experimental-features", "nix-command flakes"]
ANSI = re.compile(r"\x1b\[[0-9;]*[A-Za-z]")

ROOT = Path(
    subprocess.run(
        ["git", "rev-parse", "--show-toplevel"], check=True, text=True, capture_output=True
    ).stdout.strip()
)
OUT = ROOT / ".flake-update"


def log(msg):
    print(msg, file=sys.stderr, flush=True)


def run(cmd, check=True, timeout=900):
    p = subprocess.run(cmd, cwd=ROOT, text=True, capture_output=True, timeout=timeout)
    if check and p.returncode != 0:
        raise RuntimeError(f"{' '.join(cmd)} failed:\n{p.stderr[-3000:]}")
    return p


def nix(*args, check=True, timeout=900):
    try:
        return run([*NIX, *args], check=check, timeout=timeout)
    except subprocess.TimeoutExpired:
        if check:
            raise
        return subprocess.CompletedProcess(args, 124, "", "timed out")


def override(rev):
    if rev is None:
        return []
    return ["--override-input", "nixpkgs", f"github:NixOS/nixpkgs/{rev}", "--no-write-lock-file"]


def hosts():
    text = (ROOT / ".github/workflows/build.yml").read_text()
    found = {}
    for attr in re.findall(r"^\s*attr:\s*(\S+)\s*$", text, re.M):
        kind, name, *rest = attr.split(".")
        config = f"{kind}.{name}"
        system = nix("eval", "--raw", f".#{config}.pkgs.stdenv.hostPlatform.system").stdout
        found[name] = {"config": config, "toplevel": ".".join(rest), "system": system}
    if not found:
        raise RuntimeError("no hosts found in .github/workflows/build.yml")
    return found


def locked_nixpkgs():
    lock = json.loads((ROOT / "flake.lock").read_text())
    node = lock["nodes"][lock["nodes"]["root"]["inputs"]["nixpkgs"]]["locked"]
    return node["rev"], node["lastModified"]


def gh_json(path):
    return json.loads(run(["gh", "api", path]).stdout)


def channel_revs(min_age_hours):
    pushes = gh_json(f"repos/NixOS/nixpkgs/activity?ref=refs/heads/{BRANCH}&activity_type=push&per_page=100")
    cutoff = dt.datetime.now(dt.timezone.utc) - dt.timedelta(hours=min_age_hours)
    revs = []
    for p in pushes:
        pushed = dt.datetime.fromisoformat(p["timestamp"].replace("Z", "+00:00"))
        if pushed <= cutoff:
            revs.append({"rev": p["after"], "pushed": p["timestamp"]})
    return revs


def commit_time(rev):
    date = gh_json(f"repos/NixOS/nixpkgs/commits/{rev}")["commit"]["committer"]["date"]
    return int(dt.datetime.fromisoformat(date.replace("Z", "+00:00")).timestamp())


_narinfo = {}


def cached(out_path):
    h = Path(out_path).name[:32]
    if h in _narinfo:
        return _narinfo[h]
    for attempt in range(4):
        req = urllib.request.Request(f"{CACHE}/{h}.narinfo", method="HEAD")
        try:
            with urllib.request.urlopen(req, timeout=30):
                _narinfo[h] = True
                return True
        except urllib.error.HTTPError as e:
            if e.code == 404:
                _narinfo[h] = False
                return False
            err = e
        except (urllib.error.URLError, TimeoutError, OSError) as e:
            err = e
        time.sleep(2**attempt)
    raise RuntimeError(f"cache.nixos.org lookup for {h} kept failing: {err}")


def cached_many(paths):
    with concurrent.futures.ThreadPoolExecutor(32) as pool:
        return dict(zip(paths, pool.map(cached, paths)))


def name_of(drv):
    return drv[33:].removesuffix(".drv")


def stem(drv):
    return re.sub(r"-[0-9].*$", "", name_of(drv))


def is_fod(d):
    return any("path" not in o for o in d["outputs"].values()) or "outputHash" in d.get("env", {})


def is_local(d):
    sa = d.get("structuredAttrs") or {}
    env = d.get("env") or {}
    return (
        sa.get("allowSubstitutes") is False
        or sa.get("preferLocalBuild") is True
        or env.get("allowSubstitutes", "1") == ""
        or env.get("preferLocalBuild") == "1"
    )


def out_path(d):
    outs = d["outputs"]
    key = "out" if "out" in outs else sorted(outs)[0]
    return outs[key]["path"]


def input_drvs(d):
    if "inputs" in d:
        return [Path(k).name for k in d["inputs"].get("drvs", {})]
    return [Path(k).name for k in d.get("inputDrvs", {})]


class Walk:
    """What one host would build at one nixpkgs revision."""

    def __init__(self, host, spec, rev):
        self.host, self.spec, self.rev = host, spec, rev
        attr = f".#{spec['config']}.{spec['toplevel']}.drvPath"
        self.root = Path(nix("eval", "--raw", *override(rev), attr).stdout).name
        shown = json.loads(nix("derivation", "show", "-r", f"/nix/store/{self.root}").stdout)
        shown = shown.get("derivations", shown)
        self.drvs = {Path(k).name: v for k, v in shown.items()}
        self.uncached = self._walk()
        self.real = {d for d in self.uncached if not is_local(self.drvs[d])}

    def _walk(self):
        uncached, seen, frontier = set(), {self.root}, [self.root]
        while frontier:
            todo = [d for d in frontier if not is_fod(self.drvs[d])]
            hits = cached_many([out_path(self.drvs[d]) for d in todo])
            frontier = []
            for d in todo:
                if hits[out_path(self.drvs[d])]:
                    continue
                uncached.add(d)
                for i in input_drvs(self.drvs[d]):
                    if i not in seen and i in self.drvs:
                        seen.add(i)
                        frontier.append(i)
        return uncached

    def deps(self, d, avoid=frozenset()):
        out, stack = set(), [d]
        while stack:
            for i in input_drvs(self.drvs[stack.pop()]):
                if i in self.uncached and i not in out and i not in avoid:
                    out.add(i)
                    stack.append(i)
        return out

    def names(self):
        return {stem(d) for d in self.real}

    def resolve(self, names):
        names = sorted(set(names))
        if not names:
            return {}
        fn = (
            "pkgs: builtins.listToAttrs (map (n: { name = n; value = "
            "let r = builtins.tryEval (if pkgs ? ${n} then pkgs.${n}.drvPath or null else null); "
            "in if r.success then r.value else null; }) (builtins.fromJSON "
            + json.dumps(json.dumps(names))
            + "))"
        )
        p = nix("eval", "--json", *override(self.rev), f".#{self.spec['config']}.pkgs", "--apply", fn, check=False)
        if p.returncode != 0:
            log(p.stderr[-1500:])
            return {}
        return {n: (Path(v).name if v else None) for n, v in json.loads(p.stdout).items()}


def attr_guesses(walk, d):
    drv = walk.drvs[d]
    guesses = []
    for source in (drv.get("structuredAttrs") or {}, drv.get("env") or {}):
        if isinstance(source.get("pname"), str):
            guesses.append(source["pname"])
    s = stem(d)
    guesses += [s, re.sub(r"^python3[0-9.]*-", "", s)]
    return list(dict.fromkeys(guesses))


def hydra_log(walk, d):
    for cand in [d, *sorted(walk.deps(d) & walk.real)][:6]:
        p = nix("log", "--store", CACHE, f"/nix/store/{cand}", check=False, timeout=120)
        if p.returncode == 0 and p.stdout.strip():
            lines = ANSI.sub("", p.stdout).rstrip().splitlines()
            return {"drv": cand, "tail": lines[-25:]}
    return None


def legacy_out(rev, system, attr):
    p = nix("eval", "--raw", f"github:NixOS/nixpkgs/{rev}#legacyPackages.{system}.{attr}.outPath", check=False)
    return p.stdout.strip() if p.returncode == 0 else None


def upstream_cached(rev, system, attr):
    out = legacy_out(rev, system, attr)
    return bool(out) and cached(out)


def find_pin_rev(attr, systems, revs, skip=()):
    for rev in revs:
        if rev in skip:
            continue
        log(f"  {attr}: checking nixpkgs {rev[:12]} for {', '.join(systems)}")
        if all(upstream_cached(rev, s, attr) for s in systems):
            return rev
    return None


def analyse(cand, base, specs, revs, current, max_pins):
    rev = cand["rev"]
    log(f"candidate {rev[:12]} (channel {cand['pushed']})")
    result = {**cand, "blockers": {}, "usable": False}
    walks = {h: Walk(h, specs[h], rev) for h in specs}
    tops_by_attr, problems = {}, []
    for h, w in walks.items():
        blockers = {d for d in w.real if stem(d) not in base[h].names()}
        if not blockers:
            continue
        below = set().union(*(w.deps(b) for b in blockers))
        tops = sorted(blockers - below)
        resolved = w.resolve(g for t in tops for g in attr_guesses(w, t))
        entries = []
        for t in tops:
            attr = next((g for g in attr_guesses(w, t) if resolved.get(g) == t), None)
            entries.append(
                {
                    "drv": t,
                    "name": name_of(t),
                    "attr": attr,
                    "hydra": HYDRA_JOB.format(attr=attr, system=w.spec["system"]) if attr else None,
                    "log": hydra_log(w, t),
                    "also": sorted(name_of(b) for b in (w.deps(t) & blockers)),
                }
            )
            if attr is None:
                problems.append(f"{name_of(t)} on {h} isn't a top-level package")
            else:
                tops_by_attr.setdefault(attr, set()).add(w.spec["system"])
        reach = w.deps(w.root, avoid=frozenset(tops))
        leftover = sorted(name_of(d) for d in (blockers - set(tops)) & reach)
        if leftover:
            problems.append(f"on {h}, still built after pinning: {', '.join(leftover)}")
        result["blockers"][h] = entries
    result["walks"] = walks
    if not result["blockers"]:
        result["usable"] = True
        result["pins"] = []
        return result
    if len(tops_by_attr) > max_pins:
        problems.append(f"{len(tops_by_attr)} packages would need pinning (limit {max_pins})")
    for attr in tops_by_attr:
        if (ROOT / f"overlays/{attr}.nix").exists():
            problems.append(f"overlays/{attr}.nix already exists")
    pins = []
    if not problems:
        for attr, systems in sorted(tops_by_attr.items()):
            pin = find_pin_rev(attr, sorted(systems), [r["rev"] for r in revs][:8] + [current], skip={rev})
            if pin is None:
                problems.append(f"no old-enough revision has {attr} cached")
                break
            pins.append({"attr": attr, "systems": sorted(systems), "rev": pin})
    result["problems"] = problems
    if not problems:
        result["usable"] = True
        result["pins"] = pins
    return result


def workaround_evidence(walks, rev):
    evidence = []
    for f in sorted((ROOT / "overlays").glob("*.nix")):
        text, attr = f.read_text(), f.stem
        overrides_upstream = re.search(rf"prev\.{re.escape(attr)}\b|inputs\.nixpkgs-", text)
        if MARKER not in text or not overrides_upstream:
            continue
        systems = {}
        for w in walks.values():
            used = w.resolve([attr]).get(attr)
            if used and used in w.drvs:
                systems[w.spec["system"]] = upstream_cached(rev, w.spec["system"], attr)
        evidence.append({"file": f"overlays/{f.name}", "attr": attr, "upstream_cached": systems})
    return evidence


def report_md(data):
    cur, chosen = data["current"], data["rev"]
    lines = ["# nixpkgs", ""]
    days = (time.time() - data["current_time"]) / 86400
    if data["decision"] == "hold":
        lines.append(
            f"Held at `{cur[:12]}` ({days:.0f} days old): no candidate could be taken from cache.nixos.org."
        )
    else:
        lines.append(
            f"`{cur[:12]}` → `{chosen[:12]}` "
            f"([compare](https://github.com/NixOS/nixpkgs/compare/{cur}...{chosen}))"
            + (", with per-package pins" if data["pins"] else "")
            + "."
        )
    lines.append("")
    if data["pins"]:
        lines += ["## Pinned packages", ""]
        for p in data["pins"]:
            lines.append(f"- `{p['attr']}` on {', '.join(p['systems'])} from nixpkgs `{p['rev'][:12]}`")
        lines.append("")
    lines += ["## Candidates", ""]
    if not data["candidates"]:
        lines.append(f"No `{BRANCH}` advance is old enough and newer than the lock.")
    for c in data["candidates"]:
        state = "taken" if c["rev"] == chosen and data["decision"] != "hold" else ("usable" if c["usable"] else "rejected")
        lines.append(f"- `{c['rev'][:12]}` (channel {c['pushed']}): {state}")
        for p in c.get("problems", []):
            lines.append(f"  - {p}")
        for h, entries in c["blockers"].items():
            for e in entries:
                extra = f", also {', '.join(e['also'])}" if e["also"] else ""
                link = f" ([Hydra]({e['hydra']}))" if e["hydra"] else ""
                lines.append(f"  - {h}: `{e['name']}`{link}{extra}")
    lines.append("")
    logs = [(h, e) for c in data["candidates"] for h, es in c["blockers"].items() for e in es if e["log"]]
    if logs:
        lines += ["## Hydra logs", ""]
        for h, e in logs:
            lines += [
                f"<details><summary>{h}: {name_of(e['log']['drv'])}</summary>",
                "",
                "```",
                *e["log"]["tail"],
                "```",
                "",
                "</details>",
                "",
            ]
    lines += ["## Workarounds", ""]
    rev = chosen if data["decision"] != "hold" else cur
    for w in data["workarounds"]:
        if not w["upstream_cached"]:
            lines.append(f"- `{w['file']}`: no host uses `{w['attr']}`")
            continue
        states = ", ".join(f"{s}: {'cached' if ok else 'not cached'}" for s, ok in w["upstream_cached"].items())
        lines.append(f"- `{w['file']}`: unmodified `{w['attr']}` at `{rev[:12]}` is {states}")
    return "\n".join(lines) + "\n"


def cmd_select(args):
    specs = hosts()
    current, current_time = locked_nixpkgs()
    log(f"locked nixpkgs {current[:12]}")
    revs = []
    for r in channel_revs(args.min_age_hours):
        if r["rev"] == current or commit_time(r["rev"]) <= current_time:
            break
        revs.append(r)
    log(f"{len(revs)} candidates")
    log("baseline")
    base = {h: Walk(h, specs[h], None) for h in specs}
    data = {"current": current, "current_time": current_time, "decision": "hold", "rev": current, "pins": [], "candidates": []}
    walks = base
    for cand in revs[: args.max_candidates]:
        result = analyse(cand, base, specs, revs, current, args.max_pins)
        cand_walks = result.pop("walks")
        data["candidates"].append(result)
        if result["usable"]:
            data["decision"] = "update"
            data["rev"] = cand["rev"]
            data["pins"] = result["pins"]
            walks = cand_walks
            break
    pinned = {p["attr"] for p in data["pins"]}
    data["workarounds"] = [w for w in workaround_evidence(walks, data["rev"]) if w["attr"] not in pinned]
    OUT.mkdir(exist_ok=True)
    (OUT / "nixpkgs.json").write_text(json.dumps(data, indent=2) + "\n")
    (OUT / "nixpkgs.md").write_text(report_md(data))
    log(f"decision: {data['decision']} {data['rev'][:12]} pins={sorted(pinned)}")


def set_nixpkgs(rev):
    path = ROOT / "flake.nix"
    text, n = re.subn(
        r'^(\s*)nixpkgs\.url = "[^"]*";$',
        lambda m: f'{m.group(1)}nixpkgs.url = "github:NixOS/nixpkgs/{rev}";',
        path.read_text(),
        count=1,
        flags=re.M,
    )
    if n != 1:
        raise RuntimeError("couldn't find `nixpkgs.url = \"...\";` in flake.nix")
    path.write_text(text)


def insert_sorted(path, pattern, line, name):
    lines = path.read_text().splitlines(keepends=True)
    matches = [(i, m.group(1)) for i, l in enumerate(lines) if (m := re.match(pattern, l))]
    if not matches:
        raise RuntimeError(f"no overlay list found in {path}")
    for i, n in matches:
        if n == name:
            lines[i] = line + "\n"
            path.write_text("".join(lines))
            return
    at = next((i for i, n in matches if n > name), matches[-1][0] + 1)
    lines.insert(at, line + "\n")
    path.write_text("".join(lines))


def add_pin(attr, systems, rev, replace=False):
    overlay = ROOT / f"overlays/{attr}.nix"
    if overlay.exists() and not replace:
        raise RuntimeError(f"{overlay.relative_to(ROOT)} already exists")
    touched = [ROOT / f for f in ("flake.nix", "flake.lock", "overlays/active.nix", "modules/flake/toplevel.nix")] + [overlay]
    saved = {f: (f.read_text() if f.exists() else None) for f in touched}
    new_overlay = saved[overlay] is None
    try:
        _write_pin(attr, systems, rev, overlay)
        if new_overlay:
            # Flakes only see tracked files, so the evals below need the new overlay in the index.
            run(["git", "add", "-N", str(overlay)])
        for spec in hosts().values():
            nix("eval", "--raw", f".#{spec['config']}.{spec['toplevel']}.drvPath")
    except Exception:
        if new_overlay:
            run(["git", "rm", "-q", "--cached", "--ignore-unmatch", str(overlay)], check=False)
        for f, text in saved.items():
            if text is None:
                f.unlink(missing_ok=True)
            else:
                f.write_text(text)
        raise
    run(["git", "add", "flake.nix", "flake.lock", "overlays", "modules/flake/toplevel.nix"])


def _write_pin(attr, systems, rev, overlay):
    flake = ROOT / "flake.nix"
    text = flake.read_text()
    if re.search(rf"^\s*nixpkgs-{re.escape(attr)}[ .=]", text, re.M):
        raise RuntimeError(f"flake.nix already has a nixpkgs-{attr} input")
    jobs = " ".join(HYDRA_JOB.format(attr=attr, system=s) for s in systems)
    marker = (
        f"{MARKER} {attr} isn't cached for {', '.join(systems)} at the main nixpkgs revision ({jobs}); "
        f"drop this input and overlays/{attr}.nix together once select-nixpkgs.py reports it cached there"
    )
    text, n = re.subn(
        r'^(\s*)(nixpkgs\.url = "[^"]*";)$',
        lambda m: f'{m.group(1)}{m.group(2)}\n{m.group(1)}{marker}\n{m.group(1)}nixpkgs-{attr}.url = "github:NixOS/nixpkgs/{rev}";',
        text,
        count=1,
        flags=re.M,
    )
    if n != 1:
        raise RuntimeError("couldn't find `nixpkgs.url = \"...\";` in flake.nix")
    flake.write_text(text)
    elems = " ".join(f'"{s}"' for s in systems)
    overlay.write_text(
        "{ inputs }:\n"
        "(_final: prev: {\n"
        f"  {MARKER} uses the nixpkgs-{attr} input in flake.nix; remove both together\n"
        f"  {attr} =\n"
        f"    if builtins.elem prev.stdenv.hostPlatform.system [ {elems} ] then\n"
        f"      inputs.nixpkgs-{attr}.legacyPackages.${{prev.stdenv.hostPlatform.system}}.{attr}\n"
        "    else\n"
        f"      prev.{attr};\n"
        "})\n"
    )
    insert_sorted(
        ROOT / "overlays/active.nix",
        r"^  \(import \./([\w-]+)\.nix \{.*\}\)$",
        f"  (import ./{attr}.nix {{ inherit inputs; }})",
        attr,
    )
    insert_sorted(
        ROOT / "modules/flake/toplevel.nix",
        r"^      ([\w-]+) = import \.\./\.\./overlays/[\w-]+\.nix \{.*\};$",
        f"      {attr} = import ../../overlays/{attr}.nix {{ inherit inputs; }};",
        attr,
    )
    nix("flake", "lock")


def commit(message):
    run(["git", "commit", "-q", "-m", message])


def cmd_apply(args):
    data = json.loads((OUT / "nixpkgs.json").read_text())
    if data["decision"] == "hold":
        log(f"holding nixpkgs at {data['current'][:12]}")
        return
    if run(["git", "status", "--porcelain"]).stdout.strip():
        raise SystemExit("apply needs a clean tree")
    start = run(["git", "rev-parse", "HEAD"]).stdout.strip()
    try:
        _apply(data)
    except Exception:
        run(["git", "reset", "-q", "--hard", start])
        log(f"apply failed; reset to {start[:12]}, nixpkgs is unchanged")
        raise


def _apply(data):
    old, new = data["current"], data["rev"]
    set_nixpkgs(new)
    nix("flake", "lock")
    run(["git", "add", "flake.nix", "flake.lock"])
    commit(
        f"chore(nixpkgs): {old[:12]} -> {new[:12]}\n\n"
        f"Newest {BRANCH} advance at least a day old that the hosts can take\n"
        f"from cache.nixos.org (see the PR body).\n\n"
        f"https://github.com/NixOS/nixpkgs/compare/{old}...{new}"
    )
    blockers = {
        e["attr"]: e
        for c in data["candidates"]
        if c["rev"] == new
        for es in c["blockers"].values()
        for e in es
    }
    for p in data["pins"]:
        add_pin(p["attr"], p["systems"], p["rev"])
        e = blockers.get(p["attr"], {})
        tail = "\n".join((e.get("log") or {}).get("tail", [])[-12:])
        commit(
            f"fix: take {p['attr']} from nixpkgs {p['rev'][:12]} on {', '.join(p['systems'])}\n\n"
            f"{p['attr']} isn't cached at nixpkgs {new[:12]}, so building it would\n"
            f"mean a from-source build in CI. {p['rev'][:12]} has it cached.\n"
            + (f"\nHydra log ({name_of(e['log']['drv'])}):\n\n{tail}\n" if tail else "")
        )
    log(f"applied nixpkgs {new[:12]} with {len(data['pins'])} pins")


def cmd_pin(args):
    specs = hosts()
    current, current_time = locked_nixpkgs()
    systems = sorted(set(args.system)) if args.system else sorted({s["system"] for s in specs.values()})
    revs = [r["rev"] for r in channel_revs(args.min_age_hours)][:8]
    rev = find_pin_rev(args.attr, systems, revs + [current])
    if rev is None:
        raise SystemExit(f"no old-enough revision has {args.attr} cached for {', '.join(systems)}")
    add_pin(args.attr, systems, rev, replace=args.replace)
    commit(
        f"fix: take {args.attr} from nixpkgs {rev[:12]} on {', '.join(systems)}\n\n"
        f"{args.attr} isn't cached at the main nixpkgs revision {current[:12]};\n"
        f"{rev[:12]} has it cached."
    )
    log(f"pinned {args.attr} to {rev[:12]}")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--min-age-hours", type=float, default=24)
    sub = ap.add_subparsers(dest="cmd", required=True)
    s = sub.add_parser("select", description="Pick a nixpkgs revision; write .flake-update/nixpkgs.{json,md}. Changes nothing.")
    s.add_argument("--max-candidates", type=int, default=6)
    s.add_argument("--max-pins", type=int, default=3)
    sub.add_parser("apply", description="Apply .flake-update/nixpkgs.json: commit the nixpkgs bump and per-package pins. Needs a clean tree; resets on failure.")
    p = sub.add_parser("pin", description="Take ATTR from the newest old-enough nixpkgs revision that has it cached: adds a nixpkgs-ATTR input and overlays/ATTR.nix with markers, checks every host evaluates, and commits.")
    p.add_argument("attr", help="top-level package attribute, e.g. codex")
    p.add_argument("--system", action="append", help="repeatable; defaults to every host's system")
    p.add_argument("--replace", action="store_true", help="overwrite an existing overlays/ATTR.nix")
    args = ap.parse_args()
    {"select": cmd_select, "apply": cmd_apply, "pin": cmd_pin}[args.cmd](args)


if __name__ == "__main__":
    main()
