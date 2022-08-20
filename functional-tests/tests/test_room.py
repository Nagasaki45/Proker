def test_room_key(room_page):
    assert room_page.get_key_from_header() == room_page.get_key_from_url()


def test_back_home_button(room_page):
    home_page = room_page.click_back_home_button()
    home_page.assert_is_welcoming()
