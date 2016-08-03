# Photo Gallery Backend

Gallery_pic is app with a simple concept, Upload, Vote, Win!!! Users can upload pictures to several different categories, allow those pictures to be voted on, and at the end of each contest the users with the most votes in each category wins free cool prizes (Flat screen T.V's, Tablets, Smart Phones, and many more cool free prizes).

 1. [General](#general)
 1. [Authentication](#authentication)
 1. [Api Response](#api-response)

## General ##

 1. Ruby version: 2.2.1
 1. Rails version: 4.2.5
 1. Server engine: Mysql2

Run `rake doc:app` for classes and methods documentation.

Checkout [Gemfile](Gemfile) for dependencies.

## Authentication ##

The API in [app](app/controllers) uses 3 keys of authentication:

 1. access_token: used when a user successfully logs in through the API. This parameter is required for all API requests, except API endpoints for login, sign up, reset password and installation.
 1. installation_key: Used when a device/installation has been registered to Gallery_pic. This is required for login, sign up and reset password endpoints. Don't send this parameter if an access_token is available.
 1. api_key: This is used only for registering an installation. The API key is `fa8acaf23e85c71b5f261fb2016e2548`

### API Response ###

The API sends consistent response for success or errors.

For errors, it always sends `error` object with `code` for error code and `message` for error message.

Error example:

```
{
 "error":
 { 
     "code": 401,
     "message": "Error message"
 }
}
```

For successful API request, it always sends `data` object with either an `object` or an `array` with the requested data.

Succcess example:
```
{
 "data": []
}
```# pic_gallery
