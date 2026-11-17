# Backend Engineering Rules

## Core Principles

1. Write production-ready, senior-level backend code.
2. Code must be clean, concise, maintainable, and reliable.
3. Prefer the simplest correct implementation.
4. Every line must have a clear purpose.
5. Avoid verbose, redundant, and over-engineered implementations.
6. Do not create 50 lines of code when 20 clean lines solve the same problem correctly.
7. Follow existing project architecture and conventions.

## ALWAYS Inspect Existing Code First

Before modifying or creating backend code:

1. Search the existing codebase for:
   - API endpoints
   - Views/controllers
   - Serializers
   - DTOs
   - Models
   - Schemas
   - Services
   - Repositories
   - Validators
   - Utilities
   - Query helpers
   - Constants
2. Understand the current request → validation → business logic → DB → response flow.
3. Reuse existing implementations.
4. Modify existing code when the required behavior belongs there.
5. NEVER create duplicate services, validators, serializers, or helpers.
6. Do not introduce a new architectural layer unless there is a real need.

## Architecture

Keep responsibilities separated:

API/View
    ↓
Validation / Serializer
    ↓
Business Logic / Service
    ↓
Repository / Query
    ↓
Database

Do not put unrelated business logic inside API views/controllers.

## Reusability

1. Reuse existing services and utilities.
2. Extract shared logic only when it is actually reused.
3. Avoid generic abstractions that solve only one trivial case.
4. Do not create helper functions merely to reduce line count.
5. A helper should have a clear responsibility.

## Code Size

1. Prefer files around 100–120 lines.
2. If a file grows significantly beyond this:
   - Remove duplication first.
   - Reuse existing utilities.
   - Simplify logic.
   - Split only meaningful responsibilities.
3. Do not artificially split logically related code only because of line count.
4. Large files should trigger an architecture review.

## API Contracts

1. API request and response contracts must be explicit.
2. Match frontend expectations exactly.
3. Do not silently rename API fields.
4. Keep request and response types consistent.
5. Document intentional differences between Create and GET contracts.
6. Never assume frontend and backend types are identical without verifying the actual wire format.

## Validation

1. Validate all client-controlled input on the backend.
2. Backend validation is authoritative.
3. Validate:
   - Required fields
   - Types
   - Ranges
   - Enum/choice values
   - String lengths
   - Lists
   - Files
   - Coordinates
   - Relationships
4. Reject invalid data instead of silently converting it when conversion could hide a client bug.
5. Keep validation logic reusable where appropriate.
6. Do not duplicate identical validation rules across multiple locations unnecessarily.

## Database

1. Store data using the correct database type.
2. Do not store structured data as strings when the schema supports structured types.
3. Preserve numeric values as numeric values.
4. Preserve lists as lists.
5. Preserve GeoJSON/geospatial data using the correct DB representation.
6. Use database constraints where appropriate.
7. Do not trust client-provided server-owned fields.

## Server-Owned Fields

Fields such as:

- user_id
- created_at
- updated_at
- listing_id
- listing_clicks
- is_active
- ownership information

must be controlled by the backend when they are server-owned.

Do not allow clients to override them unless explicitly required by the API contract.

## Query / GET APIs

1. GET responses must use the documented response contract.
2. Do not return unnecessary fields.
3. Reuse serializers/response builders where appropriate.
4. Avoid N+1 database queries.
5. Filter and paginate at the database/query level whenever possible.
6. Do not load large datasets into memory unnecessarily.

## Create → DB → GET Consistency

For every important entity, verify:

Request
  ↓
Validation
  ↓
Business Logic
  ↓
Database
  ↓
GET Serializer
  ↓
Frontend

Types and values must remain consistent across the entire flow.

Example:

price
Flutter → wire → backend → DB → GET → Flutter

Do not fix only one layer if the contract is inconsistent across multiple layers.

## Null / Empty Values

1. Clearly distinguish:
   - null
   - empty string
   - empty list
   - zero
2. Do not convert values arbitrarily.
3. Do not store empty strings where null is semantically correct.
4. Follow the existing API contract.

## Error Handling

1. Return consistent HTTP status codes.
2. Return useful validation errors.
3. Do not expose internal stack traces or sensitive implementation details.
4. Log unexpected server errors appropriately.
5. Never silently swallow exceptions.

## Security

1. Never trust client-provided authorization/ownership fields.
2. Validate permissions before modifying resources.
3. Validate uploaded files.
4. Prevent unauthorized object access.
5. Do not expose sensitive database fields.
6. Avoid logging secrets, tokens, passwords, or sensitive data.

## Performance

1. Prefer efficient DB queries.
2. Avoid unnecessary DB calls.
3. Avoid repeated serialization/parsing.
4. Use indexes where justified by query patterns.
5. Do not introduce caching without a real performance requirement.
6. Avoid premature optimization.

## Testing

For every meaningful backend change, consider:

1. Valid input
2. Missing required fields
3. Invalid types
4. Invalid enum values
5. Boundary values
6. Null values
7. Empty values
8. Unauthorized access
9. Database persistence
10. GET response correctness

## Before Creating New Code

Always ask:

- Does this already exist?
- Can I reuse it?
- Can I modify the existing implementation?
- Is a new service/helper really necessary?
- Am I duplicating business logic?
- Can this be simpler?

## Final Code Quality Check

Before finishing:

1. Remove unused imports.
2. Remove unused variables.
3. Remove duplicate logic.
4. Remove unnecessary abstractions.
5. Remove unnecessary comments.
6. Check API contract.
7. Check DB types.
8. Check error handling.
9. Run formatter/linter.
10. Run relevant tests.
11. Verify no unrelated files changed.

## Golden Rule

Prefer:

Simple + Correct + Reusable + Testable + Secure

over:

Complex + Redundant + Over-engineered + Verbose
