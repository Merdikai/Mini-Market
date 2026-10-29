import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'mini_market_backend.settings')
django.setup()

from apps.products.models import Category, Product, ProductSpec

def seed():
    print("🌱 Seeding Mini Market Luxury Catalog...")
    categories_data = [
        {'name': 'Horology', 'slug': 'horology', 'description': 'Geneva-crafted automatic mechanical timepieces.'},
        {'name': 'Cyber Apparel', 'slug': 'cyber-apparel', 'description': 'Reactive carbon-lattice outerwear.'},
        {'name': 'Audio', 'slug': 'audio', 'description': 'Planar magnetic acoustic transducers.'},
        {'name': 'Futuristic EDC', 'slug': 'futuristic-edc', 'description': 'Titanium everyday carry companions.'},
        {'name': 'Hardware', 'slug': 'hardware', 'description': 'Next-generation computing hardware.'},
    ]

    cat_map = {}
    for c in categories_data:
        obj, _ = Category.objects.get_or_create(slug=c['slug'], defaults=c)
        cat_map[c['name']] = obj

    products_data = [
        {
            'title': 'Ora Chrono Geneva 01',
            'slug': 'ora-chrono-geneva-01',
            'category': cat_map['Horology'],
            'price': 1850.00,
            'description': 'Precision Geneva-crafted automatic chronograph featuring a 240-step scrubbed sapphire canvas, obsidian black ceramic bezel, and open mechanical escapement.',
            'icon_name': 'watch',
            'accent_color': '#E5C158',
            'rating': 4.98,
            'review_count': 342,
            'is_featured': True,
            'is_daily_drop': True,
            'stock': 4,
            'badge': 'GENEVA DROP',
            'specs': {
                'Movement': 'Swiss Calibre 9012 Automatic',
                'Crystal': 'Scratched-Proof Double Sapphire',
                'Case Diameter': '41mm Grade-5 Titanium',
                'Water Resistance': '100m / 10 ATM',
                'Power Reserve': '72 Hours',
            }
        },
        {
            'title': 'Artefakt Lattice Parka',
            'slug': 'artefakt-lattice-parka',
            'category': cat_map['Cyber Apparel'],
            'price': 740.00,
            'description': 'Near-black iridescent outerwear engineered with reactive carbon lattice membrane. Illuminates under environmental lumina and repels torrential storm conditions.',
            'icon_name': 'checkroom',
            'accent_color': '#00F5FF',
            'rating': 4.95,
            'review_count': 189,
            'is_featured': True,
            'is_daily_drop': False,
            'stock': 9,
            'badge': 'LIMITED RUN',
            'specs': {
                'Fabric': 'Triple-Lacquered Carbon Weave',
                'Membrane': 'Hydro-Shield 30K Reactive',
                'Insulation': 'Graphene Aerogel 120g',
                'Hardware': 'Matte Anodized Magnetic Clasps',
            }
        },
        {
            'title': 'Cyber Pulse Audio Buds',
            'slug': 'cyber-pulse-audio-buds',
            'category': cat_map['Audio'],
            'price': 299.00,
            'description': 'Spatial planar-magnetic monitors with titanium acoustics, active zero-latency spatial positioning, and frosted matte smoke charging capsule.',
            'icon_name': 'headphones',
            'accent_color': '#00F5A0',
            'rating': 4.88,
            'review_count': 512,
            'is_featured': True,
            'is_daily_drop': False,
            'stock': 22,
            'badge': 'BESTSELLER',
            'specs': {
                'Driver': '12mm Planar Magnetic',
                'Latency': '18ms Ultra-Low Sync',
                'Battery': '38h with Charging Pod',
                'Noise Cancelling': '-48dB Adaptive Hybrid ANC',
            }
        },
    ]

    for p in products_data:
        specs = p.pop('specs')
        product, _ = Product.objects.get_or_create(slug=p['slug'], defaults=p)
        for k, v in specs.items():
            ProductSpec.objects.get_or_create(product=product, key=k, defaults={'value': v})

    print("✨ Seeding completed successfully!")

if __name__ == '__main__':
    seed()
