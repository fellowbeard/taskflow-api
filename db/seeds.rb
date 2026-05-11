["Michael", "Sage", "Alex"].each do |name|
  User.find_or_create_by!(name: name) do |user|
    user.password = "password"
  end
end