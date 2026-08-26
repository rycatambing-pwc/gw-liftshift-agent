# Gosu Dimensions

## Overview

Dimensions represent physical or financial quantities with units — e.g., monetary amounts, lengths, durations. Gosu's `IDimension` interface lets custom types behave like numbers with arithmetic operators.

## IDimension Interface

```gosu
class MyMeasure implements IDimension<MyMeasure, UnitType> {
  override function add(that : MyMeasure) : MyMeasure { ... }
  override function subtract(that : MyMeasure) : MyMeasure { ... }
  override function multiply(scalar : Number) : MyMeasure { ... }
  override function division(scalar : Number) : MyMeasure { ... }
  override function modulo(scalar : Number) : MyMeasure { ... }
  override function negate() : MyMeasure { ... }
  override function toNumber() : Number { ... }
  override function fromNumber(n : Number, unit : UnitType) : MyMeasure { ... }
  override function numberType() : Class { ... }
  override function compareTo(that : MyMeasure) : int { ... }  // optional but needed for </>
}
```

- `CLASSNAME` = the implementing class itself (self-type)
- `UNITTYPE` = the unit of measure type (e.g., `Currency`, `LengthUnit`)
- Implement `compareTo` to enable `<`, `>`, `<=`, `>=` operators

## Arithmetic Operator Overloading

When `IDimension` is properly implemented, Gosu enables standard arithmetic:
```gosu
var total = amount1 + amount2   // calls add()
var diff  = amount1 - amount2   // calls subtract()
var half  = amount1 / 2         // calls division()
var triple = amount1 * 3        // calls multiply()
var rem   = amount1 % 100       // calls modulo()
var neg   = -amount1            // calls negate()
```

Comparison operators work when `compareTo` is implemented:
```gosu
amount1 < amount2
amount1 >= amount2
```

## Built-in Guidewire Dimension Types

### MonetaryAmount
```gosu
uses gw.pl.currency.MonetaryAmount

var amount = new MonetaryAmount(100.00bd, Currency.TC_USD)
var total = amount + new MonetaryAmount(50.00bd, Currency.TC_USD)
```

### CurrencyAmount
```gosu
uses gw.api.financials.CurrencyAmount

var ca = new CurrencyAmount(250.00bd, Currency.TC_EUR)
```

Both types hold a `BigDecimal` value and a `Currency` typekey. Arithmetic only valid within the same currency.

## Date Intervals as Dimensions

Date intervals use `DateInterval` with a `DateUtil` unit:
```gosu
var weeks = (startDate..endDate).unit(DateUtil.WEEKS)
var days  = (startDate..endDate).unit(DateUtil.DAYS)
var r = startDate..(startDate + 7.Days)  // if Days dimension defined
```

## Custom Dimension Example

```gosu
class Temperature implements IDimension<Temperature, TemperatureUnit> {
  var _value : BigDecimal
  var _unit : TemperatureUnit

  construct(v : BigDecimal, u : TemperatureUnit) {
    _value = v; _unit = u
  }

  override function add(that : Temperature) : Temperature {
    return new Temperature(_value + that._value, _unit)
  }
  override function toNumber() : Number { return _value }
  override function compareTo(that : Temperature) : int {
    return _value.compareTo(that._value)
  }
  // ... other required methods
}
```

## Unit Conversions

Dimensions do NOT automatically convert units — the programmer is responsible:
```gosu
// Wrong: mixing currencies
var wrong = new MonetaryAmount(100.bd, Currency.TC_USD) + new MonetaryAmount(50.bd, Currency.TC_EUR)
// Correct: convert first, then add
```

## Interval Integration

Custom types can participate in intervals by implementing `ISequenceable`:
```gosu
var tempRange = new Temperature(0.bd, C)..new Temperature(100.bd, C)
```
