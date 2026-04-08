# Clean Architecture Skill

**Focus**: Scalability and Domain-Driven Design (Feature-First) enforcement.

## Rules
1. **Directory Structure**:
   - `lib/core/`: Utilities, themes, constants, formatters. NO dependencies on `lib/features/`.
   - `lib/features/`: Isolated feature domains (e.g., `discount_calculator/`, `sales_history/`).
2. **Feature Isolation**: Each feature must contain its own `screens/`, `providers/` (or `blocs/`), `widgets/`, and `models/`. Do not cross-import UI components from one feature to another unless it's a shared core widget.
3. **Naming Conventions**:
   - Classes/Enums: `UpperCamelCase` (e.g., `SalesPriceProvider`)
   - Files/Folders: `snake_case` (e.g., `sales_price_provider.dart`)
   - Variables/Methods: `lowerCamelCase`
   - Private Members: Prefix with `_`.
