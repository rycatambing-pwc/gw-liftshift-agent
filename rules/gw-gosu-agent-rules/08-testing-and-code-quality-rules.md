# Testing and Code Quality Rules

These rules govern GUnit test structure, logging discipline, and general code quality conventions. Full background: `/context/gosu/cross_cutting/13-gunit-testing.md`, `/context/gosu/cross_cutting/12-logging-and-structured-logger.md`, `/context/gosu/oop/11b-enhancements.md`.

## GUnit: Tests Must Live in the `gtest` Directory

GUnit tests must be placed in the `gtest` source directory, not alongside production code. Tests placed outside `gtest` will not be discovered by the test runner.

## GUnit: Use the Correct Product Base Class

Each Guidewire product has its own GUnit base test class (e.g. `gw.testharness.TestBase` for PolicyCenter, equivalent classes for ClaimCenter and BillingCenter). Always extend the appropriate base class — it sets up the server context needed for entity access and bundle management. Using the wrong base class, or no base class, produces test failures that look like infrastructure problems rather than assertion failures.

## GUnit: Follow the `When...Test` Naming Convention

Test class names should follow the `When<Subject><Condition>Test` pattern (e.g. `WhenPolicyIsSubmittedTest`, `WhenClaimHasNoExposuresTest`). Individual test methods (prefixed with `testThat`) should describe the expected outcome, not the mechanism.

```gosu
// GOOD
function testThatPolicyNumberIsAssignedOnSubmission() { ... }

// BAD — describes what happens, not what is asserted
function testSubmitPolicy() { ... }
```

## GUnit: Test Both the Success Path and the Failure Path

Every test must cover at minimum: the outcome when the condition holds (assertion passes) and the outcome when it does not (expected failure, exception, or null result). A test that only asserts the happy path provides no protection against regressions on error cases.

## Rule: Never Use `print()` for Logging

`print()` is a Gosu development convenience — it writes to stdout and bypasses Guidewire's logging infrastructure entirely. It provides no level control, no log routing, and no structured output.

**Always use the structured logger** with the appropriate level:

```gosu
// WRONG
print("Processing policy: " + policy.PublicID)

// CORRECT
logger.info("Processing policy: " + policy.PublicID)
```

## Rule: Never Log PII or PCI Data

Do not log personally identifiable information (names, addresses, SSNs, dates of birth) or payment card information (card numbers, CVVs, expiry dates) at any log level. This applies to all log outputs — structured logger, debug logs, and any diagnostic output.

## Rule: Enhancement Dispatch Is Static — Account for the Declared Type

Gosu enhancements use **static dispatch**: the enhancement method called is determined by the **declared type** of the variable at compile time, not the runtime type of the object. If a variable is declared as a base type but holds a subtype instance, the enhancement defined on the base type will be called — not one defined on the subtype.

This is the opposite of virtual method dispatch. Be explicit about declared types when the correct enhancement behavior depends on subtype specificity.

Full details: `/context/gosu/oop/11b-enhancements.md`.

## Rule: Enhancements Are for Cross-Cutting Entity Behavior — Not Narrow UI Logic

Do not write enhancements that exist solely to support one PCF's display logic. Enhancements apply to all code that uses the enhanced type — a narrowly scoped UI helper embedded in an enhancement adds noise and confusion for every other caller of that type.

**Correct approach:** put UI-specific logic in a dedicated UI helper `.gs` class in the customer package, and call it from the PCF Code tab.

## Rule: Use `@Suites` to Group Related Tests

When a set of GUnit tests covers related functionality, annotate the test class with `@Suites` to group them. This allows running a targeted suite rather than the full test run during focused development or CI validation of a specific feature area.
