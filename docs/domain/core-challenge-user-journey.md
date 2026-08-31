## Challenge User Journey(MVP)

The MVP user journey is centered on Challenge Mode, while preserving the broader Play model underneath it.

A user moves through the Play domain roughly as follows:

```text
Discover or create a Play
        ↓
Configure Challenge Mode
        ↓
Start the Play
        ↓
Tap and create Play Cards
        ↓
Referee reviews the activity
        ↓
Referee gives a verdict
        ↓
Challenger responds to the verdict
        ↓
Play Cards remain part of the user's activity
        ↓
Selected cards may be surfaced to other users
```

### 1. Discovering and Creating Plays

The main page is the primary entry point into the Play domain.

Users can:

* browse existing Play Templates
* select a Play they want to participate in
* customize an existing Play Template
* create a new Play Template

The page presents several template options together with a form for defining or modifying a Play.

A Play Template represents the behavior itself:

```text
Title
Rules
Poster
```

Challenge-specific configuration is added only when the user chooses to participate through Challenge Mode.

The main page also surfaces successful and failed Play Cards through two leaderboards.

These leaderboards provide examples of how other users have participated in Plays and make behavioral activity itself discoverable as content.

---

### 2. Configuring a Challenge

For the MVP, users primarily participate in Plays through Challenge Mode.

After choosing what they want to challenge themselves to do, the challenger configures additional commitment-related conditions.

These include:

* the Play they are committing to
* the amount they want to stake
* the person who will act as referee

The Play defines the behavior.

Challenge Mode adds the commitment mechanism around that behavior.

Conceptually:

```text
Play
"What am I going to do?"

        +

Challenge
"Under what commitment conditions will I do it?"
```

The cadence and duration of a challenge are not fixed globally.

Different challenges may proceed at different speeds depending on the behavior itself and the agreement between the challenger and referee.

---

### 3. Inviting the Referee

A challenge includes a referee who eventually evaluates the challenger's activity.

The challenger can invite the referee by sharing either:

* an email invitation
* a direct link to the referee experience

The referee does not need to participate in the Play in the same way as the challenger.

Their role is to understand the challenge, inspect the challenger's recorded activity, and eventually make a decision.

---

### 4. Playing Through Taps

Once a challenger has started a Play, they interact with it through **Tapping**.

A Tap represents the user's decision to engage with a Play at a particular moment.

For the Challenge MVP, tapping is intentionally simple.

The user selects a Play they previously started and taps its Play Card or entry.

```text
Existing Play
    ↓
Tap
    ↓
record activity
```

Tapping activates the creation of a new Play Card.

The Tap is therefore the bridge between:

```text
"I am participating in this Play"

and

"This is what I did for it."
```

Future Play modes may give Tapping additional meanings, but the fundamental idea remains that a Tap represents an instance of interaction with a Play.

---

### 5. Creating Play Cards

After tapping a Play, the user can create a **Play Card**.

A Play Card records something the user did as part of that Play.

It serves both as:

* a personal activity record
* behavioral content that may later be shown to other people

Conceptually:

```text
Play
    ↓
participation
    ↓
Tap
    ↓
Play Card
```

A challenge can accumulate multiple Play Cards over time.

Together, these cards form a visible history of the challenger's activity.

For Challenge Mode, all relevant Play Cards created by the challenger are made available to the referee when the challenge is reviewed.

---

### 6. Final Call

The referee evaluates the challenge through the **Final Call** experience.

The Final Call page is designed to provide enough context for the referee to understand both:

1. what the challenger committed to doing, and
2. what the challenger actually recorded while doing it.

The Play Template is therefore shown prominently as the reference point for the challenge.

Below it, the referee can review the Play Cards created during the challenge.

Conceptually:

```text
Play Template
"What was the challenge?"

        ↓

Play Cards
"What did the challenger actually do?"

        ↓

Referee Decision
"Was the challenge successful?"
```

After reviewing the activity, the referee can finalize one of two verdicts:

```text
SUCCESS
FAIL
```

The referee's decision closes their part of the evaluation process.

---

### 7. Challenger Finalization

When the referee finalizes the verdict, the challenger is notified.

The challenger then makes the final response to the result.

The MVP provides three possible responses:

```text
ACCEPT
DISPUTE
CHICKEN OUT
```

### Accept

The challenger accepts the referee's verdict and finalizes the challenge accordingly.

### Dispute

The challenger does not agree with the referee's verdict.

A dispute represents disagreement with the result rather than ordinary completion of the challenge.

### Chicken Out

The challenger chooses not to complete the normal finalization process and accepts the consequence of withdrawing from the commitment.

The distinction between referee verdict and challenger response allows the system to represent both:

```text
What the referee decided

and

How the challenger responded to that decision
```

rather than reducing the entire challenge to a single status.

---

### 8. Personal Activity

Play Cards created by a user remain part of their activity history.

The user's personal page can display the Plays and Play Cards associated with that user.

The page itself may combine information from several domains.

For example:

```text
User / Profile
├── nickname
├── introduction
└── profile

Play
├── participated Plays
└── created Play Cards
```

The fact that Play Cards appear on a user's page does not transfer their ownership to the User domain.

They remain Play content displayed in the context of a particular user.

---

### 9. Content Discovery

Play Cards are not limited to private activity records.

Selected cards can also become discoverable behavioral content.

The MVP currently exposes two leaderboard-oriented views:

```text
Success Leaderboard
Fail Leaderboard
```

A system-defined ranking process determines which cards appear and their ordering.

These leaderboards provide an initial discovery mechanism because Challenge Mode naturally produces clear success and failure outcomes.

However, leaderboard ranking is not intended to define the long-term content discovery model.

The broader behavior platform should eventually support ordinary content discovery that is independent from challenge outcomes.

Conceptually:

```text
MVP discovery
├── Success leaderboard
└── Fail leaderboard

Future discovery
├── ranked content
├── ordinary Play Cards
├── personalized content
├── recent activity
└── other discovery models
```

The ranking and paging mechanisms may evolve independently from the underlying Play and Play Card concepts.

---

## MVP Journey and the Broader Play Model

The current journey is deliberately challenge-heavy:

```text
Choose behavior
    ↓
Stake
    ↓
Choose referee
    ↓
Tap
    ↓
Create Play Cards
    ↓
Referee verdict
    ↓
Challenger response
```

This should not be mistaken for the universal lifecycle of every future Play.

A future meetup, chatting session, routine, or other Play mode may have a very different participation lifecycle.

For example:

```text
Meetup

Choose Play
    ↓
Join
    ↓
Attend
    ↓
Create Play Cards
```

or:

```text
Chat Session

Choose Play
    ↓
Join conversation
    ↓
Participate
    ↓
Create Play Cards
```

The stable concepts are broader:

```text
Play
    ↓
User chooses to participate
    ↓
User interacts with the Play
    ↓
User may produce behavioral content
```

Challenge Mode adds commitment, referee evaluation, verdicts, and stakes on top of that foundation.

---

## Journey Principle

The MVP should therefore be understood through the following principle:

> **Challenge defines the first participation journey, but Play defines the platform.**

The challenge journey validates the behavioral-content concept through a familiar commitment model, while the Play domain remains general enough to support fundamentally different forms of participation in the future.
