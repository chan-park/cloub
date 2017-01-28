# **cloub**, Location-based Social Networking App #

##**What Database Should Look Like**

```
#!JSON

"database": {
    "geofire": {
        "postId": {
             g: "hashkey", 
             l: {
                 "lat": latitude,
                 "long": longitude"
             }
        }
    },
    "users" : {
        "user.uid": {
            "username": userId,
            "email": email,
            "profilePictureUrl": url,
            "posts": {
                "postId": {
                    "timestamp": timestamp,
                    "pictureUrl": url # this should be medium size picture
                }
                
            }
        }
    },
    "posts" : {
        "postId": {
            "writer" : userId,
            "caption" : text,
            "comments" : {
                "commentId": {
                    "commenter": userId,
                    "comment": comment
                },
            },
            "pictureUrl" : url,
            "likes" : number
        }
    }
}
```
# **How do you download posts?**
First off, GeoFire regionQuery queries all postId's on a certain region(where user scrolls on the map). 

# How to scale posts?
When GeoFire queries posts on the map, you only fetch thumbnail versions of the posts on the map. You only download the contents of the post if the user presses on the annotationView. 

To make this work, each time a user posts, you are going to store two images, one shrinked image, and one original image. 


** Pseudocode **

```
#!python
for each postId:
    if postId is not in posts:
        construct a Post instance with postId, and its contents
        store it into posts dictionary
```

    



##** Bugs to fix later & UI improvements **
1. Keyboard covers text field in signup view
2. Applying filter on the picture by swiping left and right in post view
3. TabBarController item should be vertically centered properly. Quite lopsided currently.
4. **Pictures are not displayed in order!(ProfileViewController)**
5. Enable refresh map
6. If user clicks on a post on someone else's profile view, you can see comments, likes, location.
7. When user changes it's location, and user presses share button, you have to update its location accordingly
8. **When user adds post, post is duplicated in the cluster(but not on database)** Solved.

##** How To Order Posts So Top Post Goes on Top of Cluster **
1. Kingpin

##**Functionalities to work on**
1. When creating account, check existing username