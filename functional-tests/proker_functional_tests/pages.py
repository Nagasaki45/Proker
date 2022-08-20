from playwright.sync_api import Page, expect


class HomePage:
    def __init__(self, page: Page, hostname=str) -> None:
        self.page = page
        self.hostname = hostname

    def visit(self):
        self.page.goto(self.hostname)

    def assert_is_welcoming(self) -> None:
        header = self.page.locator("h1.title:text('Welcome to Proker')")
        expect(header).to_be_visible()

    def assert_error_joining_room(self) -> None:
        error = self.page.locator("form .is-danger")
        expect(error).to_be_visible()

    def create_room(self):
        self.page.locator("button:text('Create room')").click()
        return RoomPage(self.page, self.hostname)

    def join_room(self, key):
        self.page.locator(".label:text('Room key')").fill(key)
        self.page.locator("button:text('Join room')").click()
        return RoomPage(self.page, self.hostname)


class RoomPage:
    def __init__(self, page: Page, hostname: str):
        self.page = page
        self.hostname = hostname

    def assert_is_a_room(self):
        expect(self._get_header()).to_be_visible()

    def get_key_from_header(self):
        header = self._get_header()
        header_text = header.inner_text()
        return header_text.split()[1]

    def get_key_from_url(self):
        return self.page.url.strip("/").rsplit("/")[-1]

    def click_back_home_button(self):
        self.page.locator("a:has-text('Back Home')").click()
        return HomePage(self.page, self.hostname)

    def join(self, name):
        self.page.locator(".label:text('Your name')").fill(name)
        self.page.locator("button:text('Join room')").click()

    def _get_header(self):
        return self.page.locator("h1.title:has-text('Room')")