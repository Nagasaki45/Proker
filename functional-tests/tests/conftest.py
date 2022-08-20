from playwright.sync_api import Page
import pytest

from proker_functional_tests.pages import HomePage


@pytest.fixture
def home_page(page: Page):
    h = HomePage(page, hostname="http://localhost:4000")
    h.visit()
    return h


@pytest.fixture
def room_page(home_page):
    return home_page.create_room()
