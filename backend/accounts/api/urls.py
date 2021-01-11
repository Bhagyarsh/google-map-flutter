from django.urls import include, path
from rest_framework_jwt.views import verify_jwt_token
from rest_framework_jwt.views import obtain_jwt_token
from rest_framework_jwt.views import refresh_jwt_token
from .views import RegisterAPIView, AuthAPIView
urlpatterns = [
    #path('auth/jwt', AuthAPIView.as_view()),
    path('user/register', RegisterAPIView.as_view()),
    path('user', obtain_jwt_token),
    path('user/verify', verify_jwt_token),
    path('user/refresh', refresh_jwt_token),
]