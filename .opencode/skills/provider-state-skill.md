# Provider State & Persistence Skill

**Focus**: Performance, UI junk prevention, and zero-loss state persistence.

## Rules
1. **Rebuild Optimization**: NEVER use `context.watch()` or `Provider.of(context)` at the root `build` method of a large screen unless necessary. Use `Consumer<T>` to wrap *only* the specific widgets that need to react to state changes.
2. **Event Dispatching**: Use `context.read<T>()` strictly for dispatching events from buttons (e.g., `onPressed: () => context.read<Provider>().calculate()`).
3. **No `setState` for Logic**: Business logic, math variables, and view state must be managed inside the `ChangeNotifier`. Avoid `setState` in StatefulWidgets unless dealing with strictly UI-only ephemeral state (like an animation controller).
4. **Persistence (`shared_preferences`)**: 
   - State that the user inputs (e.g., text field values, toggle switches) should be immediately saved to `SharedPreferences` within the Provider.
   - On screen re-entry (in `initState`), read these values from the Provider to restore the UI seamlessly.
