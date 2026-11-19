# 🎨 MINI MARKET — UI/UX DESIGN SYSTEM & COMMERCIAL GUIDELINES

**Document Version**: 1.0.0  
**Design Standard**: Enterprise Commercial Retail Product  
**Modes**: Full Light Mode & Obsidian OLED Dark Mode Support  

---

## 1. Design Philosophy

Mini Market is designed for **fast-paced, high-throughput retail operations**. Cashiers, store clerks, and managers interact with the software under demanding store conditions. 

### 1.1 Core Principles
1. **High Visual Ergonomics**: Tap targets must be at least $48\times 48\,\text{dp}$ for touch reliability.
2. **Instant Scannability**: High contrast data typography, clear inventory health badges, and numeric keypads for cashier speed.
3. **Restraint Over Clutter**: Clean geometric layouts without distracting decorative flourishes or unnecessary gradients.
4. **Authentic Imagery**: Every product displays real-world grocery, beverage, and household imagery cached persistently.
5. **Dual Theme Harmony**: True OLED Dark Mode (`#07080B`) for battery efficiency and night shifts, alongside an elegant crisp Executive Light Mode (`#F8FAFC`).

---

## 2. Color Palette & Token System

| Token | Light Theme Value | Dark Theme Value (Obsidian) | Purpose |
| :--- | :--- | :--- | :--- |
| `surface.canvas` | `#F8FAFC` (Slate 50) | `#07080B` (OLED Obsidian) | Scaffold primary canvas |
| `surface.card` | `#FFFFFF` (Pure White) | `#111420` (Deep Smoke Void) | Elevated cards, tables, drawers |
| `surface.elevated` | `#F1F5F9` (Slate 100) | `#161A29` (Raised Glass Plate) | Input fields, active tabs, dialogs |
| `border.subtle` | `#E2E8F0` (Slate 200) | `rgba(255,255,255,0.08)` | Table dividers, container hairline borders |
| `border.focused` | `#0284C7` (Sky Blue 600) | `#00F5FF` (Hyper Radiant Cyan) | Active search focus, selected items |
| `brand.primary` | `#0284C7` (Sky Blue 600) | `#00F5FF` (Hyper Radiant Cyan) | Primary action CTAs, active highlights |
| `brand.secondary`| `#059669` (Emerald 600) | `#00F5A0` (Cyber Emerald) | Successful checkouts, revenue indicators |
| `brand.luxury` | `#D97706` (Amber Gold) | `#E5C158` (Liquid Champagne Gold)| VIP customer tags, top-tier products |
| `status.stockGreen`| `#10B981` (Emerald) | `#10B981` (Emerald) | Healthy stock level (> min threshold) |
| `status.alertOrange`| `#F59E0B` (Amber) | `#F59E0B` (Amber) | Low stock alert |
| `status.errorRed` | `#EF4444` (Rose Red) | `#EF4444` (Rose Red) | Out of stock, voided, negative margin |
| `text.primary` | `#0F172A` (Slate 900) | `#FFFFFF` (Pure White) | Headings, monetary totals, product titles |
| `text.secondary`| `#475569` (Slate 600) | `#94A3B8` (Slate 400) | Table subtext, timestamps, SKUs |
| `text.muted` | `#94A3B8` (Slate 400) | `#64748B` (Slate 500) | Disabled states, empty state captions |

---

## 3. Real Internet Product Imagery Standard

Retail applications must showcase real items (e.g. Coca-Cola 330ml, Heinz Ketchup, Kellogg's Corn Flakes, Organic Apples).

### 3.1 Public CDN Image Sources
- High-reliability, royalty-free e-commerce product CDNs (Unsplash Retail, Open Food Facts, Wikimedia Commons Verified Products).
- Clean, transparent or studio-isolated backgrounds.

### 3.2 Caching & Fallback Architecture
1. **Multi-Tiered Cache**: Memory Cache (100 MB) $\rightarrow$ Local Disk Cache (`cached_network_image`) $\rightarrow$ Network.
2. **Offline Resilience**: Once an image is loaded, it remains stored permanently on local flash memory for offline POS operation.
3. **Low-Bandwidth Shimmer**: Subtle SVG/Skeleton shimmer while loading.
4. **Graceful Fallback**: If network fails and image is uncached, render a stylish geometric icon badge with the department's theme color (never broken `X` icons).

---

## 4. Responsive Device Form Factors

```
 +-------------------------+   +---------------------------------------------+
 |   MOBILE PHONE (POS)    |   |           TABLET / DESKTOP POS              |
 | +---------------------+ |   | +--------------------+ +------------------+ |
 | | Search / Barcode    | |   | | Category Matrix    | | Cart Ledger      | |
 | +---------------------+ |   | | & Product Grid     | |                  | |
 | | Product Grid        | |   | |                    | | Line Total       | |
 | | (2 columns)         | |   | | (4-5 columns)      | | Tax & Discount   | |
 | +---------------------+ |   | |                    | | Grand Total      | |
 | | [Bottom Bar: Cart]  | |   | |                    | | [Pay Cash/Card]  | |
 | +---------------------+ |   | +--------------------+ +------------------+ |
 +-------------------------+   +---------------------------------------------+
```

1. **Compact Mobile (Phones)**: Vertical flow with sticky bottom checkout dock and floating barcode scanner button.
2. **Tablet & POS Terminals (Landscape)**: Split-view POS with product grid on the left ($65\%$ width) and live interactive cart/payment drawer on the right ($35\%$ width).
