# Luminary — Fight the Void with Tiny Lights

## Inspiration

In a world that often feels overwhelming and meaningless, we noticed something: **the small moments of light get lost**. A good cup of coffee, a kind word from a stranger, finishing a task you've been putting off — these tiny victories fade quickly, swallowed by the noise of daily life.

We asked ourselves: *What if there was a gentle companion that helped you collect these moments? And what if, when the void feels close, it could remind you — with warmth and understanding — that your moments matter?*

That's how **Luminary** was born. It's not just a journaling app. It's a quiet protest against the emptiness — a place to gather light, one small spark at a time.

---

## What It Does

Luminary helps users:

1. **Record daily "glimmers"** — small moments of light worth remembering
2. **Track moods** with expressive, hand-crafted character emotions
3. **Revisit past moments** through the "Gather Light" feature
4. **Receive AI-powered warmth** — Gemini generates personalized, empathetic reflections on your entries

### The Gemini Magic

When you tap "Gather a little light," Luminary retrieves a random past journal entry and sends it to **Gemini API**. Gemini then generates a warm, thoughtful reflection — not generic advice, but a personalized message that acknowledges your specific moment and offers gentle encouragement.

For example, if you wrote *"I finally cleaned my room today"*, Gemini might respond:

> *"That took more energy than people realize. You chose to create order in your space — that's choosing yourself. Well done."*

This transforms passive journaling into an **active dialogue of self-compassion**.

---

## How We Built It

### Architecture

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   iOS App       │     │   Web Demo      │     │   Backend API   │
│   (SwiftUI)     │────▶│   (Next.js)     │────▶│   (FastAPI)     │
└─────────────────┘     └─────────────────┘     └────────┬────────┘
                                                         │
                                                         ▼
                                               ┌─────────────────┐
                                               │   Gemini API    │
                                               │   (AI Warmth)   │
                                               └─────────────────┘
                                                         │
                                                         ▼
                                               ┌─────────────────┐
                                               │   PostgreSQL    │
                                               └─────────────────┘
```

### Tech Stack

| Layer | Technology |
|-------|------------|
| **iOS App** | SwiftUI |
| **Web Demo** | Next.js 16, React 19, TypeScript, Tailwind CSS |
| **Backend** | Python, FastAPI, SQLAlchemy (async) |
| **Database** | PostgreSQL with asyncpg |
| **AI** | **Gemini API** (google-genai) |
| **Deployment** | Vercel (Web), Render (API) |

### Gemini Integration

We integrated Gemini API to generate warm, contextual responses. The key was crafting the right prompt:

```python
prompt = f"""
You are a warm, empathetic companion. The user recorded this moment:
"{journal_entry}"

Generate a short, gentle reflection (1-2 sentences) that:
- Acknowledges the specific moment they shared
- Offers warmth without being preachy
- Helps them see the meaning in small things

Be concise. Be kind. Be real.
"""
```

We generate multiple alternatives and cache them, so users get variety when revisiting the same entry.

---

## Challenges We Faced

### 1. Tone Calibration with Gemini

The hardest part wasn't technical — it was **emotional**. Early prompts produced responses that felt:
- Too generic ("Great job!")
- Too therapeutic ("It's okay to feel this way")
- Too long (walls of text)

We iterated extensively on prompt engineering to find the right voice: **warm but not saccharine, brief but not dismissive, personal but not intrusive**.

### 2. Cross-Platform Consistency

Building for both iOS (SwiftUI) and Web (Next.js) meant maintaining visual and emotional consistency across platforms. We solved this by:
- Extracting exact color values from iOS code
- Using the same character assets
- Matching animation timing and easing curves

### 3. The "Void" UX Problem

How do you design for emptiness? When a user hasn't journaled in days, the app shouldn't guilt them. We created a "longtime no visit" state with a gentle message: *"It's been a while... Welcome back."* — no judgment, just presence.

### 4. Breathing Animation Performance

The home screen features a "breathing" light animation that runs continuously. On web, we had to optimize this to avoid layout thrashing and ensure smooth 60fps performance using CSS transitions instead of JavaScript animation loops.

---

## What We Learned

1. **AI is a mirror, not a replacement** — Gemini doesn't tell users how to feel. It reflects their moments back with added warmth, helping them see value they might have missed.

2. **Small moments compound** — Designing for "tiny lights" taught us that micro-interactions matter. Every tap, every transition, every word contributes to the emotional experience.

3. **Emptiness needs design too** — The paused states, empty states, and "no data" screens required as much care as the main features. Absence is part of the experience.

4. **Prompt engineering is UX writing** — Crafting Gemini prompts felt like writing UI copy. Every word shapes the user's emotional journey.

---

## What's Next

- **Streaks & gentle nudges** — Encourage consistency without guilt
- **Voice journaling** — Speak your glimmers, let Gemini transcribe
- **Shared lights** — Send anonymous encouragement to other users
- **Mood insights** — Gemini-powered weekly reflections on emotional patterns

---

## Try It

- **Web Demo:** [glimmer-web-theta.vercel.app](https://glimmer-web-theta.vercel.app)
- **iOS App:** Available on TestFlight

---

*Luminary: Because even in the void, tiny lights still matter.*
