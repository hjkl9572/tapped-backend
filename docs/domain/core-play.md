# Play Domain

## Overview

The Play domain represents the core behavioral content of the application.

A **Play** describes something that people can choose to do.

Examples include:

* completing a personal challenge
* joining an offline meetup
* participating in a chatting session
* performing a daily routine
* playing a social game
* completing an activity with another person or group

The specific form of the activity may vary, but the common concept is the same:

> A Play defines a behavior that a person can understand, choose, and participate in.

The application is therefore not fundamentally a challenge application.

It is a **behavior platform** where behaviors themselves are treated as content.

---

## Play as Behavioral Content

Most content platforms organize content around something people consume.

For example:

```text
Video platform
→ watch a video

Music platform
→ listen to a song

Social media
→ read or view a post
```

The Play domain instead organizes content around something people **do**.

```text
Play platform
→ perform a behavior
```

A Play is therefore similar to a piece of content, but its purpose is to initiate behavior rather than passive consumption.

A user can discover a Play, understand what it asks them to do, decide whether they want to participate, and then perform that behavior.

This makes the Play itself the central content unit of the application.

---

## Default Play

Every Play begins with a small set of concepts that describe the behavior.

The default Play consists of:

### Title

A short description of the activity.

Examples:

```text
Read for 30 minutes every day

Meet strangers for coffee

No social media after 10 PM

Talk about one movie for an hour
```

### Rules

The conditions that explain what participating in the Play means.

Rules may describe:

* what participants should do
* when the activity happens
* how long it lasts
* what counts as completion
* restrictions or expectations
* how participants interact with each other

The rules give the behavior enough structure for different users to understand the same Play consistently.

### Poster

A visual representation of the Play.

The poster helps users recognize and discover the activity as content.

Together:

```text
Play
├── Title
├── Rules
└── Poster
```

form the minimum expression of a behavioral idea.

---

## Play Template

A behavioral idea can exist independently from any individual user's participation.

For example:

```text
"Read for 30 minutes every day"
```

is a behavior that many users may choose to perform.

The Play domain therefore distinguishes between the **definition of a behavior** and a person's actual participation in it.

The reusable definition can be understood as a **Play Template**.

A template answers:

> What is this behavior?

A user's participation answers:

> I chose to do this behavior.

This distinction allows one behavioral idea to be discovered, shared, reused, and played by many people.

---

## Playing

A Play becomes meaningful when a user chooses to participate in it.

The platform therefore has two related concepts:

```text
Play Template
    ↓
defines a behavior

Participation
    ↓
a user chooses to perform that behavior
```

Different Play modes may define participation differently.

For example:

```text
Challenge
→ commit to achieving something

Meetup
→ attend an activity with others

Chatting Session
→ join a conversation

Routine
→ repeatedly perform a behavior
```

The underlying Play remains behavioral content, while each mode defines additional rules around how that behavior is performed.

---

## Play Modes

The default Play model intentionally contains only the concepts that are broadly useful across different forms of behavior.

More specialized behavior is represented through **Play Modes**.

Conceptually:

```text
               Play
        title / rules / poster
                 │
        ┌────────┼────────┐
        ↓        ↓        ↓
    Challenge  Meetup    Chat
        ↓        ↓        ↓
   additional mode-specific concepts
```

A mode extends the meaning of a Play rather than replacing the base Play model.

For example, Challenge mode may introduce concepts such as:

* commitment
* success and failure
* verification
* a watcher or referee
* stakes
* final judgment

An offline meetup may instead introduce:

* location
* meeting time
* number of participants
* host
* attendance

A chatting mode may introduce:

* participants
* conversation duration
* topic
* communication channel

These concepts belong to their respective modes.

They should not become mandatory properties of every Play.

---

## Challenge Mode

The MVP begins with **Challenge Mode**.

A challenge is a Play in which a user commits to performing a behavior under explicit success or failure conditions.

For example:

```text
Play

Title
"Wake up before 7 AM for 7 days"

Rules
"Wake up before 7 AM every day for seven consecutive days."

Poster
[visual representation]

        +

Challenge Mode

Commitment
Verification
Success / Failure
Watcher
Stake
```

Challenge Mode therefore adds commitment-related behavior on top of the default Play.

It does not define the Play domain itself.

---

## Why Challenge Mode Comes First

The broader idea of a platform for behavioral content can initially be difficult for users to understand because it does not closely match an established product category.

The concept of a **challenge**, however, is already familiar.

People already understand ideas such as:

* taking a challenge
* committing to a goal
* succeeding or failing
* asking another person to verify the result
* putting something at stake to strengthen commitment

Challenge Mode therefore provides a concrete entry point into the broader behavioral platform.

The MVP uses the **commitment device** model because it gives users an immediately understandable reason to participate.

Conceptually:

```text
Initial product

Behavior Platform
        ↓
difficult to explain directly

Challenge
        ↓
familiar behavioral structure
        ↓
users experience the underlying Play model
```

Challenge is therefore the first product expression of the platform, not its final domain boundary.

---

## Domain Direction

The Play domain must remain independent from assumptions that are specific to Challenge Mode.

A Play should not inherently require concepts such as:

```text
stake
watcher
verdict
success
failure
payment
```

Those concepts may be essential to Challenge Mode, but they are not essential to behavioral content in general.

Otherwise, future modes would be forced into a challenge-shaped model.

For example, an offline meetup should not need an artificial success verdict simply because the original MVP started as a challenge product.

The domain should instead preserve this relationship:

```text
Play
    ↓
general behavioral content

Play Mode
    ↓
specialized participation model
```

This separation allows the platform to expand without redefining the meaning of Play.

---

## Long-Term Product Model

The long-term vision is a platform where behavioral ideas themselves can be created, discovered, shared, and performed.

A user may eventually browse behaviors in much the same way that they browse other forms of content.

For example:

```text
"I want something productive to do."

"I want to meet people."

"I want a difficult challenge."

"I want something fun to do tonight."

"I want a routine to follow."

"I want a conversation to join."
```

The platform can respond with Plays that represent those behaviors.

Different modes provide different structures for participation, while the core Play concept remains stable.

This makes the domain extensible:

```text
                Play
                 │
      ┌──────────┼──────────┐
      ↓          ↓          ↓
 Challenge    Meetup      Chat
      │
      ↓
    MVP
```

Additional modes can be introduced as the product discovers new useful ways for people to organize and share behavior.

---

## Core Principle

The Play domain should be modeled around the following principle:

> **Play is behavioral content. A mode defines how that behavior is played.**

Challenge Mode is the first implementation of this concept because it provides a familiar commitment model for the MVP.

The domain itself must remain broader than Challenge so that new behavioral modes can be introduced without redesigning the fundamental Play model.
