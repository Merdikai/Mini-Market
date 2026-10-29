from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny
from django.contrib.auth.models import User
from .serializers import UserSerializer
from .models import UserProfile

class CurrentUserView(APIView):
    permission_classes = [AllowAny]

    def get(self, request):
        # Demo / Default VIP Profile for Showcase
        user, _ = User.objects.get_or_create(
            username='alexandre',
            defaults={
                'email': 'alexandre@minimarket.luxury',
                'first_name': 'Alexandre',
                'last_name': 'Mercer',
            }
        )
        profile, _ = UserProfile.objects.get_or_create(user=user)
        serializer = UserSerializer(user)
        return Response(serializer.data)
