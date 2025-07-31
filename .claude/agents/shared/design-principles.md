# Core Design Principles

Essential principles that guide all Zenvestor development decisions.

## YAGNI (You Aren't Gonna Need It)

Don't implement functionality until it's actually needed, not when you think you might need it.

**DO:**
- Implement only what's required for current user stories
- Create interfaces with only the methods currently used
- Add properties only when they serve an immediate purpose

**DON'T:**
- Add "nice to have" features without requirements
- Create generic solutions for hypothetical future needs
- Build abstractions for single use cases

## KISS (Keep It Simple, Stupid)

Simplicity should be a key goal in design, and unnecessary complexity should be avoided.

**DO:**
- Prefer clear, straightforward code over clever solutions
- Use well-known patterns instead of inventing new ones
- Choose readable names over short ones

**DON'T:**
- Over-engineer solutions
- Create deep nesting or complex conditionals
- Optimize prematurely

## DRY (Don't Repeat Yourself)

Every piece of knowledge must have a single, unambiguous, authoritative representation within a system.

**DO:**
- Extract common patterns into shared code
- Use composition to share behavior
- Create abstractions for repeated business logic

**DON'T:**
- Copy-paste code between files
- Duplicate business rules
- Confuse textual similarity with knowledge duplication

## Application

These principles work together:
- YAGNI prevents over-engineering
- KISS ensures maintainability
- DRY reduces inconsistency

Apply them pragmatically - they guide decisions but aren't rigid rules.