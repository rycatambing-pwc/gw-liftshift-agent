---
document: gosu-templates
purpose: Gosu template files (.gst) for generating text/HTML output
scope: .gst files, renderToString, render, params, extends, scriptlets, expressions
---

# Gosu Templates (.gst)

## Overview

Gosu templates are `.gst` files that generate text output by mixing static text with embedded Gosu expressions and scriptlets. Used for email bodies, document generation, HTML snippets, and other text output.

## Basic Template Syntax

```gosu
// greeting.gst
Hello, ${name}!
Today is <%= java.time.LocalDate.now() %>.
```

### Expression Syntax

- `${expr}` — inline expression, output the result
- `<%= expr %>` — same as `${expr}`, alternative syntax
- `<% code %>` — scriptlet, execute code without output

```gosu
// Using scriptlet for conditional output
<% if (user.Premium) { %>
  Welcome, Premium member!
<% } else { %>
  Upgrade to Premium for more features.
<% } %>
```

## Template Parameters

Declare parameters with `<%@ params(...) %>`:

```gosu
<%@ params(name : String, amount : BigDecimal, dueDate : java.util.Date) %>
Dear ${name},

Your payment of ${amount} is due on ${dueDate}.
```

## Template Inheritance

Extend a base template class with `<%@ extends ClassName %>`:

```gosu
<%@ extends gw.api.template.BaseEmailTemplate %>
<%@ params(policy : entity.Policy) %>

Subject: Policy ${policy.PolicyNumber} Update

Dear ${policy.PrimaryInsured.DisplayName},
...
```

## Comments

Template comments (not included in output):

```gosu
<%-- This is a template comment, not rendered --%>
```

## Using a Template

### renderToString()

```gosu
var output = greeting_gst.renderToString()   // no params
var output = policyEmail_gst.renderToString(policy)  // with params
```

### render(writer)

```gosu
uses java.io.StringWriter

var writer = new StringWriter()
policyEmail_gst.render(writer, policy)
var output = writer.toString()
```

## Template Class Name Convention

Template file `policyRenewal.gst` → class `policyRenewal_gst`

The `_gst` suffix is the Gosu naming convention for template classes.

## Template File Size Limit

**JVM method limit**: Templates compile to a single Java method. JVM methods are limited to 65535 bytes of bytecode. Very large templates can exceed this limit and fail to compile.

**Solution for large templates**: Split into multiple smaller templates and compose them:

```gosu
// mainTemplate.gst
<%@ params(policy : entity.Policy) %>
${headerSection_gst.renderToString(policy)}
${bodySection_gst.renderToString(policy)}
${footerSection_gst.renderToString()}
```

## Gosu Expressions in Templates

Full Gosu expressions are valid:

```gosu
<%@ params(items : List<LineItem>) %>
Total items: ${items.Count}
Subtotal: ${items.sum(\i -> i.Amount)}

<% for (item in items) { %>
  - ${item.Description}: ${item.Amount}
<% } %>
```

## Error Handling in Templates

Templates throw exceptions at runtime for:
- Null pointer on `${expr}` when expr is null (use `${expr ?: ""}`)
- Missing parameter (compile error)
- Method not found on type (compile error)

Null-safe output:
```gosu
${policy.Description ?: "No description provided"}
```

## Agent checks

When reviewing template code:

1. Are parameters declared with `<%@ params(...) %>`?
2. Is the template large enough to risk the 65535 byte limit?
3. Are null values handled with `?:` in expressions?
4. Is `renderToString()` called with the correct parameter types?
