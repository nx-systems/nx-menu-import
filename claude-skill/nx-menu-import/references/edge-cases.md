# Edge cases

Handle these the same way every time.

**The same option belongs in more than one group** (Ranch is a salad dressing *and* a wing sauce). A row has one `Menu Category`, so it needs one row per group — but the two rows cannot both be called `Ranch`, because `POS Name` is the matching key (see SKILL.md, Rule 7) and they would collapse into one record. Give them distinct names: `Ranch Dressing` under `Salad Dressings`, `Ranch Sauce` under `Wing Sauces`. Use `Guest Name` to show the guest the same word on both (`Ranch`).

**The same item appears in more than one menu section** (Caesar Salad under Lunch at 11 and under Dinner at 14). Two rows are needed, and they must have distinct `POS Name`s — `Caesar Lunch` and `Caesar Dinner`, with `Guest Name` `Caesar Salad` on both. List the pair in your handoff: the dealer may prefer one item with a price level instead of two records.

**A modifier that has its own modifiers** (a combo's side choice includes Side Salad, which needs a dressing choice). Modifier option rows use the same columns as items, so the `Side Salad` row gets its own `Modifier Category 1 = Salad Dressings` block. Nesting is allowed; just make sure every referenced group has option rows.

**An included choice with premium upcharges** ("served with your choice of side; substitute sweet potato fries +2"). Build one modifier group with `Min 1`, `Max 1`, `Free 0`. Standard options get `Default Modifier Price` `0`; premium options get their upcharge. Do not use `Free` to model this.

**When to use `Free`.** Only for the "first N are free, then each costs X" pattern — pizza toppings, wing sauces at 0.75 each after the first two. Every option in that group carries the per-unit price, and `Free` carries N. If the menu doesn't describe that pattern, `Free` is `0`.

**Prep instructions** (No Onions, Extra Sauce, Light Ice, Dressing on the Side). Do not create rows for these. NX has a separate prep-modifier system that is configured in the portal, not through this import. The only time a prep word belongs in the file is when it is part of an item's actual name on the menu ("Extra Crispy Wings" is an item; "extra crispy" as an option is not).

**Market price, price ranges, "ask your server."** Leave `Default Menu Item Price` blank and list the item in the verify-if-blank handoff. Never pick a number.

**Included items with no choice** ("served with fries"). Nothing to build — fries are part of the item. Mention it in `Description` if the menu does, and move on.

**Out of scope for import — flag, do not fake.** Size-dependent modifier pricing (toppings that cost more on a large), half-and-half items, time-of-day or happy-hour pricing, bundle or combo discounts, items sold by weight, items reporting to more than one sales category. Import the base item; list what the dealer needs to configure by hand.
