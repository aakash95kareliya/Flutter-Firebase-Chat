# flutter_chat

Flutter Chat with firebase realtime database.

# How it works:

Before start chatting, you need to login with google.After that you can see list of user which are store in database.
Tap on any user list item to redirect to chat screen where you can start chatting.

Following plugins are used.
1) Fireabase Auth(https://pub.dev/packages/firebase_auth)
    -For User authentication
2) Firebase database(https://pub.dev/packages/firebase_database)
    -Store user data in firebase database
3) Shared Preference(https://pub.dev/packages/shared_preferences)
    -Store user data to manage user session.
