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

## Rule: Guard Debug Log Messages with `DebugEnabled`

Log message arguments are evaluated **before** the logger level is checked. An unguarded `logger.debug("Value: " + expensiveComputation())` calls `expensiveComputation()` on every execution regardless of whether debug logging is on.

Always guard expensive debug messages:

```gosu
// WRONG — expensiveComputation() runs even when debug is off
logger.debug("Value: " + expensiveComputation())

// CORRECT
if (_logger.DebugEnabled) {
  _logger.debug("Value: " + expensiveComputation())
}
```

This is especially important inside loops or frequently-called methods.

## Rule: Always Pass the Exception as the Second Argument to `logger.error()`

Calling `logger.error(message)` with only a message string captures the message but **discards the stack trace**. Always pass the exception object as the second argument so the full stack trace is captured in the log output.

```gosu
// WRONG — stack trace is lost
} catch (e) {
  _logger.error("Failed to process policy: " + e.Message)
}

// CORRECT
} catch (e) {
  _logger.error("Failed to process policy", e)
}
```

## Rule: Never Silently Swallow Exceptions

An empty or message-only catch block that takes no corrective action hides failures and makes troubleshooting impossible. Either:
- Re-throw the exception (or a wrapped version of it), or
- Log it with the full exception object and take an explicit compensating action.

```gosu
// WRONG — failure is hidden
try {
  processPolicy(policy)
} catch (e) {
  // do nothing
}

// WRONG — stack trace is discarded
} catch (e) {
  _logger.error("Something went wrong")
}

// CORRECT
} catch (e) {
  _logger.error("Failed to process policy " + policy.PublicID, e)
  throw e
}
```

## Rule: Enhancement Dispatch Is Static — Account for the Declared Type

Gosu enhancements use **static dispatch**: the enhancement method called is determined by the **declared type** of the variable at compile time, not the runtime type of the object. If a variable is declared as a base type but holds a subtype instance, the enhancement defined on the base type will be called — not one defined on the subtype.

This is the opposite of virtual method dispatch. Be explicit about declared types when the correct enhancement behavior depends on subtype specificity.

Full details: `/context/gosu/oop/11b-enhancements.md`.

## Rule: Enhancements Are for Cross-Cutting Entity Behavior — Not Narrow UI Logic

Do not write enhancements that exist solely to support one PCF's display logic. Enhancements apply to all code that uses the enhanced type — a narrowly scoped UI helper embedded in an enhancement adds noise and confusion for every other caller of that type.

**Correct approach:** put UI-specific logic in a dedicated UI helper `.gs` class in the customer package, and call it from the PCF Code tab.

## Rule: No Instance Fields or Constructors in `.gsx` Enhancement Files

Gosu enhancements are **compile-time constructs** — they add methods and properties to an existing type but do not have their own object lifecycle. Declaring instance fields or constructors in a `.gsx` file is a compilation error and is conceptually wrong.

```gosu
// WRONG — instance field and constructor in an enhancement
enhancement PolicyEnhancement : entity.Policy {
  var _cache : String  // compile error
  construct() { ... }  // compile error
}

// CORRECT — methods and computed properties only
enhancement PolicyEnhancement : entity.Policy {
  property get DisplayLabel() : String {
    return this.PolicyNumber + " - " + this.Status.Code
  }
}
```

If shared state is needed, put it in a static field on a regular `.gs` class and call that class from the enhancement.

## Rule: Use `@Suites` to Group Related Tests

When a set of GUnit tests covers related functionality, annotate the test class with `@Suites` to group them. This allows running a targeted suite rather than the full test run during focused development or CI validation of a specific feature area.
