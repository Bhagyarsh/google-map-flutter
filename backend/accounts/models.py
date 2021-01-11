from django.db import models
from django.contrib.auth.models import (
    BaseUserManager, AbstractBaseUser
)


class UserManager(BaseUserManager):
    def create_user(self, username, firstname, lastname, password=None):
        """
        Creates and saves a User with the given email and password.
        """
        if not username:
            raise ValueError('Users must have an username address')

        user = self.model(
            username=username,
            firstname=firstname,
            lastname=lastname
        )

        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_staffuser(self, username, firstname, lastname, password):
        """
        Creates and saves a staff user with the given email and password.
        """
        user = self.create_user(
            username,
            firstname=firstname,
            lastname=lastname,
            password=password,
        )
        user.staff = True
        user.save(using=self._db)
        return user

    def create_superuser(self, username, firstname, lastname, password):
        """
        Creates and saves a superuser with the given email and password.
        """
        user = self.create_user(
            username,
            firstname=firstname,
            lastname=lastname,
            password=password,
        )
        user.staff = True
        user.admin = True
        user.save(using=self._db)
        return user

# hook in the New Manager to our Model


class User(AbstractBaseUser):

    username = models.CharField(max_length=255,unique=True)
    firstname = models.CharField(max_length=255)
    lastname = models.CharField(max_length=255)
    Verified = models.BooleanField(default=False)
    active = models.BooleanField(default=True)
    staff = models.BooleanField(default=False)  # a admin user; non super-user
    admin = models.BooleanField(default=False)  # a superuser
    timestamp = models.DateTimeField(auto_now_add=True)

    objects = UserManager()
    USERNAME_FIELD = 'username'
    # Email & Password are required by default.
    REQUIRED_FIELDS = ['firstname', 'lastname']

    def __str__(self):
        return str(self.username)

    def get_full_name(self):
        # The user is identified by their email address
        return self.firstname + ' ' + self.lastname

    def get_short_name(self):
        # The user is identified by their email address
        return self.firstname


    def has_perm(self, perm, obj=None):
        "Does the user have a specific permission?"
        # Simplest possible answer: Yes, always
        return True

    def has_module_perms(self, app_label):
        "Does the user have permissions to view the app `app_label`?"
        # Simplest possible answer: Yes, always
        return True

    @property
    def is_verified(self):
        "Is the user a member of staff?"
        return self.Verified

    @property
    def is_staff(self):
        "Is the user a member of staff?"
        return self.staff

    @property
    def is_admin(self):
        "Is the user a admin member?"
        return self.admin

    @property
    def is_active(self):
        "Is the user active?"
        return self.active
