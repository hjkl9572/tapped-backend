# User Domain

## Overview

The User domain represents a person as a participant in the application.

Its purpose is to provide a stable application-level identity that other domains can refer to.

A User answers:

> Who is performing this action?

The User domain does not own the behavioral content that a person creates or participates in.

For example, Plays created or joined by a user still belong to the Play domain even when they are displayed as part of that user's page.

---

## User as Application Identity

A user is the common identity shared across the application.

Other domains may associate their own concepts with a user.

For example:

```text
User
├── creates Play
├── participates in Play
├── has Profile
├── receives Notification
└── performs Payment
```

These relationships do not mean that the User domain owns those concepts.

Instead, User provides the identity around which different domain activities can be associated.

---

## Domain Responsibility

The User domain should remain focused on concepts that belong to the existence and lifecycle of an application user.

Examples may include:

* application user identity
* account existence
* account state
* creation of a user account
* removal or deactivation of an account
* basic user-level policies shared across the application

Presentation-oriented information such as nickname, biography, profile image, or other public-facing attributes belongs to the Profile domain when that distinction is useful.

Behavioral content belongs to the Play domain.

---

## User and Play

A user may create, discover, join, or complete Plays.

However:

> A Play does not become part of the User domain merely because it belongs to or is displayed under a user.

For example, a user's page may display:

```text
Nickname
Introduction
Profile image

Created Plays
Joined Plays
Recent Play activity
```

This page combines information from multiple domains.

Conceptually:

```text
User page
├── User/Profile information
└── Play information
```

The frontend page is a composition of domain data rather than a domain boundary itself.

---

## Cross-Domain Relationships

The User domain acts as a reference point for many other domains.

For example:

```text
Play
→ created by User

Payment
→ initiated by User

Notification
→ delivered to User

Profile
→ describes User
```

Each domain owns its own behavior and rules.

User provides the stable identity used to establish those relationships.

This keeps business responsibilities separated while still allowing the application to present them together.

---

## Domain Size

The User domain is intentionally small.

A domain does not need to contain complex behavior if the business concept itself is simple.

The User domain should not absorb unrelated responsibilities merely to make it larger.

Keeping User small prevents it from becoming a generic container for:

* profiles
* social activity
* play history
* payments
* notifications
* authentication-provider details

Those concerns should remain in the domains that own their meaning.

---

## Core Principle

> **User represents who participates in the application. It does not own everything associated with that person.**

Other domains may reference the User, while retaining ownership of their own concepts and business rules.
