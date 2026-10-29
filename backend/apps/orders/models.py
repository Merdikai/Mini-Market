from django.db import models
from django.contrib.auth.models import User
from apps.core.models import TimeStampedModel
from apps.products.models import Product

class Order(TimeStampedModel):
    STATUS_CHOICES = (
        ('PENDING', 'Pending Authorization'),
        ('FABRICATING', 'In Fabrication'),
        ('DISPATCHED', 'Dispatched / In Transit'),
        ('DELIVERED', 'Delivered'),
    )

    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='orders', null=True, blank=True)
    order_number = models.CharField(max_length=50, unique=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='DISPATCHED')
    total_amount = models.DecimalField(max_digits=10, decimal_places=2)
    shipping_address = models.TextField()
    dispatch_tier = models.CharField(max_length=50, default='Standard Orbital')

    def __str__(self):
        return f"{self.order_number} - {self.status}"

class OrderItem(TimeStampedModel):
    order = models.ForeignKey(Order, related_name='items', on_delete=models.CASCADE)
    product = models.ForeignKey(Product, on_delete=models.CASCADE)
    price_at_purchase = models.DecimalField(max_digits=10, decimal_places=2)
    quantity = models.PositiveIntegerField(default=1)

    def __str__(self):
        return f"{self.quantity}x {self.product.title}"
