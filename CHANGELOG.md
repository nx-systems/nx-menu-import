# Changelog

## 2.0
- Confirmed: a blank cell is ignored on re-import and leaves the existing value alone. Portal-configured operational settings survive later imports, which is what makes the leave-it-blank discipline safe.
- Rule 7 rewritten: re-import matches on `POS Name` and overwrites only the fields the file carries.

## 1.9
- Re-import overwrites matched records with the file's values. Added the master-copy handling note.

## 1.8
- `POS Name` is the import's matching key. It must be unique across the whole file; re-importing does not duplicate.

## 1.7
- `Max 0` means unlimited.
- Prep modifiers are configured in the portal, not imported.
- `Sales Category` on modifier rows may follow the parent items or the modifier group — Pass 1 asks when paid modifiers are involved.

## 1.6
- Added the edge-case section and the no-truncation output rules.

## 1.5
- `Category` column removed from the template; removed from the pack.

## 1.3–1.4
- `Menu Category` added as required. `Category` suppressed, then dropped.

## 1.2
- Six required fields established: `Menu Category`, `Sales Category`, `POS Name`, `Guest Name`, `Chit Name`, `Tax Group`.
- Corrected `Type`: a reporting label (`Food`, `Alcohol`, `Non Alcohol beverage`, `Retail`, `Other`). There is no `Modifier` value.
- Instruction added to delete the template's example rows.

## 1.0–1.1
- Initial pack. Documented the modifier-category model, name-matching behavior, and the two-pass procedure.
