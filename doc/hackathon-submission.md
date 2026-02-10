# Lumenary

## Inspiration
Lumenary is an app designed to support individuals, especially international students, by promoting mental wellness and ensuring safety. The app provides a private, low-pressure space where users can track their emotions daily, with no social interaction required.

A key feature is the Journal, where users capture their feelings and select a "Mood Sprite" in different colors. Google Gemini powers personalized, empathetic responses to each entry, transforming journaling from a solitary activity into a supportive dialogue.

Users can review past entries through a calendar view to track emotional patterns. Safety features include emergency contacts who are notified if check-ins are missed, with the ability to pause check-ins at any time.

## What it does
- **Daily journaling** with colorful Mood Sprites
- **AI-powered warmth** via Gemini's personalized reflections
- **Calendar view** to track emotional patterns
- **Safety check-ins** with emergency contact notifications
- **Pause mode** for when users need space

## How we built it
- **iOS**: SwiftUI
- **Web**: Next.js, React, TypeScript, Tailwind CSS
- **Backend**: Python, FastAPI, PostgreSQL
- **AI**: Google Gemini API
- **Deployment**: Vercel + Render

## Challenges we ran into
- Calibrating Gemini's tone to be warm but not generic
- Maintaining consistency across iOS and Web platforms
- Designing gentle UX for empty/paused states
- Handling timezones for international users

## Accomplishments that we're proud of
- Built a complete cross-platform solution in a short time
- Created an emotionally intelligent AI journaling experience
- Designed a safety system that balances care with privacy

## What we learned
- AI works best as a mirror, reflecting moments with added warmth
- Prompt engineering is a form of UX writing
- Empty states deserve as much design attention as features

## What's next for Lumenary
- Voice journaling with Gemini transcription
- AI-powered weekly mood insights
- Gentle streak reminders without guilt
