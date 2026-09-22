# NX Menu Import

Turn a restaurant menu — a PDF, photos, a web page, or typed text — into an NX Restaurant menu item import CSV, ready to upload at **Configuration > Import**.

This repository holds the instruction pack that tells an AI assistant how to build that file correctly, plus ready-made packaging for Claude and ChatGPT.

> Maintained by NX Restaurant for the NX dealer network.
> Questions about a specific import belong with your NX Support Partner, not the issue tracker.

## Pick how you want to use it

### Claude — recommended

Download **`nx-menu-import-skill.zip`** from the [latest release](../../releases/latest) and add it as a skill. One-time setup. After that:

> Build an NX menu import file from this menu.

### ChatGPT

Open the **NX Menu Import Builder** GPT — link in the help center article. Nothing to install.

To build your own, follow [`custom-gpt/SETUP.md`](custom-gpt/SETUP.md).

### Any other assistant

Copy [`instructions/NX-Menu-Import-AI-Instructions.md`](instructions/NX-Menu-Import-AI-Instructions.md) into the chat, then give it the menu.

If your assistant can open links, this is usually enough:

```
Read https://raw.githubusercontent.com/nx-systems/nx-menu-import/main/instructions/NX-Menu-Import-AI-Instructions.md
and follow it. Here is the menu.
```

## What's here

| Path | What it is |
|---|---|
| `instructions/` | The instruction pack. The single source of truth — everything else is packaging. |
| `claude-skill/` | The pack as an installable Claude skill |
| `custom-gpt/` | Step-by-step config for the ChatGPT Custom GPT |
| `docs/` | The dealer-facing guide (source for the help center article) |
| `scripts/build-skill.sh` | Builds the release zip from `claude-skill/` |

## How it works

The workflow is deliberately two-pass. The assistant first returns a **plain-language outline** — sections, modifier groups, items, open questions, and anything it wasn't sure it read — and stops. Only after the dealer confirms does it build the CSV, and it prints a self-check before handing the file over.

That checkpoint is the point. An AI will produce a confident, well-formatted file with invented prices in it. The outline is where a dealer catches that, and where they supply the venue's exact Sales Category, Tax Group, and Routing Group names — which matters because NX creates a new configuration record for any name that doesn't match an existing one, with no error.

The pack also encodes the parts of NX that are not obvious from the template alone: that a category becomes a modifier category by being referenced as one, that `Max 0` means unlimited, that `POS Name` is the import's matching key, and that a re-import overwrites the fields the file carries while ignoring the ones it leaves blank.

## Making changes

`instructions/NX-Menu-Import-AI-Instructions.md` is the source of truth. Edit it there, bump the version line in its header, note the change in [`CHANGELOG.md`](CHANGELOG.md), then rebuild the skill:

```sh
./scripts/build-skill.sh
```

The skill's `SKILL.md` is generated from the pack, so do not hand-edit it — your change will be overwritten on the next build.

After a change that affects behavior: re-upload the knowledge file on the Custom GPT, and cut a new release so the help center download points at the current version.

### Verify before you publish

This pack encodes real import behavior, not just formatting. Before publishing a change that touches the column contract, the modifier model, or re-import behavior, run one throwaway import at a test venue and confirm it does what the pack claims.

## License

Released under [CC0 1.0](LICENSE) — public domain dedication. Copy it, paste it into any AI tool, adapt it, build products on it, with no attribution required and no conditions attached.

[`NOTICE.md`](NOTICE.md) covers the two things a copyright waiver does not: the NX trademarks, and what to check before a generated file reaches a live venue.
