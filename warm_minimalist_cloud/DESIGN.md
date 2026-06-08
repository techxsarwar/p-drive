---
name: Warm Minimalist Cloud
colors:
  surface: '#f9f9ff'
  surface-dim: '#d3daef'
  surface-bright: '#f9f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f1f3ff'
  surface-container: '#e9edff'
  surface-container-high: '#e1e8fd'
  surface-container-highest: '#dce2f7'
  on-surface: '#141b2b'
  on-surface-variant: '#454655'
  inverse-surface: '#293040'
  inverse-on-surface: '#edf0ff'
  outline: '#757687'
  outline-variant: '#c5c5d8'
  surface-tint: '#3a4bdf'
  primary: '#3748dd'
  on-primary: '#ffffff'
  primary-container: '#5364f7'
  on-primary-container: '#fffbff'
  inverse-primary: '#bdc2ff'
  secondary: '#5d5f5d'
  on-secondary: '#ffffff'
  secondary-container: '#e2e3e1'
  on-secondary-container: '#636563'
  tertiary: '#006b2d'
  on-tertiary: '#ffffff'
  tertiary-container: '#00873b'
  on-tertiary-container: '#f7fff3'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dfe0ff'
  primary-fixed-dim: '#bdc2ff'
  on-primary-fixed: '#000965'
  on-primary-fixed-variant: '#192dc8'
  secondary-fixed: '#e2e3e1'
  secondary-fixed-dim: '#c6c7c5'
  on-secondary-fixed: '#1a1c1b'
  on-secondary-fixed-variant: '#454746'
  tertiary-fixed: '#6bff8f'
  tertiary-fixed-dim: '#4ae176'
  on-tertiary-fixed: '#002109'
  on-tertiary-fixed-variant: '#005321'
  background: '#f9f9ff'
  on-background: '#141b2b'
  surface-variant: '#dce2f7'
typography:
  display:
    fontFamily: Inter
    fontSize: 40px
    fontWeight: '700'
    lineHeight: 48px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 34px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.01em
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.03em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  container-padding: 24px
  stack-gap: 16px
  section-gap: 40px
  gutter: 16px
---

## Brand & Style

This design system is built on the principles of **Warm Minimalism**. It rejects the cold, sterile nature of traditional enterprise software in favor of a "homely" digital environment that feels premium, tactile, and calm. The target audience consists of professionals and creatives who value organization as a form of mental clarity.

The aesthetic draws from the precision of Linear and the approachability of Notion. It utilizes heavy whitespace to reduce cognitive load, ensuring that the act of managing files feels meditative rather than chore-like. The emotional response should be one of quiet confidence, reliability, and warmth. High-quality micro-interactions and subtle haptic-inspired visuals replace loud decorations.

## Colors

The palette is anchored by a warm, off-white background (`#F7F7F5`) which prevents screen fatigue and creates a paper-like quality. The primary accent (`#5B6CFF`) is a vibrant but sophisticated blue used sparingly to signal action and focus. 

- **Surface:** Use the background color for the main canvas. Use pure white (`#FFFFFF`) for elevated cards to create a subtle "layered paper" effect.
- **Contrast:** Maintain high legibility by using the Primary Text color for all headings.
- **Success:** The green is reserved for upload completions and secure states, maintaining a soft but clear presence.

## Typography

The design system utilizes **Inter** across all levels to maintain a systematic, utilitarian, yet modern feel. 

Visual hierarchy is achieved through significant size stepping and weight distribution rather than color variation. Headlines use tighter letter spacing and heavier weights to feel "grounded." Body text is given generous line height to ensure comfortable readability during long sessions of file browsing. Labels for metadata (file sizes, dates) should use the `label-sm` style with increased tracking for clarity at small scales.

## Layout & Spacing

This design system employs a **fluid-to-fixed layout** model optimized for mobile-first cloud interactions. 

- **Grid:** On mobile, use a 4-column layout with 24px outer margins.
- **Rhythm:** Spacing follows an 8px linear scale. Use 24px for standard internal container padding to match the "breathable" brand personality.
- **Safe Areas:** Ensure all bottom-docked actions have a minimum of 32px clearance from the device home indicator.
- **Reflow:** On larger viewports (Tablets), cards should transition from a single-column list to a multi-column masonry or grid view, maintaining the 24px gutter.

## Elevation & Depth

Depth is communicated through **Tonal Layering** and **Soft Diffusion Shadows**. Avoid harsh borders or black shadows.

1.  **Level 0 (Base):** The `#F7F7F5` background.
2.  **Level 1 (Cards/Sheets):** Pure white `#FFFFFF` surfaces with a "Soft" shadow (10% opacity of `#111827`, 20px blur, 4px Y-offset).
3.  **Level 2 (Modals/Popovers):** Pure white with a slightly more aggressive "Ambient" shadow (12% opacity, 40px blur, 10px Y-offset).

Interactive elements should appear to "lift" slightly on press, achieved by increasing the shadow blur radius rather than changing the element size.

## Shapes

The shape language is defined by **Smoothness**. The standard corner radius for primary containers and cards is **24px**, creating a friendly, organic silhouette.

- **Standard Buttons:** 12px radius.
- **Main Cards:** 24px radius.
- **Input Fields:** 12px radius.
- **Search Bars:** Pill-shaped (fully rounded) to differentiate global navigation from content containers.

Avoid sharp corners entirely to maintain the "lovable" and premium character of the design system.

## Components

### Buttons
- **Primary:** Solid `#5B6CFF` with white text. High-padding (16px vertical).
- **Secondary:** Transparent background with a 1px border of `#E5E7EB` (Light Gray).
- **Ghost:** No background or border, used for low-priority navigation.

### Input Fields
- Use a soft-gray background (`#F1F1EF`) rather than a white background to make them feel "recessed" into the page. 
- Focus state: A 2px solid `#5B6CFF` border.

### Cards (File/Folder)
- Files should be represented by large-format thumbnails with 12px internal rounding. 
- Folders use a custom icon set with the same 24px parent rounding logic.
- Metadata (Size, Owner) should always be in the `label-md` or `label-sm` style using the secondary text color.

### Progress Bars
- For uploads, use a slim 4px track. The track is `#E5E7EB` and the fill is the primary accent. The ends are always rounded.

### Navigation Bar
- A bottom-docked, blurred background (using the off-white base color) with a height of 84px. Icons should be line-weight (2pt) to match the Inter font's stroke.