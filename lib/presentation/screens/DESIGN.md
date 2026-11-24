---
name: ADSO4089 Mobile
colors:
  surface: '#0b1326'
  surface-dim: '#0b1326'
  surface-bright: '#31394d'
  surface-container-lowest: '#060e20'
  surface-container-low: '#131b2e'
  surface-container: '#171f33'
  surface-container-high: '#222a3d'
  surface-container-highest: '#2d3449'
  on-surface: '#dae2fd'
  on-surface-variant: '#c7c4d7'
  inverse-surface: '#dae2fd'
  inverse-on-surface: '#283044'
  outline: '#908fa0'
  outline-variant: '#464554'
  surface-tint: '#c0c1ff'
  primary: '#c0c1ff'
  on-primary: '#1000a9'
  primary-container: '#8083ff'
  on-primary-container: '#0d0096'
  inverse-primary: '#494bd6'
  secondary: '#adc6ff'
  on-secondary: '#002e6a'
  secondary-container: '#0566d9'
  on-secondary-container: '#e6ecff'
  tertiary: '#4edea3'
  on-tertiary: '#003824'
  tertiary-container: '#00885d'
  on-tertiary-container: '#000703'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#e1e0ff'
  primary-fixed-dim: '#c0c1ff'
  on-primary-fixed: '#07006c'
  on-primary-fixed-variant: '#2f2ebe'
  secondary-fixed: '#d8e2ff'
  secondary-fixed-dim: '#adc6ff'
  on-secondary-fixed: '#001a42'
  on-secondary-fixed-variant: '#004395'
  tertiary-fixed: '#6ffbbe'
  tertiary-fixed-dim: '#4edea3'
  on-tertiary-fixed: '#002113'
  on-tertiary-fixed-variant: '#005236'
  background: '#0b1326'
  on-background: '#dae2fd'
  surface-variant: '#2d3449'
typography:
  display-lg:
    fontFamily: Roboto Flex
    fontSize: 57px
    fontWeight: '700'
    lineHeight: 64px
    letterSpacing: -0.25px
  headline-lg:
    fontFamily: Roboto Flex
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
  headline-lg-mobile:
    fontFamily: Roboto Flex
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 36px
  headline-md:
    fontFamily: Roboto Flex
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  title-lg:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  title-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '500'
    lineHeight: 24px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-lg:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 16px
  margin: 16px
  space-xs: 4px
  space-sm: 8px
  space-md: 16px
  space-lg: 24px
  space-xl: 32px
---

## Brand & Style

This design system establishes a high-performance academic management environment tailored for vocational training. The brand personality is authoritative, precise, and approachable, built upon Material 3 principles. The UI evokes focus, academic rigor, and technological empowerment, instilling confidence in students and instructors managing complex technical curricula.

The design style combines a refined **Corporate / Modern** baseline with **High-Contrast / Bold** data displays. It leverages dark obsidian surfaces, luminous accents, and structured layout patterns to ensure critical academic metrics remain immediately legible under any lighting condition.

## Colors

The color architecture is anchored by a deep obsidian background that reduces eye strain during extended study sessions. Vibrant indigo serves as the primary action catalyst, paired with Material blue for structural highlights and status indicators. 

- **Primary (`#6366F1`):** Core interactive elements, active states, and primary button fills.
- **Secondary (`#3B82F6`):** Supporting actions, progress indicators, and informational badges.
- **Tertiary (`#10B981`):** Success states, attendance confirmations, and completed milestone markers.
- **Neutral (`#0F172A`):** Obsidian surface foundations, split panes, and high-contrast text hierarchies.

## Typography

Typography prioritizes absolute clarity for data-dense academic schedules, grade breakdowns, and attendance logs. Roboto Flex provides structural weight for headlines, while Inter ensures exceptional legibility at small scale for tabular data and metadata.

Ensure that large headers scale down appropriately on mobile viewports to prevent awkward wrapping of course titles and module codes.

## Layout & Spacing

The layout relies on a responsive fluid grid system optimized for mobile-first academic delivery. Content areas utilize a standard 16px margin and gutter system, allowing modules and cards to reflow cleanly across tablet and desktop extensions.

- **Mobile:** Single-column stacked layouts with persistent bottom navigation.
- **Tablet:** Two-column split views pairing course schedules with active grade trackers.
- **Desktop:** Multi-column dashboard configurations supporting dense administrative data grids.

## Elevation & Depth

Depth is articulated through tonal surface layering rather than harsh drop shadows. Components sit on elevated obsidian planes (`#1E293B` and `#334155`) against the deep background (`#0F172A`). 

Subtle ambient glows in primary indigo are reserved exclusively for active modal dialogs, floating action buttons (FABs), and high-priority deadline alerts to guide user focus naturally.

## Shapes

A rounded shape language (`roundedness`: 2) creates a friendly yet professional atmosphere. Standard UI components utilize a 0.5rem radius, while major cards and bottom sheets step up to 1rem (`rounded-lg`) and 1.5rem (`rounded-xl`) to establish distinct interactive zones.

## Components

- **Buttons:** Filled primary buttons use the vibrant indigo accent with pill or rounded-lg geometry. Outlined and text variants maintain high contrast against dark surfaces.
- **Chips:** Used for filterable course categories, status tags, and attendance states. Selected states invert to solid primary fills.
- **Lists:** Dense, alternating row structures for gradebooks and attendance logs, featuring clear leading avatars or module icons.
- **Checkboxes & Radio Buttons:** Custom-rendered with primary indigo fills and high-contrast check/indicator icons for task completion tracking.
- **Input Fields:** Filled input variants with floating labels set on elevated surface containers, featuring prominent error and success validation borders.
- **Cards:** Surface-container tiers housing course modules, assignment deadlines, and instructor announcements, utilizing rounded corners and clear internal padding.
- **Data Displays:** Specialized high-contrast metric cards and radial progress indicators for tracking competency completion percentages.