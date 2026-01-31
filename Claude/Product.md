# Product Document (Feature Map + Detailed Description)

> This document describes what **The Product** does and provides a structured feature map you can use as a **Product Document / PRD backbone** to build a functional product.

---

The Product is a scheduling automation platform that replaces back-and-forth coordination with a booking experience driven by:

1. **Connected calendars** (to detect busy times)
2. **Availability rules** (working hours, buffers, limits, notice, etc.)
3. **Event types** (meeting templates: duration, location, hosts, questions)
4. **Booking surfaces** (shareable links + website embeds)
5. **Automations + integrations** (video links, reminders, routing, CRM updates)

### Core flow

**Host setup → Share link → Invitee picks a time → Booking confirmed + calendar event created → Notifications/automations run**

**Host sets availability boundaries**
- Working hours, days
- Buffers before/after
- Minimum notice
- Daily/weekly limits
- Timezone handling (invitee sees local time)

**Host defines event types**
- 15-min intro, 30-min demo, interview, etc.
- Each event type has: duration, location, questions, schedule, and policies

**Invitee books**
- Booking page displays real-time availability that respects:
  - Host rules
  - Existing busy blocks in connected calendars
  - Capacity and limits (for group events)

**Confirmation + conferencing**
- Calendar event created (and updated on reschedule)
- Video conference details inserted (Zoom/Teams/Meet) if connected
- Email confirmations + calendar invites (ICS)

**Team scheduling (key differentiators vs. simple schedulers)**
- **Round robin:** distribute meetings across a pool of hosts
- **Collective:** find times that work for multiple internal attendees
- **Routing forms:** ask intake questions first, then route to correct person/event
- **Meeting polls:** propose multiple options and let people vote/select

**Workflows**
- Reminders and follow-ups via email/SMS to reduce no-shows and standardize process

**Developer platform**
- APIs + webhooks to sync with CRM/ATS/support tools and internal systems

**Enterprise governance**
- SSO/SCIM, audit logs, retention policies, security controls

---

## 2) Product goals

**Primary goal:** Let a host publish bookable availability that an invitee can schedule against—without conflicts—while automating confirmations and follow-ups.

### Success metrics
- Booking completion rate (view → booked)
- Conflict rate (should be ~0)
- No-show rate (improves with reminders)
- Time-to-book (share → confirmed)
- Routing accuracy (for routing/round robin)

### Non-goals (for MVP)
- Marketplace/discovery
- Deep CRM/ATS feature parity (prefer hooks + integrations)
- Complex billing/proration (basic payments is sufficient)

---

## 3) Personas & permissions

1. **Invitee (external):** view slots, answer questions, book/reschedule/cancel
2. **Host (individual):** manage event types, availability rules, calendar connections
3. **Team admin:** manage users/teams, shared event types, assignment rules, reporting
4. **Org admin/IT:** SSO/SCIM, retention, audit, security/compliance controls

**Permissions model suggestion:** `Organization → Teams → Users → Event Types`

---

## 4) Domain model (suggested entities)

- **User**
- **Organization**
- **Team**
- **CalendarConnection** (provider, tokens, scopes)
- **AvailabilitySchedule** (weekly rules, exceptions, holidays)
- **EventType**
- **Booking** (status: booked / rescheduled / canceled / no-show)
- **Invitee** (name, email, timezone)
- **Question** / **Answer** (booking form + routing intake)
- **RoutingForm** + **RoutingRule**
- **RoundRobinPool** + assignment state
- **Workflow** (trigger + channel + template + timing)
- **NotificationLog**
- **WebhookSubscription** + **WebhookDeliveryLog**
- **AuditLog** (admin actions)
- **RetentionPolicy** / **DeletionRequest**

---

## 5) Modules & feature list (PRD-ready)

### A) Authentication & accounts

**MVP**
- Email/password + magic link
- Basic profile: name, photo, timezone, locale
- Workspace/org creation

**V1**
- OAuth sign-in (Google/Microsoft)
- Invitee login-less flows (tokenized links)

**Enterprise**
- SSO (SAML/OIDC), domain control, SCIM provisioning

---

### B) Calendar connections & sync

**MVP**
- Connect Google Calendar + Microsoft 365
- Read busy/free blocks
- Write events on booking (create/update/cancel)

**V1**
- Multiple calendars per user (overlay busy)
- Per-event-type calendar selection
- Conflict resiliency: double-check before write, retry, graceful fallback

**Key requirements**
- Incremental sync (provider webhooks where available; polling fallback)
- Token refresh + secure storage
- Rate limiting & exponential backoff per provider

---

### C) Availability engine (the “brain”)

This is the most critical part.

**MVP rules**
- Weekly working hours
- Slot duration per event type
- Buffers before/after meetings
- Minimum notice (e.g., cannot book within 2 hours)
- Daily/weekly booking limits
- Time zone support (invitee local display; canonical storage)

**V1**
- Date-specific overrides (vacation, special hours)
- Holiday calendars
- Busy rules (count tentative? OOO? configurable)

**Algorithm expectations**
- Efficient slot generation (cacheable, deterministic)
- Always revalidate provider busy state at booking time
- Idempotent booking writes (avoid duplicates)

---

### D) Event types

**MVP**
- 1:1 meeting event type
- Settings:
  - Name, description
  - Duration
  - Location type (phone, in-person, video, custom)
  - Questions (booking form)
  - Cancellation policy
  - Scheduling limits (notice, buffers, max/day)

**V1**
- Group event (1 host, many invitees; capacity)
- Collective (multiple internal required attendees)
- Round robin (pool of hosts; assignment rules)
- Meeting polls

**Templates**
- Pre-built templates for common workflows (sales, recruiting, onboarding)

---

### E) Booking surfaces (link + embeds)

**MVP**
- Public booking page per event type
- Shareable short link
- Embed options:
  - Inline embed
  - Popup widget
  - “Book” button

**V1**
- Branding: logo/colors, custom domain, custom URL slug
- Tracking params capture (UTM + referrer)
- Optional A/B hooks

---

### F) Booking lifecycle (reschedule/cancel + ICS)

**MVP**
- Book → confirm → create calendar event
- Reschedule (preserve booking ID chain)
- Cancel (host/invitee)
- Email confirmation + ICS

**V1**
- Cancellation reasons
- No-show tracking (manual or automated)
- Waitlist (for group/capacity events)

---

### G) Conferencing & locations

**MVP**
- Static location text (phone/address/instructions)
- Generic meeting link field

**V1**
- Connect Zoom/Teams/Meet and auto-insert details
- Per-event-type location choices

---

### H) Workflows / automations

**MVP**
- Email reminders (e.g., 24h + 1h before)
- Follow-up email after meeting

**V1**
- SMS reminders + time windows
- Conditional workflows based on event type and answers
- Webhook-triggered custom workflows

---

### I) Routing forms (intake → correct host)

**V1 (high value for sales/recruiting)**
- Pre-booking form (intake questions)
- Rules engine:
  - Example: if `Company size > 50` route to `Team A`, else `Team B`
- Availability-aware routing (don’t route to someone unavailable)
- Fallback to round robin pool

---

### J) Team scheduling & assignment

**V1**
- Teams, roles, shared event types
- Round robin pools with rules:
  - rotate
  - weighted
  - least-recent
  - priority tiers
- Collective scheduling across multiple internal calendars

---

### K) Reporting & analytics

**MVP**
- Bookings by event type
- Cancel/no-show counts
- Popular time-of-day and day-of-week

**V1**
- Routing performance + funnel conversion
- Time-to-book metrics
- CSV export
- Admin dashboard (org/team level)

---

### L) Integrations ecosystem

**MVP**
- Google/Microsoft calendar
- Webhooks (booked/canceled/rescheduled)

**V1**
- Slack notifications
- Payments provider (Stripe, etc.)
- CRM/ATS via native integration or Zapier/Make-style connector

---

### M) Developer platform (API + webhooks)

**V1**
- REST API for: users, event types, bookings
- Webhooks for: booking created/updated/canceled, invitee created, routing submitted
- Delivery retries + signing secrets
- Event versioning + idempotency keys
- Rate limits + API keys/OAuth

---

### N) Security, privacy, and compliance

**Baseline**
- Encryption at rest/in transit
- Least privilege scopes per integration
- Admin audit trails: who changed what and when

**Governance (Enterprise)**
- Data retention policies
- Data deletion tooling
- Advanced audit logs
- SSO/SCIM controls

---

## 6) Suggested scope cuts (ship plan)

### MVP (strong “replica core”)
- 1:1 event types
- Google + Microsoft calendar read/write
- Availability rules: working hours, buffers, min notice
- Booking page + shareable link
- Confirmation + ICS + reschedule/cancel
- Basic reminders (email)
- Basic admin + reporting

### V1
- Team features: round robin, collective
- Routing forms
- Workflows (email + SMS)
- Webhooks + API
- Branding + embed variants

### Enterprise later
- SSO/SCIM, retention policies, advanced audit controls

---

## 7) Open decisions (fill in for your build)

- Is this for **internal use** or **SaaS**?
- Target user: **solo**, **small team**, or **routing-heavy sales org**?
- Which calendar providers must be supported first: Google, Microsoft, Apple?
- Notification channels: email only (MVP) vs email+SMS (V1)?
- Multi-tenant architecture needs (SaaS) vs single-tenant (internal)?

