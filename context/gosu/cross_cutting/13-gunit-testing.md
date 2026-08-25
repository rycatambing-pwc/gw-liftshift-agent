---
document: gunit-testing
purpose: Help an agent recognize and review Gosu unit tests
scope: GUnit, gtest, assertions, TestServer, suites
---

# GUnit Testing

## Mental model

GUnit is used to write automated unit tests of Gosu code and is based on JUnit-style concepts.

## Common locations and naming

- Test classes live under `modules/configuration/gtest`.
- Test classes commonly extend product-specific base classes such as `XXServerTestClassBase` or `XXUnitTestClassBase`.
- Test class names should describe context, often `When...Test`.
- Test functions use lowerCamelCase and often begin with `testThat`.

## Common assertions

- `assertTrue(...)`
- `assertEquals(...)`
- `assertNull(...)`
- `assertNotNull(...)`

## TestServer

If no server is running, Studio may start TestServer automatically. Starting TestServer beforehand can avoid repeated startup costs.

## Suites

Use `@Suites` with a unique string to group test classes. Suite classes should use compatible base test class types.

## Agent checks

When reviewing tests:

1. Does the test name describe behavior?
2. Does it use the correct server/unit base class?
3. Are setup and assertions clear?
4. Does it rely on external integration points, making it not a unit test?
5. Does it verify both expected result and failure path where relevant?
