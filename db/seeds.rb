Account.delete_all
User.delete_all

a = Account.create(name: "Authful Development", )
u = User.create(account: a, email: "dummy@authful.com", qr_expiration: 10.minutes.from_now)
otp = u.generate_otp

puts <<MEMO
Account Token: #{a.token}
User Token: #{u.token}
Current OTP: #{otp}

** Viewing QR Code **
http://authful.dev#{u.qr_url}

** Enrolling a user **
curl -X POST http://authful.dev/api/users -H "Api-Token: #{a.token}" -d email=<user-email>

** Validating Code **
curl -X GET http://authful.dev/api/users/#{u.token}/validate -H "Api-Token: #{a.token}" -d token=#{otp}

** Unenrolling a user **
curl -X DELETE http://authful.dev/api/users/#{u.token} -H "Api-Token: #{a.token}"

** Generating Recovery Codes **
curl -X POST http://authful.dev/api/users/#{u.token}/recovery_codes -H "Api-Token: #{a.token}"
MEMO
