# Authful
The Authful project is a REST-based two factor authentication code base. It is based on a service-oriented architecture pattern and therefore is best used as an API, behind-the-scenes for an application.

Authful includes:
* Support for multiple “2FA” mobile apps (Google Authenticator, Authy, etc.)
* Support for multiple accounts (production, staging, testing, etc.)
* Enrollment / un-enrollment of users
* SMS integration
* International mobile numbers
* Generation of QR code images
* Validation of user OTPs (one-time passwords)
* Resetting of user secrets
* Management of fallback phone numbers
* Creation and management and invalidation of user recovery codes 

There is additional information further along in the documentation that explains these features in more detail.

## About

Authful was originally written as an internal application to provide Compose customers with the option to enable and configure two factor authentication, thereby increasing the level of security required when accessing their Compose accounts.

So, why did we create our own implementation? After evaluating some of the popular two factor services on the market, we noticed that they required users to use their mobile apps and we did not want our customers to be required to use a specific app just to turn on 2FA in Compose. We wanted to keep it open.

We have open-sourced this tool and codebase so the community can easily and safely implement a two factor authentication solution, as well, that does not force their customers to be locked into a specific vendor’s mobile app.

## Contribute!
We are accepting pull requests that add or improve a basic web interface for viewing and managing users and accounts. Also, we will gladly accept pull requests for any bug fixes.

## Requirements
* Ruby 1.9.3 or higher
* MongoDB 2.2.4 or higher
* A Twilio account (for SMS delivery)

We assume that you have a local version of MongoDB running (we recommend brew to install) or you can use a hosted MongoDB service (like [Compose](https://www.compose.io/signup). I hear those guys are pretty swell.) to run MongoDB for you in both development and production environments.

## Getting Started
After cloning the project, do the following to get started:

1. Install the needed gems.

`gem install bundler && gem bundle update`

2. Configure your driver and environment variables.

For **MongoDB**, configure your mongoid.yml file to point to your instance of MongoDB, either local or hosted.

For **Twilio**, set these environment variables in your `config/initializers/twilio.rb` file.
* TWILIO_SID
* TWILIO_TOKEN
* TWILIO_FROM

Once that is set and good to go, you can run the following command from your terminal of choice:
`rackup -p 4000`

From there, you should have the application up and running on your machine ... like a boss. If, however, your console is filled with errors, double-check that you have updated your bundle and that you have properly set your Twilio variables. We’d recommend [rbenv](https://github.com/sstephenson/rbenv) for this.

## Try Things Out
Well, if you have done all the work to get this working, surely you want to take the next step and try it out. So, return to your handy terminal window ... you need to do one more thing.

#### Setting up a test account and one-time password (OTP)
To do this, run the following command:

`rake db:seed`

When you run this, it will populate your database, but more importantly, it will output, into your terminal window, tokens that you will use for authentication and sample curl commands.

The output will look like this:
(**Note:** This output is currently defaulted for people using pow. If you use rackup or other tools, make sure you change your base URL from `authful.dev` to `localhost`.)

```
Account Token: 4cyo6jssckuqt3pa
User Token: mvex6i
Current OTP: 709450

** Viewing QR Code **
http://authful.dev/qr/mvex6i.png

** Enrolling a user **
curl -X POST http://authful.dev/api/users -H "Api-Token: 4cyo6jssckuqt3pa" -d email=<user-email>

** Validating Code **
curl -X GET http://authful.dev/api/users/mvex6i/validate -H "Api-Token: 4cyo6jssckuqt3pa" -d token=709450

** Unenrolling a user **
curl -X DELETE http://authful.dev/api/users/mvex6i -H "Api-Token: 4cyo6jssckuqt3pa"

** Generating Recovery Codes **
curl -X POST http://authful.dev/api/users/mvex6i/recovery_codes -H "Api-Token: 4cyo6jssckuqt3pa"
```

**Note**: After you run the `rake db:seed` command, the one-time password (OTP) provided is only be valid for 90 seconds. To generate a new OTP for testing, you can create a new user and then use the curl command for enrolling the user via SMS. Otherwise, you can generate a new QR code image and test on a mobile app like Google Authenticator.

Ok, so now you should be set to go. You have a test account and the test account information that you need to get started. 

#### Authful Commands
We have included commands that you will need below.

**Enrolling a user from a 2FA mobile app (like Authenticator, Authy, Duo)**
```bash
curl -X POST http://authful.dev/api/users -H "Api-Token: <account-token>" -d email=<user-email>
```

**Enrolling a user from SMS**
```bash
curl -X POST http://authful.dev/api/users -H "Api-Token: <account-token>" -d email=<user-email> -d phone=<phone-number>
```

**View a user**
```bash
curl -X GET http://authful.dev/api/users/<user-token> -H "Api-Token: <account-token>"
```

**Requesting a code via SMS**
```bash
curl -X GET http://authful.dev/api/users/<user-token>/send_sms -H "Api-Token: <account-token>"
```

**Validating a code**
```bash
curl -X GET http://authful.dev/api/users/<user-token>/validate -H "Api-Token: <account-token>" -d token=<token generated or recieved via sms>
```

**Register a fallback SMS number**
```bash
curl -X PATCH http://authful.dev/api/users/<user-token>/fallback -H "Api-Token: <account-token>" -d phone=<phone number>
```

**Send code to a fallback SMS number**
```bash
curl -X GET http://authful.dev/api/users/<user-token>/fallback -H "Api-Token: <account-token>"
```

**Generate a user's recovery codes**
```bash
curl -X POST http://authful.dev/api/users/<user-token>/recovery_codes -H "Api-Token: <account-token>"
```

**View a user's remaining recovery codes**
```bash
curl -X GET http://authful.dev/api/users/<user-token>/recovery_codes -H "Api-Token: <account-token>"
```

**Validate a user's recovery code**
```bash
curl -X GET http://authful.dev/api/users/<user-token>/recovery_codes/<recovery-code> -H "Api-Token: <account-token>"
```

**Un-enrolling a user**
```bash
curl -X DELETE http://authful.dev/api/users/<user-token> -H "Api-Token: <account-token>"
```

## Final Notes

Now that we have all the details laid out, there are a couple of technical notes about our implementation, just in case this information is helpful.

**Phone Number Validation**

Authful validates phone numbers using [Google libphonenumber](https://code.google.com/p/libphonenumber/).

**QR Codes**

QR Codes are generated based on [RFC 6238 - TOTP](https://tools.ietf.org/html/rfc6238).

## License

Authful is released under the [BSD Simplified License](http://opensource.org/licenses/BSD-3-Clause). The Authful License is available at [LICENSE](LICENSE.md) in the project.