---
name: nx-menu-import
description: Convert a restaurant menu (PDF, photos, web page, or typed text) into an NX Restaurant menu item import CSV, with categories, modifier groups, and min/max/free settings. Use when the user mentions an NX menu import, an NX Menu Item CSV, building a menu import file for a venue, or converting a menu into NX POS.
---

# NX Menu Import

You are converting a restaurant menu into an NX Restaurant menu import CSV. Follow this document exactly. Do not improvise columns, values, or structure.

Before building the CSV, read `references/edge-cases.md` — it covers the situations that come up in almost every real menu (an option in two groups, an item in two sections, included choices with upcharges, market price, and what cannot be expressed in this file at all).

You are converting a restaurant menu into an NX Restaurant menu import CSV. Follow this document exactly. Do not improvise columns, values, or structure.

## 0. What you are producing

A single CSV file: the header row exactly as given in Section 3, then one row per record. Comma-delimited, UTF-8, values containing commas wrapped in double quotes.

Two kinds of rows go in the same file:

- **Item rows** — things a guest orders (Cheeseburger, Grey Goose, Caesar Salad).
- **Modifier option rows** — choices attached to items (Rare, Add Bacon, On the Rocks, Ranch).

They use the same columns. A modifier option is just a menu item that gets referenced by another item.

**The published template ships with example rows in it** (Grey Goose, Titos, Belvedere, Bar Mods, Rocks, Salt, twist). Those are illustrations, not data. Delete every one of them. Your output contains the header row and the venue's own records, nothing else.

## 1. The NX data model — seven rules

**Rule 1 — Categories and groups are created by being named.**
NX matches `Menu Category`, `Sales Category`, `Routing Group`, and `Tax Group` values against records that already exist in the venue — exact spelling, exact capitalization. If a name matches, the item links to it. If it does not match, **NX creates a new one**. A typo does not fail the import; it silently creates a duplicate config object someone has to clean up by hand. Name discipline (Section 4) is the single most important thing you will do.

**Rule 2 — Modifiers are rows, not columns.**
Every individual choice ("Medium Rare", "Add Avocado") needs its own row, with a `Menu Category` that groups it (e.g. `Meat Temps`, `Burger Add-Ons`).

**Rule 3 — A category becomes a modifier category by being used as one.**
When you put a category name into a `Modifier Category N` column on some other item's row, NX marks that category as a modifier category. You do not declare it anywhere else. This means: **never use the same category name for both a menu section and a modifier group.** If `Sides` is a menu section guests order from *and* the name of a modifier group on entrées, NX will flag your menu section as a modifier category. Name the modifier group `Entree Side Choice` instead.

**Rule 4 — Modifier groups attach in numbered blocks of four.**
Each modifier group on an item uses four columns: `Modifier Category N`, `Modifier Category N Min`, `Modifier Category N Max`, `Modifier Category N Free`. Use blocks 1, 2, 3… in order with no gaps. The pattern extends as far as you need — add further blocks by continuing the same naming, up to 99.

- `Min` — how many choices the server must pick (`0` = optional, `1` = required).
- `Max` — the most they may pick. **`0` means unlimited.** Use `0` whenever the menu doesn't state a cap ("add any of the following").
- `Free` — how many are included at no charge before the modifier's price applies (`0` = all are charged).

**Rule 5 — Two price columns, different jobs.**
`Default Menu Item Price` is what the item costs when ordered on its own. `Default Modifier Price` is the upcharge when the item is used as a modifier on something else. A modifier option that adds nothing to the price gets `0`. A row can have both if it is sold standalone *and* used as a modifier.

**Rule 6 — Six fields are required. Everything else is safe to leave blank.**

Required on every row — the import expects these:

`Menu Category` · `Sales Category` · `POS Name` · `Guest Name` · `Chit Name` · `Tax Group`

Not required, but the import will go through with a gap that someone has to notice later. Fill them when you can, and **list any you left blank in your handoff** so the dealer verifies them in the portal:

`Default Menu Item Price` · `Default Modifier Price` · `Routing Group`

Blank is not neutral for these. An item with no price rings at zero. An item with no `Routing Group` prints to no kitchen or bar station at all.

Every other column is genuinely optional. Blank means "use the NX default," which is a correct value. A guessed value is not. Leave optional columns blank unless the menu or the dealer explicitly told you what goes there.

**Rule 7 — `POS Name` is the matching key, and the file overwrites what it matches.**
The importer matches rows against existing records by `POS Name`. A re-import does not create duplicates — it lands on the same records and **updates them to whatever the file says**. The file wins.

Two consequences, and the dealer needs both:

*Correcting is easy.* Wrong price, wrong routing group, misspelled guest name — fix the row, import the same file again, done.

*A stale file is destructive — but only where it carries a value.* A blank cell is ignored on re-import: it leaves whatever is already on the record alone. So the operational settings a dealer configures in the portal after importing (cook times, KDS behavior, prompts, priority) survive every later import, because this file leaves those columns empty by design.

What a re-import does overwrite is any field the file actually fills. If someone changes a price in the portal and the file still holds the old price, re-importing reverts it without warning. So the generated CSV is the venue's master copy for the fields it carries: keep it, and when one of those fields changes, change it in the file too. Never import an older copy over a newer one.

**`POS Name` must therefore be unique across the entire file**, not just within a category. Two rows sharing a `POS Name` are one record to the importer, and the second overwrites the first. Where two different things would naturally share a name, make the names distinct (see `references/edge-cases.md`).

## 2. Procedure — two passes, with a mandatory stop in between

### Pass 1 — Extract and confirm (no CSV yet)

Read the menu and produce a plain-language outline for the dealer to check. Do not write any CSV in this pass.

Output, in this order:

1. **Menu sections found** — the list of `Menu Category` names you will use for items.
2. **Modifier groups found** — each group name, its options, and the Min/Max/Free you propose, plus a one-line reason ("menu says 'choose two sides'").
3. **Items** — grouped by section, with price and which modifier groups attach to each.
4. **Open questions** — anything the menu did not tell you. Always include these unless the dealer already answered them:
   - What `Sales Category` should each menu section report to? *(Required.)* Propose a mapping (e.g. `Food`, `Liquor`, `Beer`, `Wine`, `N/A Bev`) and ask them to confirm it or replace it with the venue's existing names.
   - What `Tax Group` applies? *(Required. Ask for the exact name as it appears in the portal.)*
   - What `Routing Group` should each section print to? (Kitchen, Bar, Expo, Fry…)
   - Do categories already in this venue use different names than the menu's headings?
   - Any modifier group where the menu does not state how many choices are allowed (you will propose `Max 0` = unlimited).
   - If there are paid modifiers: should they report under the parent items' Sales Category, or under their own?
5. **Assumptions** — every place you filled a gap, listed explicitly.
6. **Low-confidence reads** — when the source is a photo or scanned PDF, list every price or name you are not certain you read correctly. Never silently pick one.

Then stop and ask the dealer to confirm or correct. **Do not proceed to Pass 2 until they reply.**

### Pass 2 — Build the CSV

Apply their corrections, then emit the file in this row order:

1. All modifier option rows, grouped by their modifier category.
2. All item rows, grouped by menu section.

(Order does not affect the import. It makes the file reviewable by a human, which is the point.)

Then run the self-check in Section 6 and print its results **before** presenting the file.

**Delivering the file.** Produce a downloadable `.csv` if your tool can create files. Otherwise put the entire CSV in one plain code block. Either way: **every row, in full, always.** Never write "remaining rows follow the same pattern," never use "etc.", never summarize a section instead of listing it. A dealer will import exactly what you hand them.

If the menu is large (roughly 150 rows or more), split the output into multiple files by menu section rather than one enormous block. Each file gets the full header row. Put all modifier option rows in the first file, and number the files in the order they should be imported.

## 3. Column contract

Header row, in this exact order and spelling. Do not rename, reorder, or remove headers — the import maps on these strings and renaming one will fail the file. Columns 47 onward repeat the four-column modifier block; add more blocks by continuing the pattern.

```
Menu Category,Sales Category,POS Name,Guest Name,Chit Name,Integration ID,Barcode,Tags,Default Menu Item Price,Default Modifier Price,Type,Meal Stage,Routing Group,Priority,Cook Time,Follow Parent,Redirect Parent,Display Price,Include in KDS Summary,Tax Group,Print on Guest Check,Include in Item Price,Prompt Keyboard,Prompt Quantity,Description,Cost,Prep Instructions,Serving Size,Calories,Total Fat,Saturated Fat,Trans Fat,Cholesterol,Sodium,Total Carbohydrate,Dietary Fiber,Total Sugars,Protein,Bevs Req,Bevs Satisfied,Default Qty,Guest Count,Modifier Weight,Reset OOS at Close Day,Out of Stock,On Hand,Modifier Category 1,Modifier Category 1 Min,Modifier Category 1 Max,Modifier Category 1 Free,Modifier Category 2,Modifier Category 2 Min,Modifier Category 2 Max,Modifier Category 2 Free
```

### Required — every row

| Column | Item row | Modifier option row |
|---|---|---|
| `Menu Category` | The section the item appears in on the POS | The modifier group's name |
| `Sales Category` | Reporting bucket (ask the dealer) | Usually the same bucket as the items it attaches to. Using the modifier group's own name here is also valid if the dealer wants modifier revenue reported separately — ask in Pass 1 if paid modifiers are involved. |
| `POS Name` | Server button label — short and unambiguous on a busy line | Option name, short |
| `Guest Name` | Full customer-facing name for receipts, kiosk, online ordering | Full option name as a guest would read it |
| `Chit Name` | Short kitchen-ticket name a cook can read at a glance | Short kitchen-ticket name |
| `Tax Group` | Exact portal name (ask the dealer) | Exact portal name |

If `POS Name`, `Guest Name`, and `Chit Name` would all be the same short string, use that string in all three. Do not leave the duplicates blank.

### Strongly recommended — flag if left blank

| Column | Use |
|---|---|
| `Default Menu Item Price` | Menu price, plain decimal |
| `Default Modifier Price` | Upcharge when used as a modifier, or `0` |
| `Routing Group` | Where it prints — `Kitchen`, `Bar`, `Expo`, `Fry`. Ask the dealer; don't guess. |

### Optional — fill only when the menu tells you

| Column | Valid values |
|---|---|
| `Type` | Reporting/receipt classification: `Food`, `Alcohol`, `Non Alcohol beverage`, `Retail`, `Other`. Set it when the menu section makes it unambiguous (a `Vodka` section is `Alcohol`, `Soft Drinks` is `Non Alcohol beverage`, `Burgers` is `Food`); otherwise leave blank. |
| `Meal Stage` | `None`, `Beverage`, `Appetizer`, `Entree`, `Dessert` |
| `Description` | The menu's own description text, verbatim |
| `Modifier Category N` + `Min`/`Max`/`Free` | Per Rule 4 |
| Nutrition columns (`Calories` through `Protein`) | Only if printed on the menu. Never estimate. |

Note: `Type` is a reporting and receipt label, not a structural flag. **There is no `Modifier` value for `Type`.** What makes something a modifier is being referenced in a `Modifier Category N` column (Rule 3), nothing else.

### Leave blank

`Integration ID`, `Barcode`, `Tags`, `Priority`, `Cook Time`, `Follow Parent`, `Redirect Parent`, `Display Price`, `Include in KDS Summary`, `Print on Guest Check`, `Include in Item Price`, `Prompt Keyboard`, `Prompt Quantity`, `Cost`, `Prep Instructions`, `Serving Size`, `Bevs Req`, `Bevs Satisfied`, `Default Qty`, `Guest Count`, `Modifier Weight`, `Reset OOS at Close Day`, `Out of Stock`, `On Hand`.

These are venue-specific operational settings. A menu cannot tell you what belongs in them, and a wrong value here causes behavior nobody will trace back to the import. The dealer sets them in the portal after import.

### Value formatting

- Prices: plain decimals, no currency symbol, no thousands separator — `12.95`, not `$12.95`.
- Min / Max / Free: whole numbers.
- Behavior flags accept `Y` / `N` / `true` / `false` / `yes` / `no` — but leave them blank per the list above.
- No `N/A`, `-`, `TBD`, `?`, or `null`. Blank means blank.
- Straight quotes and apostrophes only (`'` and `"`), never curly ones copied from a PDF. A value that contains a comma or a double quote is wrapped in double quotes, and a double quote inside it is doubled: `"12"" Pizza, Large"`.
- Category, group, tax group, and routing group names: plain ASCII letters — `Entree`, not `Entrée`. Accented characters are fine in `Guest Name` and `Description`, where they are display text, not a lookup key.
- One row per record. Never put multiple items on one row.
- If a menu lists size variants at different prices (Small $6 / Large $9), make them **separate item rows** (`Caesar Sm`, `Caesar Lg`) unless the dealer says to use a size modifier group instead.

## 4. Naming rules

These exist because a mismatched name creates a duplicate config object instead of failing.

1. **Ask before inventing.** Before Pass 2, ask the dealer for the venue's existing Sales Category, Tax Group, and Routing Group names. Use those strings exactly — including capitalization and spacing.
2. **One spelling, everywhere.** Pick one form of each name and reuse the identical string in every row and every `Modifier Category N` cell. `Bar Mods` and `Bar Mod` are two different categories to NX.
3. **No trailing or double spaces.** Strip them.
4. **No ampersands or slashes where a word will do** — `Soups and Salads`, not `Soups & Salads` / `Soups/Salads`. Punctuation variants are the most common source of accidental duplicates.
5. **Modifier group names must not collide with menu section names.** See Rule 3.
6. **Every `POS Name` in the file is unique.** It is the import's matching key (Rule 7). Two rows sharing one name collapse into one record.

## 5. Worked example

Menu source:

> **VODKA** — Grey Goose 14 · Tito's 11 · Belvedere 13
> *Served neat, on the rocks, with a twist, or salted rim*
>
> **BURGERS** — Classic Cheeseburger 16
> *Choice of temperature. Add bacon 3, add avocado 2.*

Dealer confirmed: Sales Categories `Liquor` and `Food`; Tax Group `Sales Tax Group`; Routing Groups `Bar` and `Kitchen`.

One modifier option row in full — every column not listed is blank:

```
Menu Category:            Bar Mods
Sales Category:           Liquor
POS Name:                 Rocks
Guest Name:               On the Rocks
Chit Name:                Rocks
Tax Group:                Sales Tax Group
Default Modifier Price:   0
```

One item row in full:

```
Menu Category:            Burgers
Sales Category:           Food
POS Name:                 Cheeseburger
Guest Name:               Classic Cheeseburger
Chit Name:                Cheesebrgr
Tax Group:                Sales Tax Group
Default Menu Item Price:  16.00
Routing Group:            Kitchen
Type:                     Food
Meal Stage:               Entree
Modifier Category 1:      Meat Temps
Modifier Category 1 Min:  1
Modifier Category 1 Max:  1
Modifier Category 1 Free: 0
Modifier Category 2:      Burger Add-Ons
Modifier Category 2 Min:  0
Modifier Category 2 Max:  0
Modifier Category 2 Free: 0
```

The full file, abbreviated to the columns that vary (`Tax Group` = `Sales Tax Group` on every row):

| Menu Category | Sales Cat | POS Name | Guest Name | Chit Name | Item Price | Mod Price | Routing | Mod Cat 1 | Min | Max | Free | Mod Cat 2 | Min | Max | Free |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Bar Mods | Liquor | Rocks | On the Rocks | Rocks | | 0 | | | | | | | | | |
| Bar Mods | Liquor | Twist | With a Twist | Twist | | 0 | | | | | | | | | |
| Bar Mods | Liquor | Salt Rim | Salted Rim | Salt Rim | | 0 | | | | | | | | | |
| Meat Temps | Food | Rare | Rare | Rare | | 0 | | | | | | | | | |
| Meat Temps | Food | Med Rare | Medium Rare | Med Rare | | 0 | | | | | | | | | |
| Meat Temps | Food | Medium | Medium | Medium | | 0 | | | | | | | | | |
| Meat Temps | Food | Well Done | Well Done | Well | | 0 | | | | | | | | | |
| Burger Add-Ons | Food | Add Bacon | Add Bacon | Bacon | | 3.00 | | | | | | | | | |
| Burger Add-Ons | Food | Add Avocado | Add Avocado | Avocado | | 2.00 | | | | | | | | | |
| Vodka | Liquor | Grey Goose | Grey Goose | Grey Goose | 14.00 | | Bar | Bar Mods | 0 | 0 | 0 | | | | |
| Vodka | Liquor | Titos | Tito's | Titos | 11.00 | | Bar | Bar Mods | 0 | 0 | 0 | | | | |
| Vodka | Liquor | Belvedere | Belvedere | Belvedere | 13.00 | | Bar | Bar Mods | 0 | 0 | 0 | | | | |
| Burgers | Food | Cheeseburger | Classic Cheeseburger | Cheesebrgr | 16.00 | | Kitchen | Meat Temps | 1 | 1 | 0 | Burger Add-Ons | 0 | 0 | 0 |

Read it back: `Bar Mods`, `Meat Temps`, and `Burger Add-Ons` each have their option rows, and each gets referenced in a `Modifier Category N` column — which is what tells NX they are modifier categories. `Vodka` and `Burgers` are never referenced that way, so they stay ordinary menu sections. Temperature is `Min 1 / Max 1` because the menu requires exactly one choice. Add-ons and bar mods are `Min 0 / Max 0`: optional, and the menu states no cap, so unlimited.

## 6. Self-check — run this and print the results before handing over the file

Report each line as PASS or a specific FAIL with the offending row numbers.

1. Header row matches Section 3 exactly — spelling and order identical, nothing renamed or dropped.
2. Every row has the same field count as the header (count the commas, including trailing empties).
3. None of the template's example rows survive (no Grey Goose, Titos, Belvedere, Bar Mods, Rocks, Salt, or twist unless they are genuinely on this venue's menu).
4. Every row has all six required fields: `Menu Category`, `Sales Category`, `POS Name`, `Guest Name`, `Chit Name`, `Tax Group`.
5. Every value appearing in any `Modifier Category N` column also exists as a `Menu Category` on at least one row in the file. *(A reference with no option rows = a modifier group with no choices in it.)*
6. No `Menu Category` value is used both as a menu section for orderable items and as a `Modifier Category N` value.
7. Menu category, sales category, tax group, and routing group names: no near-duplicates differing only by case, punctuation, spacing, or plural. List any pair you find.
8. `Type` values are only `Food`, `Alcohol`, `Non Alcohol beverage`, `Retail`, `Other`, or blank. `Meal Stage` values are only `None`, `Beverage`, `Appetizer`, `Entree`, `Dessert`, or blank.
9. No prices contain `$`, commas, or text. No cell contains `N/A`, `TBD`, `-`, or `null`.
10. Modifier blocks are used in order with no gaps (no row uses block 2 while block 1 is empty).
11. For every modifier block used: `Max` is `0` (unlimited) or ≥ `Min`; `Free` is `0` or ≤ `Max` when `Max` is not `0`.
12. **Every `POS Name` in the file is unique** — no repeats anywhere, in any category. This is the import's matching key; duplicates silently collapse into one record. Flag any `POS Name` longer than 20 characters for the dealer to shorten.
13. Item count in the CSV equals the item count the dealer confirmed in Pass 1. State both numbers.
14. No row was elided, summarized, or replaced with a placeholder. The file is complete.
15. No curly quotes or apostrophes anywhere in the file.

Then print, in plain language:

- Total item rows, total modifier option rows, total categories that will be created.
- A list of every category, tax group, and routing group name the import will create, so the dealer can eyeball it against the venue's existing config before importing.
- **Every row missing a `Default Menu Item Price`, `Default Modifier Price`, or `Routing Group`** — these import fine but need verifying in the portal.
- Every assumption you made that the dealer did not explicitly confirm.
- A short handling note for the dealer, in these words or close to them: *"Save this file — it is the master copy of this menu. Importing it again updates the matching items rather than duplicating them, so corrections are easy: fix the row and re-import. Blank cells are ignored, so anything configured in the portal afterward is safe. But any field this file does fill will be overwritten on re-import — so if a price changes in the portal, change it here too, and never import an older copy over newer changes."*

## 7. Do not

- Do not leave the template's example rows in the file.
- Do not invent prices, calories, allergens, or descriptions not in the source menu.
- Do not add columns, rename columns, reorder columns, or add a second header row.
- Do not add explanatory rows, blank separator rows, notes, or comment rows to the CSV.
- Do not reuse a `POS Name` anywhere in the file.
- Do not present the file without telling the dealer to keep it as the master copy (Rule 7).
- Do not use `Modifier` as a `Type` value — it is not one.
- Do not fill the "Leave blank" columns with defaults you think are sensible.
- Do not skip the Pass 1 checkpoint, even if the menu looks simple.
- Do not present the CSV without the Section 6 self-check results.
- Do not elide, abbreviate, or summarize rows. If it is too long for one message, split by section per Pass 2 — never shorten.
