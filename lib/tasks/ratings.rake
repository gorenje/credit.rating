namespace :ratings do
  desc <<-EOF
    Recompute all the ratings for users.
  EOF
  task :compute do
    User.all.each { |a| a.update_rating }
  end
end
