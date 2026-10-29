# 🌟 Mini Market — Luxury 3D E-Commerce Platform

[![Flutter CI](https://github.com/Merdikai/Mini-Market/actions/workflows/frontend.yml/badge.svg)](https://github.com/Merdikai/Mini-Market/actions)
[![Django Backend CI](https://github.com/Merdikai/Mini-Market/actions/workflows/backend.yml/badge.svg)](https://github.com/Merdikai/Mini-Market/actions)
[![Flutter Version](https://img.shields.io/badge/Flutter-3.x%20Stable-02569B?logo=flutter)](https://flutter.dev)
[![Dart Version](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![Django Version](https://img.shields.io/badge/Django-5.x%20DRF-092E20?logo=django)](https://www.djangoproject.com/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Zero Warnings](https://img.shields.io/badge/Static%20Analysis-0%20Errors%20%7C%200%20Warnings-success)](https://dart.dev/tools/analysis)

> **Design Vision**: An ultra-luxury, high-performance shopping application inspired by the digital craftsmanship of **[Ora by Scrolltide](https://www.scrolltide.co/templates/ora)** (Geneva horology luxury, 240-step scrubbed canvases, microscopic typography, and liquid depths) and **[Artefakt by GetLayers AI](https://www.getlayers.ai/templates?layer=artefakt)** (near-black cyber-outerwear, reactive lattice grid illumination under touch, iridescent materials, and $4\times 4$ perspective dynamics).

---

## 📸 Architectural & Visual Highlights

```
                                MINI MARKET ARCHITECTURE
 ┌────────────────────────────────────────────────────────────────────────────────────────┐
 │                                 FLUTTER MOBILE CLIENT                                  │
 │                                                                                        │
 │  ┌─────────────────────────┐  ┌─────────────────────────┐  ┌────────────────────────┐  │
 │  │    LatticeGlowCanvas    │  │       TiltCard3D        │  │   HologramTurntable    │  │
 │  │ Reactive touch grid     │  │ 4x4 Matrix3D projection │  │ 360° product rotation   │  │
 │  │ with ambient wave pulse │  │ with specular glare     │  │ with glowing pedestal  │  │
 │  └─────────────────────────┘  └─────────────────────────┘  └────────────────────────┘  │
 │                                                                                        │
 │  ┌──────────────────────────────────────────────────────────────────────────────────┐  │
 │  │ Screens: Discovery Hero • Live Filter Matrix • 3D Detail • Cart • 3D Card        │  │
 │  │ Checkout • VIP Hologram Loyalty Club • Artifact Creator                          │  │
 │  └──────────────────────────────────────────────────────────────────────────────────┘  │
 └───────────────────────────────────────────┬────────────────────────────────────────────┘
                                             │ REST API (HTTPS / JWT / CORS)
 ┌───────────────────────────────────────────▼────────────────────────────────────────────┐
 │                              DJANGO REST FRAMEWORK BACKEND                             │
 │                                                                                        │
 │  ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐ ┌──────────────────────┐  │
 │  │  apps.products  │ │    apps.cart    │ │   apps.orders   │ │    apps.accounts     │  │
 │  │ Catalog, Specs  │ │ Session & User  │ │ Multi-tier      │ │ JWT Auth, VIP Tier   │  │
 │  │ & Reviews API   │ │ Cart Engine     │ │ Dispatch Engine │ │ & Loyalty Points     │  │
 │  └─────────────────┘ └─────────────────┘ └─────────────────┘ └──────────────────────┘  │
 └────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## ✨ Features & Component Manifest

### 1. 3D Interactive Engine & Custom Painters
* **`LatticeGlowCanvas`** (`lib/widgets/lattice_glow_canvas.dart`):
  - High-performance `CustomPainter` rendering a fine lattice matrix.
  - Dynamically tracks finger touches and pointer movements with quadratic energy falloff.
  - Continuous ambient harmonic wave pulses for an immersive cyber atmosphere.
* **`TiltCard3D`** (`lib/widgets/tilt_card_3d.dart`):
  - True $4\times 4$ `Matrix4` perspective transforms (`rotateX`, `rotateY`, `perspective: 0.0018`).
  - Real-time physics spring animation returning cards to center upon touch release.
  - Specular radial light sheen that sweeps across the card face matching tilt angles.
* **`HologramTurntable`** (`lib/widgets/hologram_turntable.dart`):
  - Interactive 360-degree horizontal drag turntable with inertia friction.
  - Dual concentric glowing pedestal rings with depth blur.
  - Continuous subtle floating bobbing animation.
  - Technical wireframe matrix overlay.
* **`GlassContainer`** (`lib/widgets/glass_container.dart`):
  - Frosted smoke glass surface with Gaussian backdrop blur (`sigma: 16`).
  - Specular hairline borders (`rgba(255,255,255,0.08)`).

### 2. Comprehensive Screen Suite
* **Discovery & Home Screen (`HomeScreen`)**:
  - Top branding header with live cart count pill and VIP quick-access.
  - Instant live debounced search bar.
  - 3D Hero Drop banner with live countdown ticker (`03:42:19 REMAINING`).
  - Horizontal animated category filter pills (`Horology`, `Cyber Apparel`, `Audio`, `Futuristic EDC`, `Hardware`).
  - Staggered product grid with 3D tilt cards.
* **3D Product Detail Screen (`ProductDetailScreen`)**:
  - Interactive 360° turntable product viewer.
  - Real-time Finish & Material tone selector with live visual feedback.
  - Technical Specifications accordion (Swiss Calibre, Double Sapphire, Aerospace Titanium).
  - Verified customer reviews breakdown with star ratings.
  - Sticky frosted glass purchase action bar with quantity stepper.
* **Luxury Bag Screen (`CartScreen`)**:
  - Dismissible interactive items with quantity increment/decrement steppers.
  - Promo coupon validator (`ORA20` for 20% off, `VIP50` for 50% VIP discount).
  - Live cost breakdown with complimentary luxury shipping calculation.
* **Secure Checkout Screen (`CheckoutScreen`)**:
  - **3D Flippable Credit Card**: Tap to flip $180^\circ$ and reveal CVC security code and platinum chip.
  - Shipping destination form with input validation.
  - Dispatch Speed selector (`Standard Orbital`, `Autonomous Drone Priority`, `White Glove Concierge`).
  - Order confirmed modal with animated checkmark.
* **VIP Club & Vault Screen (`ProfileScreen`)**:
  - 3D Holographic VIP Membership card with metallic sheen and loyalty points.
  - Order dispatch history timeline with real-time tracking badges.
  - Vault settings (theme switcher, currency selector, biometric lock).

---

## 🐍 Django REST Framework Backend

Located in `./backend/`:

| Module | Description | Endpoints |
| :--- | :--- | :--- |
| **`apps.core`** | Base `TimeStampedModel`, exceptions, health check | `GET /api/core/health/` |
| **`apps.products`** | Category, Product, ProductSpec, ProductReview | `GET/POST /api/products/items/`, `GET /api/products/categories/` |
| **`apps.cart`** | Cart and CartItem with live price calculations | `GET/POST /api/cart/`, `POST /api/cart/{id}/add_item/` |
| **`apps.orders`** | Order, OrderItem, and dispatch tiers | `GET/POST /api/orders/` |
| **`apps.accounts`** | UserProfile, VIP tiers, JWT authentication | `POST /api/accounts/token/`, `GET /api/accounts/me/` |

### Database Seeder
Populate the luxury catalog, specs, and categories in 1 command:
```bash
cd backend
python seed_data.py
```

---

## 🚀 Getting Started

### 1. Flutter Mobile / Desktop App

Ensure you have Flutter 3.x installed.

```powershell
# Navigate to the Flutter project
cd mini_market

# Install dependencies
flutter pub get

# Verify zero errors & zero warnings
flutter analyze --no-fatal-infos

# Run on Android Phone Emulator
flutter run -d Medium_Phone

# Or run instantly on Windows Desktop
flutter run -d windows

# Or run in Chrome browser
flutter run -d chrome
```

### 2. Django Backend

```bash
cd backend

# Create virtual environment & install requirements
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt

# Run migrations & seed data
python manage.py migrate
python seed_data.py

# Run tests
python manage.py test tests

# Start development server
python manage.py runserver 8000
```

---

## 🛡️ CI/CD Quality Assurance

This repository includes two GitHub Actions workflows:

1. **Frontend CI (`.github/workflows/frontend.yml`)**:
   - Executes `flutter pub get`.
   - Strictly enforces `flutter analyze --no-fatal-infos` (0 errors, 0 warnings policy).
   - Executes full widget and unit test suites (`flutter test`).
2. **Backend CI (`.github/workflows/backend.yml`)**:
   - Sets up Python 3.11 environment.
   - Verifies migrations consistency (`makemigrations --check`).
   - Executes Django automated test suite and database seeder.

---

## 📦 Git Commit History

The repository features **120+ structured atomic commits** covering every milestone across themes, custom shaders, 3D math, widgets, screens, backend apps, and workflows.

Repository URL: **[https://github.com/Merdikai/Mini-Market](https://github.com/Merdikai/Mini-Market)** (Branch: `main`)
