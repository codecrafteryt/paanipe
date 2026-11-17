# Flutter Engineering Rules

## Core Principles

1. Write clean, production-ready, senior-level Flutter code.
2. Code must be relevant, concise, readable, and maintainable.
3. Prefer the simplest correct implementation.
4. Do not write unnecessary, verbose, or redundant code.
5. If a feature can be implemented correctly in 20 lines, do not turn it into 40–50 lines without a strong technical reason.
6. Every line of code should have a purpose.
7. Avoid over-engineering and premature abstraction.

## ALWAYS Inspect Existing Code First

Before writing or modifying code:

1. Search the existing codebase for related:
   - Controllers
   - Models
   - Services
   - Repositories
   - API methods
   - Widgets
   - Helpers
   - Extensions
   - Validators
   - Constants
   - Utilities
2. Understand the existing architecture and coding patterns.
3. Reuse existing implementations whenever possible.
4. Modify the existing file/function instead of creating a duplicate implementation.
5. NEVER create a new helper/service/widget/model if an equivalent implementation already exists.
6. Do not duplicate business logic across multiple files.

## Reusability

1. Write reusable code where reuse is actually needed.
2. Prefer existing reusable components over creating new ones.
3. Extract a helper/function only when:
   - Logic is repeated
   - The function has a clear responsibility
   - Extraction improves readability or maintainability
4. Do not create abstractions for one-time trivial operations.
5. Avoid unnecessary generic classes, wrappers, factories, or layers.

## Code Size

1. Keep files preferably within 100–120 lines.
2. If a file becomes significantly larger than 120 lines:
   - First check whether existing logic can be simplified.
   - Remove duplication.
   - Reuse existing utilities.
   - Split only meaningful responsibilities into logical files.
3. Do NOT split code just to artificially satisfy the line limit.
4. Large files should be treated as a signal to review architecture.

## Functions

1. Keep functions short and focused.
2. Prefer one responsibility per function.
3. Avoid deeply nested conditions.
4. Avoid large switch statements when a clean reusable mapping/configuration is better.
5. Do not repeat the same condition or transformation multiple times.
6. Use early returns where they improve readability.
7. Avoid unnecessary temporary variables.

## GetX / State Management

1. Follow the existing GetX architecture.
2. Reuse existing controllers where appropriate.
3. Do not introduce another state-management solution unless explicitly requested.
4. Keep UI state, business logic, and API logic separated.
5. Controllers should not contain excessive UI-building logic.
6. Avoid unnecessary Obx/GetBuilder nesting.
7. Do not create reactive variables when normal variables are sufficient.

## Models / JSON

1. Models must safely parse API responses.
2. Never assume backend numeric types are always identical.
3. Handle int/double/string numeric variations safely where the API contract allows them.
4. Handle nullable fields explicitly.
5. Avoid unsafe casts such as:
   `json['price'] as double`
   when backend may return an integer.
6. Prefer concise safe parsing.
7. Keep `fromJson` / `toJson` readable and consistent.
8. Do not silently hide malformed API data unless that behavior is intentional.

## API / Networking

1. Reuse existing API clients/services.
2. Do not create duplicate API methods.
3. Keep request construction separate from UI code.
4. Match backend field names exactly.
5. Do not rename API keys casually.
6. Verify actual request/wire types before changing parsing logic.
7. Handle loading, success, empty, and error states.
8. Do not swallow exceptions silently.

## UI

1. Reuse existing widgets/components.
2. Follow existing project design system.
3. Avoid duplicating widget trees.
4. Extract widgets only when they improve readability/reuse.
5. Do not create a separate widget for every tiny UI fragment.
6. Avoid unnecessary nesting.
7. Keep build methods readable.
8. Avoid business logic directly inside large build methods.

## Null Safety

1. Prefer proper null handling over force `!`.
2. Do not use `!` unless nullability is logically guaranteed.
3. Never write code such as:
   `value.toString() ?? "Unknown"`
   because `toString()` is non-null.
4. Handle null at the correct layer.

## Validation

1. Validate user input at the UI/form layer.
2. Never rely only on frontend validation.
3. Match backend validation rules.
4. Do not duplicate complex validation logic unnecessarily.
5. Reuse validators where available.

## Performance

1. Avoid unnecessary rebuilds.
2. Avoid unnecessary API calls.
3. Avoid repeated parsing/conversions.
4. Use const where it provides value.
5. Do not optimize prematurely.
6. Prefer simple efficient solutions over complicated micro-optimizations.

## Error Handling

1. Errors must be meaningful and actionable.
2. Do not catch exceptions just to ignore them.
3. Preserve useful error information.
4. Follow the project's existing error-handling pattern.

## Before Creating New Code

Ask internally:

- Does this already exist?
- Can I reuse it?
- Can I modify the existing implementation?
- Is this abstraction actually necessary?
- Can this be implemented more simply?
- Am I duplicating existing logic?

## Final Code Quality Check

Before finishing:

1. Remove unused imports.
2. Remove unused variables.
3. Remove duplicate logic.
4. Remove unnecessary comments.
5. Remove unnecessary abstractions.
6. Run formatter.
7. Run analyzer/tests relevant to the change.
8. Verify no unrelated files were modified.
9. Keep the implementation concise.

## Golden Rule

Prefer:

Simple + Reusable + Readable + Correct

over:

Complex + Over-engineered + Verbose
