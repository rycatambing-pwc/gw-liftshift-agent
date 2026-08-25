---
document: gosu-xml-integration
purpose: XML parsing, creation, and serialization in Gosu
scope: XmlElement, QName, XSD-based types, XmlSerializationOptions, Base64
---

# XML Integration in Gosu

## Core Types

- `gw.xml.XmlElement` — generic XML element for schema-less XML
- XSD-generated types — strongly typed, derived from XSD schemas
- `gw.xml.XmlSerializationOptions` — controls serialization output

## Generic XML (XmlElement)

```gosu
uses gw.xml.XmlElement

// Parse XML string
var root = XmlElement.parse("<person><name>John</name></person>")

// Access children
var name = root.getChild("name").Text

// Create XML
var elem = new XmlElement("person")
elem.setAttributeValue("id", "123")
var child = new XmlElement("name")
child.Text = "John"
elem.addChild(child)

// Serialize
var xmlString = elem.asUTFString()   // for debugging only
var bytes = elem.bytes()             // preferred — use for production
```

## XSD-Generated Types

When an XSD schema is provided, Gosu generates strongly-typed classes:

```gosu
// XSD-generated type (e.g. from WSDL/schema)
var person = new PersonType()
person.$Name = "John"     // $ prefix for XSD-defined elements/attributes
person.$Age = 30
var bytes = person.bytes()
```

### XSD-Prefixed Properties

On XSD-generated types, all properties have `$` prefix:

| Property | Purpose |
|----------|---------|
| `$Children` | Child elements |
| `$Namespace` | Namespace URI |
| `$QName` | Qualified name |
| `$Text` | Text content |
| `$TypeInstance` | Type info |
| `$SimpleValue` | Typed simple value |
| `$Value` | Value accessor |
| `$Nil` | xsi:nil flag |

## QName

```gosu
uses javax.xml.namespace.QName

var qname = new QName("http://my.namespace", "localName")
var qname2 = new QName("localName")   // no namespace
```

## Parsing Best Practices

```gosu
// Best — use bytes for production (most efficient)
var xmlBytes = getXmlBytes()
var element = XmlElement.parse(xmlBytes)

// Acceptable — use string for debugging only
var xmlStr = "<root/>"
var element = XmlElement.parse(xmlStr)
```

`element.bytes()` — preferred over `element.asUTFString()` for all non-debug use.

## Serialization Options

```gosu
var options = new XmlSerializationOptions()
options.setPrettyPrint(true)
options.setEncoding("UTF-8")

var bytes = element.bytes(options)
```

## XmlSimpleValue Factories

For creating typed simple values in XSD types:

```gosu
var dateVal = XmlSimpleValue.makeDateInstance(someDate)
var intVal = XmlSimpleValue.makeIntInstance(42)
var boolVal = XmlSimpleValue.makeBooleanInstance(true)
var strVal = XmlSimpleValue.makeStringInstance("text")
```

## XSD to Gosu Type Mappings

| XSD type | Gosu type |
|----------|-----------|
| `xs:string` | `String` |
| `xs:int` / `xs:integer` | `Integer` / `BigInteger` |
| `xs:decimal` | `BigDecimal` |
| `xs:boolean` | `Boolean` |
| `xs:dateTime` | `java.util.Date` |
| `xs:date` | `java.util.Date` (date part only) |
| `xs:base64Binary` | `byte[]` |

## Base64 Encoding / Decoding

```gosu
uses gw.api.util.Base64Util

var encoded = Base64Util.encode(myBytes)    // byte[] → Base64 String
var decoded = Base64Util.decode(encoded)   // Base64 String → byte[]
```

## Agent checks

When reviewing XML code:

1. Is `element.bytes()` used (preferred) or `element.asUTFString()` (debug only)?
2. Are XSD-generated type properties accessed with `$` prefix?
3. Is Base64 encoding correct for `xs:base64Binary` fields?
4. Are namespace prefixes handled with `QName` where needed?
