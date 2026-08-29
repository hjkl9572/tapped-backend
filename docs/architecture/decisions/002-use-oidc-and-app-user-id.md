# ADR-002: Use OIDC for Authentication and AppUser ID as the Application Identity

## Status

Accepted

## Context

The previous application relied on Supabase Auth and Google OAuth authentication.

The Spring Boot migration moves authentication responsibility into the Spring Security layer rather than continuing to depend on Supabase Auth.

Google supports OpenID Connect and provides a stable provider-specific subject identifier through the `sub` claim.

The application may support additional OpenID Connect providers in the future.

Using provider-specific identifiers throughout application code would couple domain logic and authorization logic to external identity providers.

Email is also unsuitable as a primary identity because it is a mutable user attribute.

The application therefore needs to distinguish between:

1. the identity used to authenticate a user with an external provider, and
2. the identity used internally after authentication succeeds.

## Decision

Use OpenID Connect provider identity only at the authentication boundary.

For Google authentication, the external identity is represented by:

```text
provider
provider_subject
```

where:

```text
provider_subject = OIDC `sub`
```

The `sub` claim is used to locate or establish the corresponding application user.

Once the external identity has been mapped to an `AppUser`, the application's canonical user identifier is:

```text
app_users.id
```

Application authorization and business logic should use `app_users.id` rather than the provider's `sub`.

Conceptually:

```text
Google
  ↓
OIDC authentication
  ↓
provider + sub
  ↓
CustomOidcUserService
  ↓
AppUser
  ↓
app_users.id
  ↓
Authentication / SecurityContext
  ↓
application logic
```

## Authentication Boundary

Spring Security handles the OAuth2/OpenID Connect protocol flow and delegates identity verification to the configured provider.

`CustomOidcUserService` is responsible for mapping the authenticated OIDC identity into the application's user model.

Its responsibility includes locating or creating the corresponding `AppUser` using the external provider identity.

Conceptually:

```text
OIDC provider identity

("google", "provider-subject")
        ↓

CustomOidcUserService
        ↓

AppUser
id = application UUID
```

After this mapping has succeeded, application code should not need to identify the current user using Google's `sub`.

Instead, the authenticated principal represented in `Authentication` should expose the application's own user identity.

The resulting `SecurityContext` therefore represents the authenticated user primarily in terms of the application's identity model.

## Rationale

### Stable Application Identity

External providers have their own identity namespaces.

For example:

```text
Google sub: abc123
Provider B sub: abc123
```

These values do not represent the same user unless the application explicitly establishes that relationship.

Using `app_users.id` provides one canonical identifier inside the application regardless of authentication provider.

### Provider Decoupling

Provider-specific identity is required when authenticating or re-authenticating the user.

However, once authentication succeeds, business code should not depend on whether the user authenticated through:

```text
Google
Provider B
Provider C
```

Application code should instead see:

```text
currentUserId = app_users.id
```

This establishes the provider integration as a boundary around authentication rather than allowing provider-specific concepts to spread through the domain.

### Future Provider Support

If another OpenID Connect provider is added later, its identity can be mapped through the same boundary:

```text
Google ───────┐
              │
GitHub/OIDC ──┼─> external identity mapping
              │
Other OIDC ───┘
                    ↓
                 AppUser
                    ↓
               app_users.id
```

The rest of the application does not need a different user-identification strategy for each provider.

## Dependency Boundary

The application still depends on the external provider whenever authentication through that provider occurs.

The architectural boundary is therefore not:

> the provider is only needed during the user's first login.

Instead:

> provider-specific identity is confined to the authentication and account-mapping boundary.

After successful authentication, internal authorization and domain operations use the application's own user ID.

The provider subject must still be retained so that future login attempts can be mapped back to the same `AppUser`.

## Consequences

### Positive

* `app_users.id` becomes the single application-level user identifier.
* Domain logic does not depend on Google-specific identity.
* SecurityContext can expose a consistent identity regardless of OIDC provider.
* Additional providers can be integrated without changing application-level identification.
* Mutable attributes such as email are not used as identity keys.
* External authentication concerns remain concentrated in the security boundary.

### Negative

* An explicit mapping between provider identity and `AppUser` must be maintained.
* Authentication code becomes slightly more complex than simply using the raw OIDC principal everywhere.
* Multiple-provider account linking will require additional rules if introduced later.

## Future Considerations

If multiple authentication providers are supported for the same application user, the provider identity mapping may eventually require a separate model such as:

```text
app_user
    1
    ↓
    N
external_identity
├── provider
├── provider_subject
└── app_user_id
```

That change should only be introduced when multiple identities per user become an actual requirement.

Regardless of the storage model, the application should preserve the same principle:

> External identity proves who authenticated. `AppUser.id` identifies who the application is operating on behalf of.
