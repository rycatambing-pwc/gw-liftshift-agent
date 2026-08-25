---
document: gosu-composition
purpose: Delegate keyword for composition-based interface implementation
scope: delegate, multi-interface, override delegated methods
---

# Gosu Composition with Delegates

## Overview

The `delegate` keyword implements composition over inheritance — a class automatically implements one or more interfaces by forwarding calls to a delegate object, without manually writing each method.

## Basic Delegate Syntax

```gosu
class PolicyFacade implements IPolicy {
  delegate _policy : IPolicy = new PolicyImpl()
  // All IPolicy methods automatically delegated to _policy
}
```

- `_policy` holds the delegate object
- `PolicyFacade` satisfies `IPolicy` without writing forwarding methods
- All interface methods are auto-delegated at compile time

## Multiple Interface Delegation

```gosu
class CompositeService implements ILogger, IAuditor, INotifier {
  delegate _logger   : ILogger   = new DefaultLogger()
  delegate _auditor  : IAuditor  = new DefaultAuditor()
  delegate _notifier : INotifier = new DefaultNotifier()
}
```

Each delegate handles its own interface. Calls to `ILogger` methods go to `_logger`, etc.

## Overriding Delegated Methods

Declare the method explicitly to override the delegation:
```gosu
class PolicyFacade implements IPolicy {
  delegate _policy : IPolicy = new PolicyImpl()

  override function getStatus() : PolicyStatus {
    // Custom implementation instead of delegation
    return _policy.getStatus() == PolicyStatus.TC_DRAFT
      ? PolicyStatus.TC_DRAFT
      : PolicyStatus.TC_ACTIVE
  }
}
```

Any method declared on the class takes precedence over the delegate.

## Delegate Field Initialization

Delegates can be initialized inline or in constructor:
```gosu
class MyService implements IService {
  delegate _impl : IService

  construct(impl : IService) {
    _impl = impl   // constructor injection
  }
}
```

## Compound Type from Multiple Delegates

When a class has multiple delegates, its type is a compound type:
```gosu
class Impl implements ISomething, IOther {
  delegate _s : ISomething = new SomeImpl()
  delegate _o : IOther = new OtherImpl()
}
// Impl satisfies ISomething & IOther
```

## Delegate vs Enhancement

| Aspect | Delegate | Enhancement |
|--------|----------|-------------|
| Adds interface implementation | Yes | No |
| Requires declaring class | Yes (implements clause) | No |
| Modifies class definition | Yes | No (separate .gsx file) |
| Dispatch | Virtual (per interface) | Static |
| Override support | Yes | No (no override chain) |

## Delegate vs Inheritance

Use delegation (not inheritance) when:
- The class already extends another class (Java/Gosu single-inheritance)
- The relationship is "has-a" not "is-a"
- Interface implementation is based on a pluggable component
- Different implementations may be injected at runtime

```gosu
// Inheritance: PolicyImpl IS-A BaseImpl
class PolicyImpl extends BaseImpl { }

// Delegation: PolicyFacade HAS-A PolicyImpl
class PolicyFacade implements IPolicy {
  delegate _inner : IPolicy = new PolicyImpl()
}
```

## Practical Guidewire Use Cases

1. **Plugin implementations**: Delegate to different strategies based on jurisdiction/product
2. **Facade pattern**: Wrap complex internal service with simple interface
3. **Decorator pattern**: Wrap with added behavior, delegate rest
4. **Testing**: Inject mock delegate for unit tests

```gosu
// Test-friendly composition
class RatingEngine implements IRatingEngine {
  delegate _engine : IRatingEngine

  construct() {
    _engine = new DefaultRatingEngine()
  }

  construct(engine : IRatingEngine) {
    _engine = engine   // inject mock in tests
  }
}
```
