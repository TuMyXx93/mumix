# Design System Skill

**Focus**: Keep UI consistent, modern, and low-maintenance by centralizing visual decisions.

## Rules
1. **Theme First**: Never hardcode colors, radii, text sizes, shadows, or spacing in feature screens if a theme/token can be used. Prefer `Theme.of(context).colorScheme`, `textTheme`, and shared constants.
2. **Single Source of Visual Truth**: Global component styling must live in core theme files (for example `lib/core/themes/*`) and be reused by all features.
3. **Component Reuse**: If the same visual pattern appears in 2+ places, extract a shared widget in `lib/core/widgets/`.
4. **Responsive by Default**: Support phone and tablet widths without branching into separate screens unless required. Prefer adaptive layouts and constraints.
5. **Preserve Visual Baselines**: If the task is feature-only (logic, provider, persistence, integration), do not alter existing layout structure, card heights, margins, paddings, or typography scale unless the user explicitly asks for UI changes.
6. **Scope Lock Before UI Edits**: Before changing UI files, state the intended visual scope in one sentence (for example: "no spacing changes, only behavior changes") and keep edits inside that scope.
7. **Dimension Stability**: For production dashboard/list cards, prefer stable constraints (`mainAxisExtent`, fixed min/max heights, or shared tokens) over fragile width-derived ratios when compact height must be preserved.
8. **Accessible Contrast**: Ensure readable contrast in both light and dark themes. Avoid low-contrast text/icon combinations.
9. **Motion with Purpose**: Keep animations short and meaningful. Avoid global animation side effects that impact unrelated widgets.
10. **No Business Logic in UI**: UI widgets render and dispatch events only; state and calculations remain in providers.
11. **Forms Consistency**: Inputs, labels, helper/error states, and buttons should use a consistent style from the theme.

## Checklist Before Finishing UI Work
- Uses theme tokens instead of hardcoded visual values.
- Repeated visual patterns extracted to shared widgets.
- Light and dark modes both verified.
- Layout verified for small and medium widths.
- No visual deltas outside requested scope.
- Critical dimensions covered by widget/golden regression tests.
- `flutter analyze` and relevant widget/feature tests pass.
