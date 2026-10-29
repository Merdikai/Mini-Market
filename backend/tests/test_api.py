from django.test import TestCase
from django.urls import reverse
from rest_framework.test import APIClient
from apps.products.models import Category, Product

class MiniMarketAPITests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.category = Category.objects.create(name='Horology', slug='horology')
        self.product = Product.objects.create(
            title='Ora Chrono Geneva',
            slug='ora-chrono',
            category=self.category,
            price=1850.00,
            description='Precision luxury watch',
            icon_name='watch',
            rating=4.98,
            stock=5,
        )

    def test_health_check(self):
        response = self.client.get(reverse('health-check'))
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data['status'], 'healthy')

    def test_products_list(self):
        response = self.client.get('/api/products/items/')
        self.assertEqual(response.status_code, 200)
        self.assertGreaterEqual(len(response.data['results']), 1)

    def test_user_profile(self):
        response = self.client.get(reverse('current_user'))
        self.assertEqual(response.status_code, 200)
        self.assertIn('profile', response.data)
