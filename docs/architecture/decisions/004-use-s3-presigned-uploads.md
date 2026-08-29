# ADR-004: Use Presigned Direct Uploads for Future S3 Image Storage

## Status

Proposed

## Context

Template images and other media should eventually be stored independently from the Spring Boot application server.

Sending image bytes through the application server is simple, but it causes the Spring server to consume bandwidth and resources for data that ultimately belongs in object storage.

Direct client uploads reduce this load, but unrestricted client access to object storage would weaken application-level authorization.

Amazon S3 supports presigned URLs, allowing the backend to authorize a specific storage operation without transferring the image bytes through the application server.

## Decision

When Supabase Storage is eventually replaced with Amazon S3, prefer a presigned direct-upload workflow.

The intended flow is:

```text
1. Client requests permission to upload an image.

2. Spring authenticates the user and validates the intended operation.

3. Spring generates an object key and a short-lived presigned S3 upload URL.

4. Spring returns the upload URL and object key to the client.

5. The client uploads the image bytes directly to S3.

6. The client sends the resulting object key as part of the application request.

7. Spring validates the reference and stores it with the corresponding domain object.
```

Conceptually:

```text
Client ── upload permission request ──> Spring
                                         ↓
                                      AWS SDK
                                         ↓
Client <──── presigned URL ───────────── S3

Client ───────── image bytes ──────────> S3

Client ───── business request ────────> Spring
                                         ↓
                                     PostgreSQL
```

## Rationale

This approach separates application authorization from binary data transfer.

Spring remains responsible for business decisions such as:

* whether the user may upload
* what type of resource the image belongs to
* allowed file types
* maximum file size
* object naming
* ownership
* expiration of upload permission

S3 remains responsible for receiving and storing the actual bytes.

This avoids routing large file payloads through the Spring application server while preserving backend control over upload authorization.

## Consequences

### Positive

* Image bytes do not consume application-server bandwidth.
* Upload traffic can scale independently from the Spring server.
* Spring retains control over application-level authorization.
* S3 credentials do not need to be exposed to the client.
* Upload permissions can be short-lived and restricted to specific object keys.

### Negative

* The upload process becomes a multi-step client workflow.
* Uploaded objects can become orphaned if the later database operation fails.
* Cleanup and object lifecycle policies may be required.
* Storage and database operations cannot share a normal relational database transaction.

## Security Considerations

Application authorization and infrastructure authorization are separate concerns.

Spring determines:

```text
Is this user allowed to upload this image for this application resource?
```

AWS IAM determines:

```text
What operations is the Spring application itself allowed to perform against S3?
```

The client should never receive permanent AWS credentials.

Presigned upload permissions should be limited by operation, object key, and expiration time.

## Future Considerations

A storage abstraction may be introduced if storage logic becomes significant:

```java
public interface ImageStorage {
    UploadTarget createUploadTarget(...);
    void delete(...);
}
```

An S3-backed implementation can then use the AWS SDK without coupling application business logic directly to S3 APIs.

Image transformation, thumbnail generation, or format conversion may later be handled asynchronously through separate infrastructure if required.
