# Sipity

[![Build Status](https://travis-ci.org/ndlib/sipity.png?branch=master)](https://travis-ci.org/ndlib/sipity)
[![Code Climate](https://codeclimate.com/github/ndlib/sipity.png)](https://codeclimate.com/github/ndlib/sipity)
[![Test Coverage](https://codeclimate.com/github/ndlib/sipity/badges/coverage.svg)](https://codeclimate.com/github/ndlib/sipity)
[![Dependency Status](https://gemnasium.com/ndlib/sipity.svg)](https://gemnasium.com/ndlib/sipity)
[![Documentation Status](http://inch-ci.org/github/ndlib/sipity.svg?branch=master)](http://inch-ci.org/github/ndlib/sipity)
[![APACHE 2 License](http://img.shields.io/badge/APACHE2-license-blue.svg)](./LICENSE)
[![Contributing Guidelines](http://img.shields.io/badge/CONTRIBUTING-Guidelines-blue.svg)](./CONTRIBUTING.md)

A plugin-ready and extensible Rails application for modeling approval style workflows.

**Q: Is it ready for other people to use?**
_A: No. However it has been designed to extract Notre Dame specific information into a separate plugin._

**Q: Why would we want to use and build upon Sipity instead of rolling our own?**
_A: Good question. Depends on your use cases. Sipity is built with the idea of approval steps and custom forms. It is not yet a generalized application. However, it is our teams observations and response to how shared Rails applications fail._

**Q: What is appealing about Sipity? In otherwords how might it work for me?**
_A: Sipity keeps business logic/validation separate from process/approval modeling separate from captured metadata. It has naive assumptions but those are isolated and provide a place to work from._

Sipity is a patron-oriented deposit interface into CurateND.
Its goal is to provide clarity on why a patron would want to fill out metadata information.

## Getting Your Bearings

### Running under SSL

To run the application under SSL, use the following command:

```console
SSL=true bin/rails s
```

Then go to https://localhost:3000

### Work Submission

The primary feature (and complexity) is Sipity's work submission show page. Below is a diagram that helps break down its composition.

![Sipity Todo List Page](artifacts/sipity-todo-list-page.png)

Sipity is a Rails application but is built with a few more concepts in mind.

![Sipity Request Cycle](artifacts/sipity-request-cycle.png)

Or if you can leverage the command line.

![Sipity Command Line Request Cycle](artifacts/sipity-command-line-request-cycle.png)

Or if you'd like to see how `cron` jobs are scheduled, look in [config/schedule.rb](config/schedule.rb).

## Anatomy of Sipity

Below is a list of the various concepts of Sipity.

```
app
|-- assets
|-- constraints
|-- controllers
|-- conversions
|-- data_generators
|-- decorators
|-- exceptions
|-- exporters
|-- forms
|-- jobs
|-- mailers
|-- mappers
|-- models
|-- parameters
|-- policies
|-- presenters
|-- processing_hooks
|-- repositories
|-- response_handlers
|-- runners
|-- services
|-- validators
|-- views
```

### Cohesion, Orthogonality, and Decoupling

I am working to keep the various concepts of Sipity loosely coupled.
I use the various `rake spec:coverage:<layer>` tasks to help me understand how each layer's specs cover that layer's code.

My conjecture is that if each layer's specs cover the entire layer:

* I have a well documented internal API.
* My feature tests can focus on integration of the various layers.

### Assets, Controllers, Helpers, Mailers, Models, Views

The usual Rails suspects.

Jeremy's Admonition:

* **Though shalt not put behavior in ActiveRecord objects**
  - This means:
    * No before/after save callbacks - prefer repository service/command objects/methods
    * No query scopes - prefer repository query objects/methods
    * No conditional validations - prefer form objects
  - Why?
    * Because the data structures are important, but "creating the universe" everytime you want to deal with a persisted object is insanity.
* **Though shalt not use ActionController filters**
  - This means:
    * Pushing authentication to another layer
    * Pushing authorization to another layer
    * Pushing cache management to another layer
    * Avoid before/after filters
  - Why?
    * Because controllers have enough stuff going on; They are often hard to test.
      - Ensuring you have the correct parameters
      - Mapping the results of the action to a response
      - Communicating any messages
      - In other words, they already have enough reasons to change.
* **Though shalt think about command line interaction**
  - This means:
    * The controllers are one of many possible clients for the underlying application.
  - Why?
    * Because if you can disentangle your application from the web pages, you will have a richer application.

### Conversions

Taking a cue from [Avdi Grimm's "Confident Ruby"](http://www.confidentruby.com/), Conversions are responsible for coercing the input to another format. These are similar to `Array()` function.

The Conversions modules are designed to be either:

* callable via module functions
* include-able and thus expose an underlying conversion method

Find out more about [Sipity's Conversions](https://github.com/ndlib/sipity/blob/master/app/conversions/sipity/conversions.rb)

### Decorators

Models are great for holding data.
Decorators are useful for collecting that data into meaningful information.

Take a look at the [Draper gem](https://github.com/drapergem/draper). It does a
great job of explaining their importance.

Find out more about [Sipity's Decorators](https://github.com/ndlib/sipity/blob/master/app/decorators/sipity/decorators.rb)

### Forms

Forms are a class of objects that are different from models. They may represent
a subset of a single model's attributes, or be a composition of multiple
objects.

Regardless their purpose is to:

* Expose attributes
* Validate attributes

They are things that could be rendered via the `simple_form_for` view template
method.

As of the writing of this, I'm not making use of Nick Sutterer's fantastic
Reform gem. Though it could make its way into this application.

Find out more about [Sipity's Forms](https://github.com/ndlib/sipity/blob/master/app/forms/sipity/forms.rb)

### Jobs

There are certain things you don't want to do during the HTTP request cycle.
Expensive calculations, remote service calls, etc.

Find out more about [Sipity's Jobs](https://github.com/ndlib/sipity/blob/master/app/jobs/sipity/jobs.rb)

**Note: With the imminent arrival of the ActiveJob into Rails 4.2, this subsystem may undergo a change.**

### Policies

Take a look at the [Pundit gem](https://github.com/elabs/pundit). Sipity is
implementing policies that adhere to the interface of Pundit Policy and Scope
objects.

Find out more about [Sipity's Policies](https://github.com/ndlib/sipity/blob/master/app/policies/sipity/policies.rb)

### Repositories

Of particular note is the Sipity::Repository class. Here are methods for
interacting with the persistence layer; either by way of commands or queries.

Find out more about [Sipity's Repositories](https://github.com/ndlib/sipity/blob/master/app/repositories/sipity/repository.rb)

### Runners

This is a step towards crafting a single class per Controller action.
They are an implementation idea of the late Jim Weirich and provide a fantastic
means of pulling even more logic out of the overworked Rails controller.

Find out more about [Sipity's Runners](https://github.com/ndlib/sipity/blob/master/app/runners/sipity/runners.rb)

### Services

The grand dumping ground of classes that do a bit more than conversions and
may not be a direct interaction with the repository.

Find out more about [Sipity's Services](https://github.com/ndlib/sipity/blob/master/app/services/sipity/services.rb)

### Validators

Because we have a need for custom validation.

### Models

For completeness, including a rudimentary Entity Relationship Diagram (ERD).

![Sipity ERD](artifacts/sipity-erd.png)

## Relationship Between Forms, Models, and Decorators

* A decorator exposes a _logical group_ attributes that a user can see.
* A form exposes a _logical group_ of attributes for a user to edit.
* A model persists attributes in a _normalized_ manner.

A decorator's attributes may be queried from numerous models.

A form's attributes may end up persisted across numerous models.
The initial value for any of those attributes may be retrieved from persisted models.

Multiple forms may exist that modify the same underlying attribute.

For example, we ask our patrons to provide a title when they create a work.
If the patron then assigns DOI, there is a form that exposes the same title along with other attributes (i.e. publisher).
If the patron then assigns a citation, and filled out a DOI, we'll leverage the same publisher as reported.

The fundamental idea is that we are providing different contexts for our patrons to fill out information.
And each metadatum may be shared across different contexts.

The idea is stretched further, as we consider something like an geo-spatial data.

If one context is "Tell us about your geo-spatial data" then that data will be required.
If you don't want to fill it out, cancel what you are doing.

If another context is "Tell us about your metadata" and we expose geo-spatial data, then that data would not be required.

## Why Do Some Repository Methods Use Service Objects?

> Why do some repository methods delegate to a service object and
> other methods have inline behavior?

My short answer is that methods are very readable, but classes allow
encapsulation of ideas. So, as a repository method gets more
complicated it becomes a primary candidate for factoring into a class.

Another way to think about it is that repository methods provide a
convenience method for Presenter and Form interaction with the data.

My suspicion is that each form should leverage a collaborating service
class instead of service method(s); The service class could be swapped
out as well. But forms are a complicated critter; They need data from
the persistence layer and need to issue a command to update the
persistence layer. (They leverage both commands and queries).

With the separation of CommandRepository and QueryRepository, our code
is at a point where forms could be composed of a QueryService and
CommandService object. And that is how things may move going forward.
But for now we factor towards an understanding of how our code is
growing and taking shape.

## Users, Groups, and Actors

Sipity has three concepts that are important when considering permissions:

* [User](app/models/user.rb) - a NetID backed person leveraging the ubiqutous [Devise gem](https://github.com/plataformatec/devise)
* [Sipity::Models::Group](app/models/sipity/models/group.rb) - represents a set of Users in which there is a logicl business connection.
* [Sipity::Models::Processing::Actor](app/models/sipity/models/processing/actor.rb) - the Object in which permissions are checked against. An Actor is associated with either a User or a Group – via a polymorphic association.

When actions are taken we record both the requestor and on behalf of information. Often the requester is a User (i.e. someone logged into the system) but Sipity is really only concerned with does the User’s associated Actor have permission. So I have short-circuited the Group structure to say that these “Agents” are in fact groups. I store the group’s api key and check basic authentication to see if it includes a Group and API Key that are correct. If so I authenticate the current user as the group (again a concession of Devise).

## Creating a New Form

* Add or reuse attributes defined [`Sipity::Models::AdditionalAttribute`](app/models/sipity/models/additional_attribute.rb); Note the "title" is an attribute on the Work.
* Add the [form object](app/forms/sipity/forms/) to the correct work area.
* Add the corresponding [view template](app/views/sipity/controllers/) to the correct location
  - The name of the form object (e.g. `BannerProgramCodeForm`) informs the name of the template (e.g. `banner_program_code.html.erb`)
* Add the form's processing action name to the corresponding workflow; The convention for processing_action_name is the form's demodulized object name in underscore format without the '\_form' (e.g. `BannerProgramCodeForm` has an action name for `banner_program_code`)

## Working with Sipity

The primary feature of Sipity is state-based permissions. It can be helpful to force an object into a given state. Use `Sipity::Services::Administrative::ForceIntoProcessingState.call` via `$ rails console`
