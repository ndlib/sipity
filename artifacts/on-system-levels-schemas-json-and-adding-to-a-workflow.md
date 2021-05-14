# On System Levels, Schemas, JSON, and Adding to a Workflow

> Dear reader this is from memory, and could be a bit creaky, but
> highlights some intentionality.  I will attempt to add disclaimers
> to some of the more speculative memories.
>
> Sincerely,
> Jeremy

## History

The Digital Library Technologies (DLT) team originally created Sipity
to help with the workflow for Electronic Theses & Dissertations
(ETDs).  This process involves different folks needing access to
different things at different times in the ETD Submission process.

Those folks are:

* Grad students
* Faculty advisors
* the Graduate School
* Office of Information Technologies (OIT)
* Catalogers of Hesburgh Libraries

At a later point, DLT added the Undergraduate Library Research Award
(ULRA) submissions.  These had similar constraints, but also need to
account for only allowing "submissions" during a given period of time.

Both of these needs created the three conceptual levels of Sipity.
The one most often thought of is the Work Type (e.g., a Master's
Thesis or Doctoral Dissertation).

## System Levels

There are three conceptual levels of Sipity:

* Work Area
* Submission Window
* Work Type

When someone begins the ETD submission process they are immediately
prompted to select a **work type**.  They're implicity selecting the
ETD **work area**, and will be submitting that ETD to the active
**submission window** for the ETD **work area**.

### Work Area

There are two implemented work areas:

* ETD
* ULRA

As of 2021-05-14 the ULRA work area is defunct.  The ETD work area is
what most people would assume Sipity is about.

### Submission Window

This is a conceptual artifact of the ULRA process.  You open and close
a window.  When the **submission window** was open, then anyone could
take the "Create an ULRA submission" action.  That action would create
a ULRA **work type**.

The submission window also determines the available **work types**.

### Work Type

This is the guts of an operation.  Each **work type** has an
associated work flow.  Those workflows are defined in JSON files; see
[app/data_generators/sipity/data_generators/work_types/etd_work_types.config.json][json].

The **work types** work flow defines _who_ can take _what_ action
_when_ the given work is in it's current state.  It can answer many
more questions around the who, what, and when.  You can ask Sipity the following:

* _who_ all can take any action for any state
* for the given state, what actions can be taken

There's also the idea that some actions are required to be taken
before other actions.  That is to say "You can't send it to your
professor until you've assigned your professor."

Again, Sipity really focuses on that _who_, _what_, and _when_
paradigm.

### Synthesis

The submission window for ETDs remain open.  However, if the ETD
process were to substantively change, we could "close" the current
window and "open" a new one.  We could re-use our existing form
objects but might write up different **work types** (with the same
name but different workflow.)

## Permissions

Sipity's permission sub-system can work on any of the above system
levels.  Conceptually, within a work area we could create an action
that would be "Create a Submission Window".  We could then give
someone permission to take that action.  We could also have a
state-machine modeled for the work area.

That machine could say there are two states: active and inactive.  And
there's one action "create a submission window".  And while the work
area is active, "creator" could take the "create a submission window"
action.

Who's the creator?  That's a role.  And we'd assign someone that role.

We could make another action be "deactivate this work area".
Then say that's only valid in the "active" state and then assign only
an "admin" to be able to take that action.

Who's the admin?  That's a role.  And we'd assign a person (or group)
to that role.

Again, to reinforce this: **Sipity is a collaborative multi-step
checklist, with strict authorization concerns.**

Sipity is a system for creating a finite state machine.  Within a
given state, different roles may take actions.  Some actions advance
the state.  Other actions must be taken before you can advance the
state.

### Strategy-level vs. Permission-levels

In Sipity, the system can give some one the role for all works of the
**work type**.  This is how the Grad School get's their ETD processing
super powers.

Alternatiively, the system can give some one a role for a single work.
This is how we ensure only the Grad Student that "submit's an ETD can
see that ETD and not others.

## Schemas

Now that we've worked through the conceptual layers.  Let's dig into
the three major schemas:

* [Work Area Schema][work-area-schema]
* [Submission Window Scheam][submission-window-schema]
* [Work Type Schema][work-type-schema]

Because the work area and submission window are, at present, low
volatility, I'm going to focus on the Work Type Schema.

### Sipity::DataGenerators::WorkTypeSchema

The WorkTypeSchema is responsible for validating (and by extension
documenting) a work type (and it's workflow).  It doesn't know if the
workflow's right, but can definitely say "What you are trying to load
is invalid".

There is a lot going on, and because of the
[permissions](#permissions) concerns, these schemas rely on
composition of sub-schemas.  I encourage you to read through those
schemas, their inline comments, and ask specific questions.

## JSON

The [etd_work_types.config.json][json]is the data that we load
into Sipity's database.  It is what creates the state machine and the
SQL data that allows us to as _who_ can do _what_ and _when_.

## Where's My Administrative Interface

For now, it's the JSON document.  To craft an administrative interface
for permission grants is a rather extensive process.  And
realistically the time to do that does not warrant the low-volatility
of permissions.  If that is no longer true, then it looks like an
excellent exercise for the reader!

## Adding to a Workflow

This is TODO, and will be tasked out once we have a reference from PR https://github.com/ndlib/sipity/pull/1264

[json]:/app/data_generators/sipity/data_generators/work_types/etd_work_types.config.json
[work-area-schema]:/app/data_generators/sipity/data_generators/work_area_schema.rb
[submission-window-schema]:/app/data_generators/sipity/data_generators/submission_window_schema.rb
[work-type-schema]:/app/data_generators/sipity/data_generators/work_type_schema.rb