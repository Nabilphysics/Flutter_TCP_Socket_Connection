
# Flutter TCP Socket Connection with Server

by Syed Razwanul Haque (https://www.linkedin.com/in/nabilphysics/)
## Video
https://youtu.be/-ATh1BpSKLk
## Project Target
This App can connect to the server. I made this app to be able to communicate with C++ BOOST ASIO Server(https://www.boost.org/doc/libs/1_77_0/doc/html/boost_asio/example/cpp03/chat/chat_server.cpp) and Client (https://www.boost.org/doc/libs/1_77_0/doc/html/boost_asio/example/cpp03/chat/chat_client.cpp).

## Note
During send and receive data the BOOST asio CHAT SERVER example that I have been using from above link add message lenth.
So that in this flutter code I programetically ignored the length. 

During data sending BOOST ASIO need character length. Furtermore, for character less than 9 we have to add
3 spaces, for more than 10 character 2 spaces and more than 100 character 1 space. 

## Data Format
I am using JSON to send and receive data.
But you can send and receive raw data. 

JSON Format: {"imageUrl":"n","gps":"40.741895,-73.989308","date":"1 st may","temp":"37.5","acc":"x:0.59,y:0.39,z:0.44","gyro":"x:0.76,y:0.23,z:0.54","volt":"12.9", "N":"1"}
Note: "imageUrl":"n" means NO image and {"N":"1"} means send with notification.

Using this app I am capturing image from remote computer. This is my application specific.
When user click "Capture Image" it send character "#" so that remote client can identify
it as image capture command.
