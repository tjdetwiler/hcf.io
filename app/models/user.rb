require 'digest/sha1'

class User < ActiveRecord::Base
  has_many :projects

  validates_length_of :login, :within => 3..40
  validates_length_of :password, :within => 5..40
  validates_presence_of :login, :email, :password, :password_confirmation, :pw_salt
  validates_uniqueness_of :login, :email
  validates_confirmation_of :password
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => "invalid email format"

  attr_protected :id, :pw_salt
  attr_accessor :password, :password_confirmation


  def self.authenticate(login, pass)
    u = find(:first, :conditions=>["login = ?", login])
    u = u || find(:first, :conditions=>["email = ?", login])
    return nil if u.nil?
    return u if User.encrypt(pass, u.pw_salt) == u.pw_hash
    nil
  end

  def password=(pass)
    @password=pass
    self.pw_salt = User.random_string(10) if !self.pw_salt?
    self.pw_hash = User.encrypt(@password, self.pw_salt)
  end

  def send_new_password
    new_pass = User.random_string 10
    self.password = self.password_confirmation = new_pass
    self.save
    #Notifications.deliver_forgot_password(self.email, self.login, new_pass)
  end

  protected

  def self.encrypt(pass, salt)
    Digest::SHA1.hexdigest(pass.to_s+salt.to_s)
  end

  def self.random_string(len)
    # generate a random string consisting of strings and digits
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    newpass = ""
    1.upto(len) { |_| newpass << chars[rand(chars.size-1)] }
    return newpass
  end

end
