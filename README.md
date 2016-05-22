# Chat Room for Hootsuite Challenge #

I created an application for creating chat rooms. The idea to create user channels and other users can discuss a topic in this room.

## Technical features ##

### Language ###
I make the App with Swift 2.0 . 

### Architeture ###

I divided the App in basically 3 Controllers:

- *Login*: Implementation of Social login system (I disabled the login Facebook because it works not legal in the simulator)
- *Main*: Main screen that manages the creation of Channel objects. A list of channels that is updated in real-time, simple.
- *ChatRoom*: A screen that uses the dynamic properties of NoSQL database Firebase, being able to create ChatRoom any source object. In the present case a list of channels, but the ChatRoom screen receives the root parameter as creating a list of messages within this root.

### Backend ###
I used Firebase, its database features Realtime. Also it manages users and keeps your data safe.

### Challenges ###

I believe that the time to learn a realtime database system was the first challenge. Another challenge was not to use interface components and program chat components, a very interesting challenge.

# Video #

![Video](https://bytebucket.org/digoreis/hootsuitechat/raw/ca26e7b3f6bf86780bb80d13aab8a31d62287d0a/v2Hootsuite.gif)