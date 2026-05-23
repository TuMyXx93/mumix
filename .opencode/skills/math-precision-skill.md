# Math Precision Skill

**Focus**: Strict number formatting, floating-point error prevention, and robust parsing.

## Rules
1. **Safe Parsing**: ALWAYS use `double.tryParse(value)` when reading from user inputs. NEVER use `double.parse()` directly to prevent `FormatException` crashes.
2. **Floating-Point Handling**: Standard `double` arithmetic can yield `0.30000000000000004`. Before displaying to the user, ensure values are formatted cleanly (e.g., `toStringAsFixed(2)` or using the `intl` package's `NumberFormat`).
3. **Advanced Formulas**: 
   - *Markup*: `Cost + (Cost * % / 100)`
   - *Gross Margin*: `Cost / (1 - (% / 100))`
   - *Cascading Discounts*: Apply percentages sequentially to the *current/subtotal* price, not additively to the original price.
4. **Validation Rules**: Prevent negative numbers for prices/costs. Prevent margins or percentage discounts >= 100% when mathematically invalid.
