# Tapped Backend

Spring Boot backend reimplementation of Tapped.

This project migrates Tapped's existing Supabase-based backend to a Spring Boot modular monolith to practice and demonstrate backend architecture, domain modeling, security, messaging, and testing.

## Goals

- Reimplement the existing Tapped backend with Spring Boot
- Define explicit domain/module boundaries using DDD concepts
- Apply schema-level data ownership between modules
- Implement authentication and authorization with Spring Security
- Explore asynchronous module communication with RabbitMQ
- Add automated tests as a first-class part of development

## Architecture

- Java
- Spring Boot
- PostgreSQL
- Spring Data JPA
- Spring Security
- RabbitMQ
- Gradle

Architecture style:

- Modular Monolith
- Domain-oriented modules
- Schema-per-module database organization
- Synchronous module calls where immediate consistency is required
- Domain/integration events for asynchronous consequences

## Current Status

Early development.

Current focus:

- Define Play domain boundaries
- Implement the Play creation flow
- Establish database schema/module ownership rules

## Project Structure

Planned structure:

```text
games.tapped
├── play
├── profile
├── notification
├── payment
└── auth
