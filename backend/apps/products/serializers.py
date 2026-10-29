from rest_framework import serializers
from .models import Category, Product, ProductSpec, ProductReview

class ProductSpecSerializer(serializers.ModelSerializer):
    class Meta:
        model = ProductSpec
        fields = ['id', 'key', 'value']

class ProductReviewSerializer(serializers.ModelSerializer):
    class Meta:
        model = ProductReview
        fields = ['id', 'author', 'rating', 'comment', 'is_verified_buyer', 'created_at']

class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = ['id', 'name', 'slug', 'description']

class ProductSerializer(serializers.ModelSerializer):
    category = CategorySerializer(read_only=True)
    category_id = serializers.PrimaryKeyRelatedField(
        queryset=Category.objects.all(), source='category', write_only=True
    )
    specs = ProductSpecSerializer(many=True, read_only=True)
    reviews = ProductReviewSerializer(many=True, read_only=True)

    class Meta:
        model = Product
        fields = [
            'id', 'title', 'slug', 'category', 'category_id', 'price',
            'description', 'icon_name', 'accent_color', 'rating',
            'review_count', 'is_featured', 'is_daily_drop', 'stock',
            'badge', 'specs', 'reviews', 'created_at'
        ]
