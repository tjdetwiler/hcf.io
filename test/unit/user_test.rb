require 'test_helper'

class UserTest < ActiveSupport::TestCase
  self.use_instantiated_fixtures = true
  fixtures :users


  def test_auth 
    #check that we can login we a valid user 
    assert_equal  @bob, User.authenticate("bob", "test")    
    #wrong username
    assert_nil    User.authenticate("nonbob", "test")
    #wrong password
    assert_nil    User.authenticate("bob", "wrongpass")
    #wrong login and pass
    assert_nil    User.authenticate("nonbob", "wrongpass")
  end


  def test_passwordchange
    # check success
    assert_equal @longbob, User.authenticate("longbob", "longtest")
    #change password
    @longbob.password = @longbob.password_confirmation = "nonbobpasswd"
    assert @longbob.save
    #new password works
    assert_equal @longbob, User.authenticate("longbob", "nonbobpasswd")
    #old pasword doesn't work anymore
    assert_nil   User.authenticate("longbob", "longtest")
    #change back again
    @longbob.password = @longbob.password_confirmation = "longtest"
    assert @longbob.save
    assert_equal @longbob, User.authenticate("longbob", "longtest")
    assert_nil   User.authenticate("longbob", "nonbobpasswd")
  end

  def test_disallowed_passwords
    #check thaat we can't create a user with any of the disallowed paswords
    u = User.new    
    u.login = "nonbob"
    u.email = "nonbob@mcbob.com"
    #too short
    u.password = u.password_confirmation = "tiny" 
    assert !u.save     
    assert u.invalid?('password')
    #too long
    u.password = u.password_confirmation = "hugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehuge"
    assert !u.save     
    assert u.invalid?('password')
    #empty
    u.password = u.password_confirmation = ""
    assert !u.save    
    assert u.invalid?('password')
    #ok
    u.password = u.password_confirmation = "bobs_secure_password"
    assert u.save     
    assert u.errors.empty? 
  end

  def test_bad_logins
    #check we cant create a user with an invalid username
    u = User.new  
    u.password = u.password_confirmation = "bobs_secure_password"
    u.email = "okbob@mcbob.com"
    #too short
    u.login = "x"
    assert !u.save     
    assert u.invalid?('login')
    #too long
    u.login = "hugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhug"
    assert !u.save     
    assert u.invalid?('login')
    #empty
    u.login = ""
    assert !u.save
    assert u.invalid?('login')
    #ok
    u.login = "okbob"
    assert u.save  
    assert u.errors.empty?
    #no email
    u.email=nil   
    assert !u.save     
    assert u.invalid?('email')
    #invalid email
    u.email='notavalidemail'   
    assert !u.save     
    assert u.invalid?('email')
    #ok
    u.email="validbob@mcbob.com"
    assert u.save  
    assert u.errors.empty?
  end


  def test_collision
    #check can't create new user with existing username
    u = User.new
    u.login = "existingbob"
    u.password = u.password_confirmation = "bobs_secure_password"
    assert !u.save
  end


  def test_create
    #check create works and we can authenticate after creation
    u = User.new
    u.login      = "nonexistingbob"
    u.password = u.password_confirmation = "bobs_secure_password"
    u.email="nonexistingbob@mcbob.com"  
    assert_not_nil u.pw_salt
    assert u.save
    assert_equal 10, u.pw_salt.length
    assert_equal u, User.authenticate(u.login, u.password)

    u = User.new(:login => "newbob", :password => "newpassword", :password_confirmation => "newpassword", :email => "newbob@mcbob.com" )
    assert_not_nil u.pw_salt
    assert_not_nil u.password
    assert_not_nil u.pw_hash
    assert u.save 
    assert_equal u, User.authenticate(u.login, u.password)

  end

  def test_rand_str
    new_pass = User.random_string(10)
    assert_not_nil new_pass
    p new_pass
    assert_equal 10, new_pass.length
  end

  def test_sha1
    u=User.new
    u.login      = "nonexistingbob"
    u.email="nonexistingbob@mcbob.com"  
    u.pw_salt="1000"
    u.password = u.password_confirmation = "bobs_secure_password"
    assert u.save   
    assert_equal 'b1d27036d59f9499d403f90e0bcf43281adaa844', u.pw_hash
    assert_equal 'b1d27036d59f9499d403f90e0bcf43281adaa844', User.encrypt("bobs_secure_password", "1000")
  end

  def test_protected_attributes
    #check attributes are protected
    u = User.new(:id=>999999, :pw_salt=>"I-want-to-set-my-salt", :login => "badbob", :password => "newpassword", :password_confirmation => "newpassword", :email => "badbob@mcbob.com" )
    assert u.save
    assert_not_equal 999999, u.id
    assert_not_equal "I-want-to-set-my-salt", u.pw_salt

    u.update_attributes(:id=>999999, :pw_salt=>"I-want-to-set-my-salt", :login => "verybadbob")
    assert u.save
    assert_not_equal 999999, u.id
    assert_not_equal "I-want-to-set-my-salt", u.pw_salt
    assert_equal "verybadbob", u.login
  end

  
end
