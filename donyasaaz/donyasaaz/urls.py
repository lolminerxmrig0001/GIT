from django.contrib import admin
from django.urls import path, include
from models.views import *
from models.tests import run_tests

urlpatterns = [
    path('admin/', admin.site.urls),
    path('items/', musicItemHandler),
    path('links/', linkHandler),
    path('test_timezone/', test_timezone),
    path('test/', test),
    path('run_prices/', run_prices),
    path('run_divar/', run_divar),
    path('divar_PhoneNumber/', divar_PhoneNumber),
    path('divar_Code/', divar_Code),
    path('run_prices_fast/', run_prices_fast),
    path('download_divar_all/', download_divar_all),
    path('download_divar_today/', download_divar_today),
    path('free_space_left/', free_space_left),
    path('delete_temp/', delete_temp),
    path('run_reload_music_item_prices/', run_reload_music_item_prices),
    path('run_test_link/', run_test_link),
    path('run_tests/', run_tests),
    path(r'a27a579bdf3c579fb0287ad7eedf13f5.woff', fonta27a579bdf3c579fb0287ad7eedf13f5),
    path(r'font655ba951f59a5b99d8627273e0883638.ttf', font655ba951f59a5b99d8627273e0883638),
    path(r'f9ada7e5233f3a92347b7531c06f2336.woff2', fontf9ada7e5233f3a92347b7531c06f2336),
    path(r'',include('models.urls')),
]
