# ADR-003: Keep Supabase Storage During the Spring Backend Migration

## Status

Accepted

## Context

The existing frontend already uploads template images directly to Supabase Storage.

After the upload succeeds, the frontend obtains the stored image path and includes that path in the request sent to the application API.

The current migration is primarily focused on moving application APIs and business logic from Next.js and Supabase RPC functions into Spring Boot.

Replacing the image storage infrastructure at the same time would introduce an additional independent migration problem.

## Decision

Keep Supabase Storage as the image storage provider during the initial Spring backend migration.

The existing frontend upload flow will remain temporarily:

```text
Frontend
    ↓
Supabase Storage
    ↓
stored image path
    ↓
Spring REST API
    ↓
PostgreSQL
```

Spring APIs may accept an image storage reference such as `photoPath` or a more storage-neutral field such as `coverImageKey`.

The backend migration should not require replacing Supabase Storage.

## Rationale

Storage migration is not required to migrate the application's core business logic.

Keeping the existing storage flow reduces migration scope and allows work to remain focused on:

* REST API design
* Spring service logic
* persistence
* authentication
* transactions
* testing

Replacing working storage infrastructure during the same migration would increase risk without providing significant immediate value.

## Consequences

### Positive

* The backend migration remains smaller and easier to verify.
* Existing frontend image upload behavior can continue working.
* Spring application logic can be migrated independently from file infrastructure.
* Storage replacement can later be handled as a separate architectural change.

### Negative

* The frontend temporarily remains coupled to Supabase Storage.
* Image upload authorization and object lifecycle remain partially outside the Spring backend.
* The application temporarily depends on both Supabase infrastructure and the new Spring backend.

## Future Considerations

The storage implementation may later be replaced with an object storage service such as Amazon S3.

Storage-specific concepts should be prevented from spreading deeply into the domain model.

Where appropriate, use neutral concepts such as:

```text
objectKey
coverImageKey
imageReference
```

rather than making domain code depend directly on Supabase-specific APIs.
