# Project Gay • Development Agents

Agents in this doc are **development agents**—roles or AI collaborators that create the **VolunQueer iOS app**. They are not end-user personas. For full product context, see `Project_Gay_Product_Doc.pdf`.

---

## What we're building (context for agents)

**Project Gay / VolunQueer** is a volunteer coordination iOS app that strengthens LGBTQ+ community life by creating repeatable, welcoming **third-space** moments. Two primary user types: **volunteers** (discover, RSVP, calendar, reminders, show up) and **organizers** (post events, rosters, communication, impact). Design principles: low friction, consent-forward, safety visible, community first. The app is lightweight event posting + sign-up + calendar + reminders; not a full CRM or social feed.

**MVP goal (10-hour timebox):** One organizer posts an event → one volunteer discovers it → RSVPs → sees it on calendar → organizer views roster. Must ship: basic auth, create event (single role + cap), event list + detail, RSVP + cancel, organizer roster, add-to-calendar (ICS), basic email reminder.

---

## Development Agents

### Product / Scope Agent

- **Owns:** Interpreting the product doc, MVP scope, and “what we’re building.”
- **Does:** Keeps the vertical slice in focus; flags scope creep; answers “is this in MVP?” Uses the product doc as source of truth for flows, jobs-to-be-done, and north-star outcomes.
- **Does not:** Implement UI or backend; it informs other agents so they build the right thing.
- **Rule of thumb:** Overbuilding the organizer console is the classic trap. Nail posting, rosters, and communication first.

### iOS App Agent

- **Owns:** The VolunQueer Xcode project, SwiftUI views, navigation, and native iOS patterns.
- **Does:** Implements screens and flows (event list, event detail, RSVP, roster, calendar). Uses SwiftUI, follows platform HIG and accessibility. Keeps the app lightweight and maintainable.
- **Consumes:** Scope from Product agent; design tokens and patterns from UI agent; data/auth contracts from Auth & data agent.
- **Tech:** Swift, SwiftUI, Xcode. Target: iOS; consider iPhone-first with clear information hierarchy (e.g. event page answers where/when/what/accessibility in first screenful).

### UI / Design System Agent

- **Owns:** Visual and interaction design of the app: colors, typography, layout patterns, components, accessibility.
- **Does:** Applies the product doc’s design language: Coral Rose (primary actions), Sky Teal (calendar/scheduling), Lavender Mist (tags), Cream (canvas), Soft Charcoal (text). Ensures contrast and readability. Implements patterns: cards for events, sticky primary action (e.g. RSVP on mobile), progressive disclosure, calendar as first-class citizen. Places mascot (otter) in onboarding, empty states, success states, nudges.
- **Does not:** Define product scope or implement business logic; it makes the iOS app match the approved look, feel, and tone (welcoming, calm, practical; microcopy friendly and precise).
- **Reference:** Product doc Sections 6 (UI/UX) and 7 (mascot).

### Auth & Data Agent

- **Owns:** Authentication (magic link or OAuth), event/volunteer/roster data, and any backend or BaaS integration.
- **Does:** Implements basic auth so organizers and volunteers can sign in. Defines and implements data needed for: events (title, date, location, roles, cap), RSVPs, roster view, add-to-calendar (ICS). Ensures consent-forward data: minimal required fields; clear visibility of what organizers see. Handles basic email reminder (MVP) and future SMS/push if scoped.
- **Does not:** Own product copy or UI layout; it exposes APIs/contracts the iOS app agent uses.
- **MVP focus:** Auth, create/read events, RSVP + cancel, roster, ICS export, one reminder path.

### QA / Testing Agent

- **Owns:** Validating the vertical slice and critical flows.
- **Does:** Confirms end-to-end flow: organizer creates event → volunteer discovers → RSVPs → sees on calendar → organizer sees roster. Checks RSVP + cancel, add-to-calendar, and basic reminder. Flags regressions and accessibility issues.
- **Does not:** Define scope or implement features; it ensures what we ship matches the MVP goal and remains usable.

---

## Agent interactions

```
                    ┌─────────────────────┐
                    │  Product / Scope    │
                    │  Agent              │
                    │  (doc, MVP, scope)  │
                    └──────────┬──────────┘
                               │
         ┌─────────────────────┼─────────────────────┐
         │                     │                     │
         ▼                     ▼                     ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│  iOS App Agent  │  │  UI / Design     │  │  Auth & Data     │
│  (SwiftUI,      │  │  System Agent    │  │  Agent           │
│   flows, nav)   │  │  (colors,        │  │  (auth, events,  │
│                 │  │   layout, a11y)  │  │   RSVP, roster)  │
└────────┬────────┘  └────────┬────────┘  └────────┬────────┘
         │                    │                     │
         └────────────────────┼─────────────────────┘
                              │
                              ▼
                    ┌─────────────────────┐
                    │  QA / Testing Agent  │
                    │  (vertical slice,    │
                    │   flows, a11y)       │
                    └─────────────────────┘
```

---

## MVP scope (target for agents)

| Must ship (vertical slice)     | Nice if time remains        | Later / Phase 2                    |
|--------------------------------|-----------------------------|------------------------------------|
| Basic auth (magic link or OAuth)| Role slots / multiple roles | Waitlists + auto-promote           |
| Create event (single role + cap)| Simple search + tags        | Recurring events + templates       |
| Event list + event detail      | Volunteer profile (name/pronouns optional) | Messaging (SMS/push)      |
| RSVP + cancel RSVP             | Lightweight admin view      | Check-in / attendance capture      |
| Organizer roster view          |                             | Impact dashboards + badges         |
| Add-to-calendar (ICS)          |                             | Organizer verification + moderation|
| Basic email reminder           |                             |                                    |

---

## References for agents

- **Product doc:** `Project_Gay_Product_Doc.pdf` — purpose, users, flows, feature deep dive, MVP, UI/UX, mascot, safety/privacy/accessibility.
- **Codebase:** `VolunQueer/` — SwiftUI app (e.g. `ContentView.swift`, `VolunQueerApp.swift`), assets, Xcode project.
- **Design:** Coral Rose, Sky Teal, Lavender Mist, Cream, Soft Charcoal. Cards, sticky primary action, progressive disclosure. Mascot: otter (onboarding, empty/success states, nudges).

---

## Future development (out of MVP)

Agents may later work on: waitlists and auto-promote, recurring events and templates, SMS/push messaging, check-in and attendance capture, impact dashboards and badges, organizer verification and moderation, safety/accessibility enhancements, and richer onboarding flows.
