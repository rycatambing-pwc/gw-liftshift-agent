---
document: gosu-checksums-fingerprints
purpose: FP64 checksum/fingerprint class for data integrity and deduplication
scope: gw.util.fingerprint.FP64, checksums, hashing
---

# Checksums and Fingerprints (FP64)

## Overview

`gw.util.fingerprint.FP64` provides 64-bit Fowler-Noll-Vo (FNV) fingerprints for data integrity checks, cache keys, deduplication, and change detection.

## Constructors

```gosu
new FP64(s : String)                // fingerprint a string
new FP64(bytes : byte[])            // fingerprint a byte array
new FP64(chars : char[])            // fingerprint a char array
new FP64(stream : InputStream)      // fingerprint an input stream
new FP64(existing : FP64)           // copy an existing fingerprint
```

## Basic Usage

```gosu
uses gw.util.fingerprint.FP64

var fp = new FP64("my content")
var hexString = fp.toHexString()    // hex representation
var bytes = fp.toBytes()            // byte[] representation
```

## Chaining Fingerprints with extend()

`extend()` combines two fingerprints — equivalent to fingerprinting the concatenated content:

```gosu
var combined = new FP64(s1).extend(new FP64(s2))

// These two are equivalent:
var a = new FP64(s1 + s2)
var b = new FP64(s1).extend(new FP64(s2))
a.equals(b)   // true
```

Use `extend()` to incrementally fingerprint large data without building a concatenated string.

## Equality and HashMap Use

`FP64` overrides `equals()` and `hashCode()` — usable as a `HashMap` key:

```gosu
var cache = new HashMap<FP64, ProcessedResult>()
var key = new FP64(documentContent)
if (not cache.containsKey(key)) {
  cache.put(key, processDocument(documentContent))
}
var result = cache.get(key)
```

## Common Use Cases

### Change Detection
```gosu
var beforeFP = new FP64(policy.toXml())
// ... modifications ...
var afterFP = new FP64(policy.toXml())
if (not beforeFP.equals(afterFP)) {
  // policy changed
}
```

### Deduplication
```gosu
var seen = new HashSet<FP64>()
for (item in items) {
  var fp = new FP64(item.UniqueContent)
  if (seen.add(fp)) {
    processUniqueItem(item)
  }
}
```

### Cache Keys
```gosu
var fp = new FP64(inputData)
var cached = _resultCache.get(fp.toHexString())
```

## Notes

- FP64 is non-cryptographic — do NOT use for security (password hashing, digital signatures)
- 64-bit — collision probability is low but non-zero; verify collision strategy for critical use cases
- `toHexString()` returns a 16-character hex string
