# Entity
An entity is a persistent data object that the application manages in the database. Entities are the high-level business objects used by the application — for example, Claim, Exposure, and Policy in ClaimCenter; Policy, PolicyLine, and Coverage in PolicyCenter; and TroubleTicket and Disbursement in BillingCenter. An entity serves as the root object for data views, rules, Gosu classes, and most other data-related areas of the application. 

## File Format and Location

### Definition and Metadata
Entity definitions are stored in XML metadata files with the .eti extension. Each file bears the name of the entity it defines (e.g., Activity.eti). New entity definition files are stored in the folder: 

```configuration/config/extensions/entity```

The schema governing all entity files is datamodel.xsd, which defines the allowable entities, their attributes, and their valid subelements. All entity definition files must conform to this schema. 

### Generated Classes

During the build process an equivalent Java file is generated in the folder ```configuration/generated/entity``` is created.


## Structural Anatomy of an Entity File
Each data entity is defined as a root <entity> XML element in its file. Here is a real example from the base configuration — the Activity entity:
```
<?xml version="1.0"?>
<entity xmlns="http://guidewire.com/datamodel"
  desc="An activity is a instance of work assigned to a user and belonging to a claim."
  entity="Activity"
  exportable="true"
  extendable="true"
  platform="true"
  table="activity"
  type="retireable">
  ...
</entity>
```

## Key Attributes

| Attribute	| Purpose |
|-----------|---------|
| `entity`	| The name of the entity (matches the filename)|
| `desc`	|	Human-readable description |
| `table`	|	The underlying database table name |
| `type`	|	Controls how the database manages instances (see below) |
| `exportable`	|	Whether the entity can be exported |
| `extendable`	|	Whether the entity can be extended |
| `platform`	|	Marks it as a Guidewire platform entity |

## The type Attribute and Persistence Behavior
The type attribute is critical — it determines how the application manages entity instances in the database: 

versionable: Instances are stored with a specific ID and version number.
retireable: Instances are preserved in the database even when retired (hidden from the UI). They remain until explicitly archived or deleted by a special function.

## Auto-Generated Fields and Reserved Types
For every declared entity, the application automatically generates an ID field of data type key, which serves as the internally managed primary key. You should never manually create fields of type key. Guidewire also reserves exclusive use of the following additional data types: foreignkey, typekey, and typelistkey. 

## Relationships: Arrays and Foreign Keys
Entities can model one-to-many relationships using array fields. For example, the Contact entity contains a Contact.ContactAddresses field, which is an array of ContactAddresses entities. When defining an array entity: 

If no other entity refers to it via a foreign key → make it versionable
If another entity does refer to it via a foreign key → make it retireable