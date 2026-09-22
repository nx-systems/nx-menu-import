# Notice

This repository is released under [CC0 1.0](LICENSE) — a public domain dedication. There are no copyright conditions on using, adapting, or redistributing this material.

Two things a copyright waiver does not address.

## Trademarks

CC0 waives copyright. It does not grant rights in the **NX** or **NX Restaurant** names, logos, or trade dress, and it says so explicitly.

You may state factually that your work is based on, compatible with, or built for NX Restaurant. You may not use the NX name or logo as the name or branding of your own product, or in any way that implies your version is official, endorsed, or supported by NX Restaurant.

If you publish a modified version of this material, please say clearly that it is modified and not the official version, so that dealers can tell the difference.

## No warranty, and what that means here

This material is provided "as is", without warranty of any kind. In no event shall NX Restaurant be liable for any claim, damages, or other liability arising from or in connection with this material or its use.

Stated plainly, because this one has real-world consequences: this repository describes how to generate a file that changes a live restaurant's point-of-sale configuration. AI-generated output can be wrong in ways that look correct — invented prices, dropped menu sections, misread items. The workflow builds in a confirmation step and a self-check for exactly that reason.

**Review every generated file before importing it, and verify the result in the portal afterward.** Responsibility for what is imported into a venue rests with whoever imports it.

## Adapting this for another platform

If you adapt this pack for a different POS, please change the NX-specific parts rather than leaving them in place. The column names, the modifier-category behavior, the `Max 0` convention, and the re-import semantics are specific to NX Restaurant and will not be correct elsewhere. A pack that names another platform but carries NX's rules produces broken imports and support tickets for both of us.
