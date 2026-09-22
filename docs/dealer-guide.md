# Using AI to Build a Menu Import File

**Draft for the NX help center · Audience: dealers**

Building a venue's menu by hand is the slowest part of most installs. If you have the menu as a PDF, a set of photos, or a web page, an AI assistant can turn it into a ready-to-upload NX import file in a fraction of the time — categories, items, modifier groups, and all the min/max/free settings included.

This article covers how to do that reliably. The emphasis is on *reliably*: an AI will happily produce a confident, well-formatted file with invented prices in it. The workflow below is built to catch that before it reaches a venue.

## What you need

- The venue's menu in any readable form: PDF, clear photos, a web page, or typed text.
- The venue's existing **Sales Category**, **Tax Group**, and **Routing Group** names, spelled exactly as they appear in the portal. Have these in front of you before you start — you will be asked for them, and getting them wrong is the most common way an import goes sideways.
- An AI assistant. Any will work, and all three routes below produce the same file:
  - **Claude — recommended.** Download the *NX Menu Import* skill from [LINK: GitHub latest release] and add it as a skill. One-time setup, then you just ask.
  - **ChatGPT.** Open the *NX Menu Import Builder* GPT at [LINK: GPT share link]. Nothing to install.
  - **Anything else.** Paste the *NX Menu Import AI Instruction Pack* into the chat before the menu — [LINK: instruction pack]. If your assistant can open links, pasting the pack's URL and asking it to read that first usually works.

If you have no preference, use Claude with the skill. It needs no setup after the first install and handles long menus without prompting.

## The workflow

### 1. Give it the menu

Attach the PDF or photos, or paste the text, and ask it to build an NX menu import file. If you are using the instruction pack rather than the skill or the GPT, paste the pack first.

For a website, paste the page text or screenshots unless you know your assistant can open links. Many cannot, and some will produce a plausible menu from the restaurant's name rather than admit it never read the page.

### 2. Answer the checkpoint

The assistant will come back with an outline rather than a file — the sections it found, the modifier groups it inferred, the items under each, and a list of questions. **This is the step that makes the whole thing work.** Read it against the actual menu.

What to look for:

- **Section and group names.** These create configuration in NX. If a name doesn't match what's already in the venue, NX creates a new record instead of linking to the existing one — no error, just a duplicate to clean up later. This is where you supply your exact portal names.
- **Min / Max / Free on every modifier group.** A menu that says "choice of two sides" should produce Min 2, Max 2. A group with no stated limit should be Max 0, which means unlimited.
- **Low-confidence reads.** If you gave it photos, it will list prices and names it wasn't sure it read correctly. Check every one.
- **Anything missing.** Whole sections get skipped, especially on multi-column menus and anything in a decorative font.

Correct what's wrong, answer the questions, and tell it to build the file.

### 3. Read the self-check

Before handing over the CSV, the assistant runs a self-check and prints the results — field counts, required fields, modifier references that point at nothing, near-duplicate names, price formatting, and an item count compared against what you confirmed in step 2.

Two things to actually read:

- **Any FAIL.** Send it back rather than fixing by hand; the same mistake is usually in several rows.
- **The list of names the import will create.** This is your last chance to catch `Sales Tax` where the venue has `Sales Tax Group`. Compare it against the portal before you upload.

It will also list every item missing a price or a routing group. Those import without error and are invisible until something rings up at zero or a ticket prints nowhere.

### 4. Import

Go to **Configuration > Import**, set Type to **NX Menu Item CSV**, choose the file, and select Import. Check the import history for the status and job ID.

### 5. Save the file

**Keep the CSV.** It is the master copy of that venue's menu.

The importer matches rows by POS Name, so importing the file again updates the matching items rather than duplicating them. Corrections are easy: fix the row, import again.

Blank cells are ignored on re-import, so anything you configure in the portal afterward — cook times, KDS behavior, prompts, priority — is safe no matter how many times the file is imported. The import file deliberately leaves those columns empty for exactly this reason.

What a re-import does replace is any field the file fills. If someone changes a price in the portal and you later import an older copy of the file, that price reverts with no warning. Store the file where the venue's team can find it, and when a price or name changes, change it in the file too.

## What to check in the portal afterward

The import creates items and links them to configuration. It does not set up everything a venue needs. After importing:

- Confirm items landed in the right Menu Categories and that modifier groups are attached where expected.
- Set the operational fields the import intentionally leaves blank: cook times, KDS summary behavior, quantity prompts, print behavior, priority.
- Configure prep modifiers (No Onions, Extra Sauce, Dressing on the Side). These are a separate system in NX and are not part of this import.
- Ring up a few items on a terminal — especially one with a required modifier group and one with a paid add-on — and confirm the prices and routing are right before handing the venue over.

## What AI cannot do here

Some things can't be expressed in the import file at all. A good assistant will flag these rather than fake them, but know them going in:

- Size-dependent modifier pricing (a topping that costs more on a large)
- Half-and-half items
- Time-of-day or happy-hour pricing
- Combo and bundle discounts
- Items sold by weight
- Items reporting to more than one sales category

Import the base items, then configure these in the portal.

## When it goes wrong

**The import failed outright.** Almost always the header row. Do not let an assistant rename, reorder, or drop a column, and do not edit the header yourself.

**Duplicate categories appeared.** A name didn't match the portal exactly — capitalization, a plural, `&` versus `and`, a trailing space. Merge them in the portal and correct the file so the next import doesn't recreate them.

**A menu section became a modifier category.** In NX, a category becomes a modifier category by being referenced as one. If a modifier group was given the same name as a menu section, the section gets flagged. Rename the modifier group in the file and re-import.

**Items are missing.** Compare the item count in the self-check against the menu. Long or multi-column menus are where assistants silently drop sections.

**Prices are wrong in a pattern.** Usually a misread column on a photographed menu. Cheaper to fix in the file and re-import than row by row in the portal.

---

## Keeping up to date

The instruction pack is versioned. If you installed the Claude skill or saved a copy of the pack some time ago, check [LINK: GitHub repository] for a newer release before a big install — the file format and the guidance both change as the importer does.

You can ask any of the three assistants which version it is working from, and it will tell you.

---

*Questions about a specific import: contact your NX Support Partner with the Job ID from the import history.*
