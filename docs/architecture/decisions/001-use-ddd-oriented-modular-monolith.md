# ADR-001: Use a DDD-Oriented Modular Monolith Architecture

## Status

Accepted

## Context

The backend is being migrated from a Next.js, Supabase, and Supabase Edge Function architecture to Spring Boot.

The application contains several distinct business concerns, including:

* Play
* User
* Profile
* Notification
* Security
* Payment

Payment functionality is already part of the existing system. The current implementation uses Lemon Squeezy together with frontend API routes and Supabase Edge Functions.

The new Spring backend should provide clearer domain boundaries while avoiding the operational complexity of prematurely introducing microservices.

Domain-Driven Design concepts are also being applied to organize the application around cohesive business responsibilities rather than around global technical layers.

## Decision

Use a modular monolith organized using DDD-oriented domain boundaries.

The initial module classification is:

```text
Core
└── Play

Supporting
├── User
├── Profile
└── Notification

General
├── Security
└── Payment
```

These classifications describe the role of each domain/module in the application.

Individual modules may contain their own aggregates, entities, value objects, repositories, domain services, application services, and infrastructure components.

The application will initially be deployed as a single Spring Boot process while maintaining explicit boundaries between modules.

Cross-module dependencies should be minimized and should follow intentional dependency directions rather than arbitrary access to another module's internals.

## Rationale

### Domain Cohesion

The modular structure is intended to increase cohesion inside each domain and reduce coupling between unrelated business concerns.

The Play domain contains the application's core product behavior and should be able to evolve with minimal dependency on supporting or general-purpose functionality.

Supporting domains exist primarily to enable the core domain, while general-purpose domains provide capabilities that are not unique to the Play business model.

### Operational Simplicity

The current application size does not justify the operational cost of microservices.

Keeping the application as one deployable unit provides:

* simpler deployment
* easier local development
* straightforward debugging
* ordinary database transactions where appropriate
* lower infrastructure complexity

while still allowing the internal architecture to express meaningful domain boundaries.

### Future Scaling

The modules may have different scaling requirements.

For example, if traffic to the Play domain becomes significantly higher than traffic to Profile, Notification, or other domains, running all modules within the same application process may cause unrelated functionality to compete for CPU, memory, connection pools, or other resources.

If this becomes an actual operational problem, the Play module can become a candidate for extraction into a separately deployed service.

Separating the domain boundary before such scaling pressure occurs reduces the architectural work required if physical separation later becomes justified.

## Messaging and Consistency Strategy

The modular monolith will also be used to explore asynchronous communication patterns such as:

* domain/application events
* RabbitMQ
* transactional outbox
* eventual consistency
* reliable message delivery

The purpose is not to introduce distributed-system complexity where it is unnecessary.

Instead, these patterns can be introduced at selected module boundaries where asynchronous communication provides useful architectural separation or educational value.

The transactional outbox pattern can be used when a database state change and an outgoing event must remain consistent.

This provides practical experience with patterns commonly used in distributed systems while preserving the simpler deployment model of a modular monolith.

If modules are later extracted into separate processes, existing explicit messaging boundaries can reduce the amount of redesign required.

## Consequences

### Positive

* Business domains have visible boundaries.
* Cohesion inside each module is increased.
* Dependencies between domains can be controlled explicitly.
* The deployment model remains simple.
* Most operations can continue using ordinary Spring/database transactions.
* Asynchronous integration patterns can be introduced selectively.
* Modules with different scaling requirements can later be considered for independent deployment.

### Negative

* Module boundaries are still primarily enforced through architecture and code structure.
* All modules initially share the same application process and therefore share some infrastructure resources.
* Poor dependency discipline could gradually turn the system into a tightly coupled monolith.
* Introducing messaging inside a monolith adds complexity and should therefore be justified per use case.

## Future Considerations

A module should not be extracted into a microservice merely because the boundary already exists.

Physical separation should be driven by concrete requirements such as:

* substantially different traffic patterns
* independent scaling requirements
* different availability requirements
* deployment independence
* fault isolation
* organizational ownership

The modular monolith is therefore the default architecture, while service extraction remains an available response to demonstrated operational needs.
