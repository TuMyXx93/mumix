# Verify Math Command

**Alias**: `/verify-math`

**Action**: 
When the user invokes this command, the AI should:
1. Run `flutter analyze`
2. Run `flutter test test/features/`
3. Check the output to ensure 100% of the mathematical provider tests pass.
4. Report the summary back to the user concisely.
