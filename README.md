# Cloub

## Authors
 - Chan Park
  - Jeffrey Li
   
## Purpose
   Cloub is a location-based message board for users to post locally and view 
   posts on a map across the world.

## Features
- Ability to see public posts around the world
- See posts based on locations and users’ followings
- Browse through a feed of posts made by users the user follows

## Control Flow
- User first creates an account
- After logging in, user can bounce among three controllers to:
- Map of the world with a color-coded identifier that lets the user know how many posts are centered in a location.
- If the user decides to zoom in, more pins will show up but the number of posts per pin goes down. When the user zooms in enough to see individual posts, the user can tap into the post to view it.
- The user can also create a post here
- When user makes a post, he will fill in text and provide an image with the camera
- A post is of text and image. Within a post, the user has the ability to follow the poster and “like” the post
- Feed of posts from the user’s follow list
- User can browse posts in an Instagram-like view of posts from the users he follows
- If user taps into a post, he can view the post
- User’s profile contains a listing of his past posts from the image
- Once an image is tapped, the user is brought to the posting with the text and image from the previous post

## Implementation
### Model
- User.swift 
- Post.swift 

### View
- ProfileView
- MapView
- PostView
- LoginView
- SignUpView
- FeedView

### Controller
- ProfileViewController.swift
- MainViewController.swift
- MainTabBarController.swift
- FeedViewController.swift
- FeedDetailViewController.swift
- PostViewController.swift
- LoginViewController.swift
- SignUpViewController.swift


