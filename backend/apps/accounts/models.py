from django.db import models
from django.contrib.auth.models import User
from apps.core.models import TimeStampedModel

class UserProfile(TimeStampedModel):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='profile')
    vip_tier = models.CharField(max_length=50, default='TIER 01 • GENEVA')
    points = models.PositiveIntegerField(default=5700)
    member_id = models.CharField(max_length=50, default='MM-9042-8819')
    shipping_address = models.TextField(blank=True, default='742 Evergreen Terrace, Sector 7, Neo Geneva')

    def __str__(self):
        return f"{self.user.username} ({self.vip_tier})"
