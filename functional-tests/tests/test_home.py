def test_home_page_is_welcoming(home_page):
    home_page.assert_is_welcoming()


def test_create_room(home_page):
    room_page = home_page.create_room()
    room_page.assert_is_a_room()


def test_join_room(home_page):
    home_page.join_room("")
    home_page.assert_is_welcoming()
    home_page.assert_error_joining_room()

    room_page = home_page.join_room("XXXX")
    room_page.assert_is_a_room()
