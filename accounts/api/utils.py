from .serializers import UserSerializer
from django.conf import settings
from django.utils import timezone
import datetime

from rest_framework.views import exception_handler
from rest_framework.response import Response
expire_delta = settings.JWT_AUTH['JWT_REFRESH_EXPIRATION_DELTA']

def jwt_response_payload_handler(token, user=None, request=None):
    # x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
    # if x_forwarded_for:
    #     ip = x_forwarded_for.split(',')[0]
    # else:
    #     ip = request.META.get('REMOTE_ADDR')
    #     print(ip)
    return {
        'token': token,
        'user': user.username,
        'fullname': user.get_full_name(),
        'expires': timezone.now() + expire_delta - datetime.timedelta(seconds=200)
    }

