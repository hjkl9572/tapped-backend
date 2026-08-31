# Profile Domain

## Overview

The Profile domain represents how a user is presented within the application.

A User represents the stable application identity of a person.

A Profile represents the information used to describe and present that person to themselves and to other users.

Conceptually:

```text
User
→ Who is this application participant?

Profile
→ How is this participant presented?
```

The Profile domain is separate from Play.

A profile page may display Play content associated with a user, but those Plays and Play Cards remain owned by the Play domain.

---

## User and Profile

The User domain provides the application's stable identity.

For example:

```text
User
├── user ID
├── account existence
└── account lifecycle
```

The Profile domain contains presentation-oriented information associated with that identity.

For example:

```text
Profile
├── nickname
├── introduction
├── profile image
└── other public-facing user information
```

The exact set of profile fields may evolve as the product develops.

The important distinction is:

> User represents application identity. Profile represents the user's presentation within the product.

A Profile therefore depends on a User identity, but the User domain does not need to own profile presentation behavior.

---

## Profile as Presentation

Profiles allow people to recognize and understand other participants.

A Profile may answer questions such as:

* Who created this Play Card?
* What name does this person use in the application?
* What does this person say about themselves?
* What image represents this person?

This information may appear in several places throughout the application.

For example:

```text
Profile page
Play Card
Leaderboard
Personal feed
Final Call
```

The fact that profile information is embedded in Play-related views does not transfer that information into the Play domain.

Instead, Play content may reference or compose Profile information when presenting its creator or participant.

---

## Profile Page

A profile page may combine information from multiple domains.

For example:

```text
Profile page

Profile domain
├── nickname
├── introduction
└── profile image

Play domain
├── created Play Cards
├── participated Plays
└── other Play activity
```

This composition is a frontend or query concern rather than evidence that Profile and Play belong to the same domain.

The Profile domain owns the descriptive information about the user.

The Play domain owns the behavioral content associated with that user.

---

## Current User Perspective

The application may expose APIs under a `/me` route to indicate that the requested resource belongs to the currently authenticated user.

For example:

```text
/me/profile-card
/me/personal-feed
```

`me` is not a domain concept.

It is an API perspective meaning:

> Resolve this resource using the currently authenticated application user.

Therefore:

```text
/me/profile-card
→ Profile domain

/me/personal-feed
→ Play domain
```

The domain is determined by the resource being returned and the business meaning of the operation, not by the `/me` prefix.

---

## Profile Card

A Profile Card is a compact representation of Profile information intended to identify or summarize a user within another view.

For example, it may be used:

* on a personal page
* alongside Play Cards
* in other user-facing summaries

A Profile Card should contain profile information required for presentation rather than Play activity itself.

If a UI combines a Profile Card with Play statistics or Play Cards, those additional values may be composed from the Play domain without changing ownership of the underlying concepts.

---

## Relationship with Play

Play content is frequently associated with a user.

For example:

```text
User
    ↓
has Profile

User
    ↓
creates
Play Card
```

The Profile may be shown together with the Play Card:

```text
Play Card
├── behavioral content      → Play domain
└── creator presentation    → Profile domain
```

This is normal cross-domain composition.

The Play domain may need an application user identifier to associate behavioral content with its creator, but it should not become responsible for maintaining nickname, introduction, or profile-image state.

Likewise, the Profile domain should not own Play Cards merely because they appear beneath a user's profile.

---

## Profile Domain Responsibility

The Profile domain is responsible for the user's presentation-oriented information.

Its responsibilities may include:

* retrieving a user's profile
* retrieving the current user's profile
* creating or initializing profile information
* updating profile information
* producing a compact Profile Card representation
* enforcing profile-specific constraints

It should not be responsible for:

* authentication
* OAuth/OIDC provider identity
* application account identity
* Play creation
* Play Card creation
* personal feeds
* leaderboard ranking
* payments

Those belong to their respective domains.

---

## Cross-Domain Composition

Some application responses may require information from more than one domain.

For example:

```text
Personal page
        ↓
┌──────────────────────┐
│ Profile              │
│ nickname             │
│ introduction         │
│ profile image        │
├──────────────────────┤
│ Play                 │
│ Play Card            │
│ Play Card            │
│ Play Card            │
└──────────────────────┘
```

This does not require merging the Profile and Play domains.

The application may compose multiple domain responses at an appropriate query or presentation boundary.

Domain ownership should follow the meaning of the data rather than the screen on which the data happens to appear.

---

## Core Principle

> **User defines who the participant is. Profile defines how the participant is presented. Play defines what the participant does.**

A single page or API experience may combine all three, but their business responsibilities remain separate.
