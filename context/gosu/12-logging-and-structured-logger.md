---
document: logging-and-structured-logger
purpose: Help an agent review Guidewire/Gosu logging code
scope: logging levels, structured logger, CLF, exception logging, security
---

# Logging and Structured Logger

## Logging purpose

Log for:

- success/failure of important actions
- recovery events
- identification of functional areas
- troubleshooting and maintenance
- auditing significant events

## Logging levels

| Level | Typical use |
|---|---|
| TRACE | method entry/exit and very fine-grained events |
| DEBUG | diagnostic details in development/troubleshooting |
| INFO | important progress/result events |
| WARN | potential problem where user experience is not affected |
| ERROR | definite problem where user experience or processing is affected |

Avoid DEBUG in production unless explicitly enabled for troubleshooting.

## Components

- Logger — category/logging channel.
- Appender — output destination.
- Layout — output format.

## Guarded logging

Guard expensive log messages:

```gosu
if (_logger.DebugEnabled) {
  _logger.debug("Expensive value: " + expensiveMethod())
}
```

Parameterized logging avoids concatenation cost for simple values, but expensive method arguments still need guards.

## Exception logging

When catching exceptions:

- attach a useful message
- pass the exception object so stack trace is captured
- log expected/recoverable exceptions at WARN/INFO if appropriate
- log unrecoverable/user-impacting exceptions at ERROR
- do not log and silently swallow without corrective action

```gosu
try {
  // work
} catch (e : Exception) {
  _logger.error("AClass::doWork - meaningful context", e)
  throw e
}
```

## Structured Logger and CLF

Structured Logger supports Guidewire Common Logging Format (CLF), a JSON-based structured format with core fields and a `contextMap`.

Agent checks:

- Is log message self-contained?
- Does context include key IDs such as policy/job/account/claim where relevant?
- Are keys lowerCamelCase?
- Are errors logged with message and stack trace?
- Is PII/PCI/sensitive data excluded?
- Are `print(...)` statements used instead of logging?

## Security

Never log unnecessary sensitive information, session IDs, passwords, PII, or PCI data.
