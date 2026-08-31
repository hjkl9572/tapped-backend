# Payment Domain

## Overview

The Payment domain represents monetary transactions performed as part of the application's business flows.

Its purpose is to manage when money is requested, paid, refunded, or otherwise changed as a consequence of an application action.

Payment is not itself the core product.

It supports other domains when a behavior requires a monetary commitment or transaction.

---

## Payment as a Supporting Capability

A Play may optionally introduce payment-related behavior.

For example, Challenge Mode may use money as part of a commitment device.

Conceptually:

```text
Play
    ↓
Challenge Mode
    ↓
requires monetary commitment
    ↓
Payment
```

The Play domain determines **why** a payment is required.

The Payment domain determines **how the monetary transaction is represented and processed**.

This distinction prevents payment-provider concepts from becoming part of the Play model.

---

## Domain Responsibility

The Payment domain may represent concepts such as:

* payment request
* amount
* payment status
* successful payment
* failed payment
* refund
* cancellation
* external payment reference

Its responsibility is to provide a consistent application-level representation of a monetary transaction.

It should not determine the behavioral meaning of that transaction.

For example:

```text
Challenge domain decision:
"Failure requires this payment."

Payment domain responsibility:
"Process and record the required payment."
```

---

## Relationship with Other Domains

Payment is usually initiated because another domain requires it.

For example:

```text
User
  ↓ participates in
Play
  ↓ defines a monetary condition
Payment
```

The Payment domain may therefore refer to:

* the User performing the transaction
* the business operation that caused the transaction
* the amount and currency
* the resulting payment state

However, the rules that determine whether a payment should happen remain in the domain that owns the originating business behavior.

---

## External Payment Provider

The current application uses **Lemon Squeezy** as its payment provider.

Lemon Squeezy is responsible for the external payment infrastructure needed to execute monetary transactions.

The application's Payment domain should treat Lemon Squeezy as an external provider rather than as the definition of payment itself.

Conceptually:

```text
Application Payment
        ↓
Payment Provider
        ↓
Lemon Squeezy
```

This keeps the application-level meaning of a payment separate from provider-specific behavior.

---

## Provider Independence

Application concepts should prefer provider-neutral language where practical.

For example:

```text
Payment
PaymentStatus
ExternalPaymentId
Refund
```

rather than making Lemon Squeezy-specific terminology part of the general domain model.

This does not require building a complex payment abstraction prematurely.

The current system may depend directly on Lemon Squeezy where appropriate.

The important boundary is conceptual:

> The application owns the meaning of the transaction; Lemon Squeezy executes the external payment operation.

---

## Current Scope

The current payment flow is intentionally limited.

The Payment domain exists to support the payment requirements of the current product rather than to become a general-purpose billing system.

Features such as:

* subscriptions
* invoicing
* complex ledger accounting
* multiple payment providers
* advanced settlement logic

are outside the domain unless future product requirements introduce them.

---

## Core Principle

> **Payment represents monetary consequences of application behavior. Other domains decide why payment is needed; the Payment domain manages the transaction itself.**

Lemon Squeezy is the current external provider used to execute those transactions.
