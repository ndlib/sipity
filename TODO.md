# Tasks

## ULRA Ingest to CurateND #971

### Attribute Mapping
 - [x] Generate list of ULRA work attributes. NOTE: attribute keys are defined by _forms_.
 - [ ] Map ULRA work attributes to appropriate predicates
 - [ ] Ensure that predicates are supported by `Document` in CurateND

### ULRA Work Attributes
```yaml
attribute_names:
  AssignAwardStatusForm:
    - is_an_award_winner
  AttachForm:
    - attached_files_completion_state
    - attachments_attributes
    - files
    - project_url
    - representative_attachment_id
  PlanOfStudyForm:
    - expected_graduation_term
    - majors
    - minors
    - primary_college
    - underclass_level
  ProjectInformationForm:
    - award_category
    - course_name
    - course_number
    - title
  PublisherInformationForm:
    - publication_name
    - publication_status_of_submission
    - submitted_for_publication
  ResearchProcessForm:
    - other_resources_consulted
    - resources_consulted
  StartASubmissionForm:
    - advisor_name
    - advisor_netid
    - award_category
    - course_name
    - course_number
    - title
```

### Structure
EtdExporter and UlraExporter are essentially the same except for the attributes hash. It may be a good idea to consolidate them into an RofExporter that relies on an external source for the attributes hash. It probably makes more sense for the attribute hash to live in the *Mapper classes. The attributes hash could be passed into the RofExporter via dependency injection _or_ it could be retrieved via a lookup method based on the Work.

There is also a lot of duplication in the *Mapper classes.
