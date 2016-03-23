# Tasks

## ULRA Ingest to CurateND #971

### Attributes
 - [ ] Generate list of ULRA work attributes. NOTE: attribute keys are defined by _forms_.
 - [ ] Map ULRA work attributes to appropriate predicates
 - [ ] Ensure that predicates are supported by `Document` in CurateND

### Structure
EtdExporter and UlraExporter are essentially the same except for the attributes hash. It may be a good idea to consolidate them into an RofExporter that relies on an external source for the attributes hash. It probably makes more sense for the attribute hash to live in the *Mapper classes. The attributes hash could be passed into the RofExporter via dependency injection _or_ it could be retrieved via a lookup method based on the Work.

There is also a lot of duplication in the *Mapper classes.