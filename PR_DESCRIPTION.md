# Volunteer discovery + design system (no auth)

## Summary

Adds the **volunteer discovery** experience and **design system** from the product doc so the app has a usable slice while auth is built in parallel. Users can browse published events and open a detail screen that answers “am I comfortable showing up?” — when/where, what you’ll do, accessibility, contact, and role availability. RSVP is a placeholder CTA until auth lands.

## Why

- Lets us ship a coherent volunteer-facing flow (discover → event detail) without blocking on auth.
- Establishes the doc’s color and layout language so future screens stay consistent.
- When auth/RSVP are ready, we only wire the existing “Sign in to RSVP” button and data; list and detail stay as-is.

## What’s in this PR

### Design system (product doc §6)

- **Theme** – `Theme.swift` + asset colors: Coral Rose (primary/RSVP), Sky Teal (calendar/scheduling), Lavender Mist (tags), Cream (canvas), Soft Charcoal (text).
- **Layout** – Cards for events; sticky primary action on event detail; progressive sections (when/where, what you’ll do, accessibility, contact, roles).

### Discovery

- **Event list** (`EventListView`) – “Discover” screen with event cards: title → when/where → cause tags → spots left. Only published events; sorted by start time. Tap → event detail.
- **Event detail** (`EventDetailView`) – First-screen essentials:
  - When & where (date, time, timezone, full location)
  - What you’ll do (description)
  - Accessibility (notes + tags, e.g. step-free, fragrance-free)
  - Event contact (name, email, phone)
  - Roles (name, description, slots filled/total)
  - Sticky bottom bar: **“Sign in to RSVP”** (Coral Rose) — placeholder until auth exists.

### Data

- **AppStore** – `rolesByEvent` (from mock bundle); `organization(for:)`, `roles(for:)`, `publishedEvents` for list/detail. Firestore roles can be wired later (e.g. subcollection).

### Navigation

- **ContentView** – When loaded, shows `EventListView` as the main screen (volunteer home). Reload / Seed Firestore toolbar unchanged.

### Other

- **.gitignore** – `GoogleService-Info-1.plist` added and file untracked so it’s not committed.

## What’s not in this PR

- Auth or real RSVP flow — “Sign in to RSVP” is a placeholder.
- Filters (distance, date, cause tags) — doc’s “next” scope.
- Map/calendar discovery views — list only for now.

## How to test

1. Run with **mock** data source (default in dev): Discover shows 2 events; tap either → full detail with org, when/where, description, accessibility, contact, roles, and “Sign in to RSVP” bar.
2. Run with **Firestore**: Seed if needed; same flow. Role slots will show 0/0 until roles are stored in Firestore.

## Follow-ups

- Wire “Sign in to RSVP” to auth and RSVP flow when ready.
- Optionally fetch roles from Firestore (e.g. `events/{id}/roles`) when moving off mock.
- Add discovery filters (date, distance, tags) per product doc.
