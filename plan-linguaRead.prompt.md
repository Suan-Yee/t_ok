# LinguaRead — Design Specification

## 1. Overview

**LinguaRead** is a distraction-free English reading platform where learners read real books and tap words or sentences to explore vocabulary and grammar. The experience should feel like a premium e-reader (Kindle, Medium) enhanced with subtle language-learning tools that appear only on demand.

**Target audience:** English language learners at A2–B2 levels.
**Tech stack:** React + Tailwind CSS, no backend (mock data).

---

## 2. Design Principles

| Principle | Description |
|---|---|
| **Calm first** | Nothing appears unless the user asks for it. Reading is the priority. |
| **Progressive disclosure** | Word → tooltip. Sentence → grammar panel. Never all at once. |
| **Warm minimalism** | Soft surfaces, rounded corners, generous whitespace. |
| **Accessibility** | High contrast in both themes, keyboard navigation, focus rings. |

---

## 3. Visual Language

### 3.1 Color Palette

| Token | Light Mode | Dark Mode | Usage |
|---|---|---|---|
| `--bg-primary` | `#FAF8F5` (warm off-white) | `#1A1A2E` (deep navy) | Page background |
| `--bg-surface` | `#FFFFFF` | `#22223A` | Cards, panels |
| `--text-primary` | `#2D2D2D` | `#E8E8E8` | Body text |
| `--text-secondary` | `#6B7280` | `#9CA3AF` | Labels, hints |
| `--accent` | `#4A6FA5` (muted blue) | `#6B8FCC` | Buttons, links, highlights |
| `--accent-hover` | `#3B5D8C` | `#89A8DC` | Hover states |
| `--accent-light` | `#E8EEF6` | `#2A3550` | Word highlight background |
| `--success` | `#4CAF82` | `#5DC090` | Progress, completion |
| `--border` | `#E5E7EB` | `#333352` | Dividers, card borders |

### 3.2 Typography

| Role | Font | Weight | Size | Line Height |
|---|---|---|---|---|
| **Reading body** | Lora (serif) | 400 | 20px (desktop), 18px (mobile) | 1.8 |
| **UI text** | Inter (sans-serif) | 400 / 500 / 600 | 14–16px | 1.5 |
| **Headings** | Inter | 600 | 24–32px | 1.3 |
| **Tooltip text** | Inter | 400 | 14px | 1.4 |
| **Chapter title** | Lora | 600 | 28px | 1.4 |

### 3.3 Spacing & Shapes

- Border radius: `8px` (cards), `12px` (modals), `full` (avatars, badges)
- Card shadow: `0 1px 3px rgba(0,0,0,0.06), 0 1px 2px rgba(0,0,0,0.04)`
- Panel shadow: `−4px 0 12px rgba(0,0,0,0.08)` (side panel)
- Content max-width: `680px` (reading column), `1200px` (library grid)
- Page padding: `24px` (desktop), `16px` (mobile)

---

## 4. Page Layouts

### 4.1 Reading Page *(most important)*

```
┌─────────────────────────────────────────────────────────┐
│  [≡]  LinguaRead        Library  My Books  [☀/🌙] [👤]  │  ← Top Nav (sticky)
├──────┬──────────────────────────────────────┬────────────┤
│      │                                      │            │
│ Ch.  │     Chapter 3: Roast Mutton          │  Grammar   │
│ list │                                      │  Panel     │
│      │     When Bilbo opened his eyes,      │  (hidden   │
│ [≡]  │     he wondered if he had…           │  by        │
│      │                                      │  default)  │
│      │     ← 680px centered column →        │            │
│      │                                      │            │
├──────┴──────────────────────────────────────┴────────────┤
│  ▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░░░░  42% read                   │  ← Bottom progress
└─────────────────────────────────────────────────────────┘
```

**States:**
- **Read Mode (default):** Plain text, no highlights. Maximum focus.
- **Learn Mode:** Words become clickable (subtle underline-dot on hover). Sentences get a faint left-border on hover.

**Interactions:**
- **Word click (Learn Mode):** A floating tooltip (`240px` wide) appears near the cursor showing: word, pronunciation (IPA), part of speech, short definition, example sentence. Dismisses on click-outside or Escape.
- **Sentence click (Learn Mode):** The right-side Grammar Panel slides in (`360px` wide) with a grammar breakdown (see §4.4). Panel has a close button.
- **Mode toggle:** A small pill toggle in the top nav: `Read | Learn`.

### 4.2 Top Navigation Bar

- **Height:** `56px`
- **Layout:** Logo left, nav links center, actions right
- **Items:**
  - Logo: "LinguaRead" in Lora 600, accent color
  - Nav links: Library, My Books, Settings (Inter 500, `text-secondary`, accent on active)
  - Actions: Dark mode toggle (sun/moon icon), Profile avatar (32px circle)
- **Behavior:** Sticky top, light bottom border. On scroll past 50px, add a subtle shadow.
- **Mobile:** Hamburger menu replaces center links. Logo + actions remain visible.

### 4.3 Sidebar (Chapter Navigation)

- **Width:** `260px`, collapsible to icon-only (`56px`)
- **Toggle:** Hamburger icon in top-left of reading page
- **Contents:**
  - Book title & author (truncated)
  - Scrollable chapter list with active chapter highlighted
  - Each chapter: number, title, check icon if completed
  - Bookmark button (heart/flag icon) for current chapter
  - Overall progress bar at bottom
- **Mobile:** Full-screen overlay drawer from left with backdrop

### 4.4 Grammar Panel

- **Trigger:** Clicking a sentence in Learn Mode
- **Position:** Slides in from the right, `360px` wide, full height below nav
- **Sections (top to bottom):**
  1. **Selected sentence** — quoted, highlighted in accent-light
  2. **Structure breakdown** — sentence parsed with color-coded parts (subject, verb, object) displayed as inline tags
  3. **Grammar rule** — Title (e.g., "Past Simple Tense"), B1-level explanation (2–3 sentences max)
  4. **Example sentences** — 2–3 additional examples using the same pattern
  5. **Tip** — A short mnemonic or common-mistake warning in an info card
- **Animation:** Slide in from right, `300ms ease-out`, content fades in with `150ms` delay
- **Mobile:** Bottom sheet modal (70% viewport height) with drag-to-dismiss

### 4.5 Library Page

```
┌─────────────────────────────────────────────────┐
│  LinguaRead        Library  My Books  [☀/🌙] [👤] │
├─────────────────────────────────────────────────┤
│                                                 │
│  📚 Library             [Search...]  [Filter ▾] │
│                                                 │
│  ┌──────┐  ┌──────┐  ┌──────┐  ┌──────┐       │
│  │ cover│  │ cover│  │ cover│  │ cover│        │
│  │      │  │      │  │      │  │      │        │
│  ├──────┤  ├──────┤  ├──────┤  ├──────┤        │
│  │Title │  │Title │  │Title │  │Title │        │
│  │[B1]  │  │[A2]  │  │[B2]  │  │[B1]  │        │
│  │▓▓░ 42%│ │▓▓▓ 80%│ │░░ 0% │ │▓░ 25% │       │
│  └──────┘  └──────┘  └──────┘  └──────┘       │
│                                                 │
└─────────────────────────────────────────────────┘
```

- **Grid:** 4 columns (desktop), 2 columns (tablet), 1 column (mobile)
- **Book card (`220px` wide):**
  - Cover image (3:4 aspect ratio, rounded `8px` top corners)
  - Title (Inter 500, 16px, max 2 lines, ellipsis)
  - Author (Inter 400, 14px, `text-secondary`)
  - Level badge: colored pill — A2 green, B1 blue, B2 purple
  - Progress bar: thin `4px` bar, accent fill, gray track
- **Hover:** Card lifts (`translateY(-2px)`, shadow increases), cover slightly scales (`1.02`)
- **Filters:** Dropdown for level (A2/B1/B2/All), search input with debounced filter

---

## 5. Component Inventory

| Component | Props | Notes |
|---|---|---|
| `<NavBar>` | `darkMode`, `onToggleDark`, `currentPage` | Sticky, responsive |
| `<Sidebar>` | `chapters[]`, `currentChapter`, `progress`, `isOpen` | Collapsible drawer |
| `<ReadingView>` | `content`, `mode` | Renders paragraphs, handles word/sentence clicks |
| `<WordTooltip>` | `word`, `definition`, `pos`, `ipa`, `example`, `position` | Floating, dismissible |
| `<GrammarPanel>` | `sentence`, `grammar`, `examples[]`, `isOpen` | Slide-in panel |
| `<ModeToggle>` | `mode`, `onChange` | Read/Learn pill switch |
| `<BookCard>` | `title`, `author`, `cover`, `level`, `progress` | Grid item in library |
| `<LibraryGrid>` | `books[]`, `filter` | Responsive grid |
| `<ProgressBar>` | `value` (0–100) | Thin bar, accent fill |
| `<DarkModeToggle>` | `isDark`, `onToggle` | Sun/moon icon button |
| `<LevelBadge>` | `level` | A2/B1/B2 colored pill |

---

## 6. Interaction & Animation Spec

| Interaction | Trigger | Animation |
|---|---|---|
| Word tooltip open | Click word (Learn Mode) | `scale(0.95→1) + opacity(0→1)`, `200ms ease-out` |
| Word tooltip close | Click outside / Escape | `opacity(1→0)`, `150ms` |
| Grammar panel open | Click sentence (Learn Mode) | `translateX(100%→0)`, `300ms ease-out` |
| Grammar panel close | Close button / Escape | `translateX(0→100%)`, `250ms ease-in` |
| Sidebar toggle | Hamburger click | `translateX(-100%→0)`, `250ms ease-out` |
| Book card hover | Mouse enter | `translateY(0→-2px) + shadow increase`, `200ms` |
| Dark mode transition | Toggle click | `background-color + color`, `300ms ease` on `<body>` |
| Progress bar fill | On load / chapter change | `width 0→n%`, `600ms ease-out` |
| Mode toggle | Click | Pill slides left/right, `200ms` |
| Word highlight (Learn Mode) | Hover | `background-color` fade in, `150ms` |

---

## 7. Responsive Breakpoints

| Breakpoint | Width | Layout Changes |
|---|---|---|
| **Desktop** | ≥ 1024px | Full layout: sidebar + reading column + grammar panel |
| **Tablet** | 768–1023px | Sidebar collapses to overlay, grammar panel as overlay, 2-col library grid |
| **Mobile** | < 768px | Hamburger nav, bottom-sheet grammar, 1-col library, full-width reading |

---

## 8. Dark Mode Mapping

All colors switch via CSS custom properties on a `dark` class on `<html>`. Tailwind's `darkMode: 'class'` strategy. Toggle persists in `localStorage`.

---

## 9. Mock Data Structure

```
Book {
  id, title, author, coverUrl, level ("A2"|"B1"|"B2"),
  chapters: [{ id, title, paragraphs: string[] }]
}

WordDefinition {
  word, ipa, partOfSpeech, definition, example
}

GrammarExplanation {
  sentence, rule, explanation, parts: [{text, role}],
  examples: string[], tip
}
```

---

## 10. File / Folder Structure

```
src/
├── components/
│   ├── layout/
│   │   ├── NavBar.jsx
│   │   ├── Sidebar.jsx
│   │   └── ProgressBar.jsx
│   ├── reading/
│   │   ├── ReadingView.jsx
│   │   ├── WordTooltip.jsx
│   │   ├── GrammarPanel.jsx
│   │   └── ModeToggle.jsx
│   └── library/
│       ├── LibraryGrid.jsx
│       ├── BookCard.jsx
│       └── LevelBadge.jsx
├── data/
│   ├── books.js
│   ├── definitions.js
│   └── grammar.js
├── hooks/
│   ├── useDarkMode.js
│   └── useClickOutside.js
├── pages/
│   ├── ReadingPage.jsx
│   └── LibraryPage.jsx
├── styles/
│   └── globals.css        ← CSS custom properties, Tailwind directives
├── App.jsx
└── main.jsx
```

---

## Relevant files
- `c:\Suan Yee Aung\GIT\MD\Design.MD` — Final output location

## Verification
1. Open `Design.MD` in VS Code preview — confirm all tables render, ASCII diagrams are readable, section anchors work
2. Cross-check every feature from the user's requirement list is addressed in the document
3. Confirm color tokens, font choices, and component names are consistent throughout

## Decisions
- App name: **LinguaRead**
- Accent color: Muted blue (`#4A6FA5`)
- Fonts: Lora (reading), Inter (UI)
- Grammar panel: Slide-in right panel on desktop, bottom-sheet on mobile
- Target language: English
- Scope: Design spec only — no code implementation in this step
