class User
  include Mongoid::Document
  include Mongoid::Timestamps
  # include Mongoid::Geospatial
  include Mongoid::Attributes::Dynamic
  attr_accessor :password
  has_one :session, dependent: :destroy
  mount_uploader :avatar, AttachmentUploader
  before_save :encrypt_password
  after_create :create_session_record

  field :email, type: String, default: ""
  validates_uniqueness_of :email
  # validates_format_of :email, :with => /^[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}$/i, :message => "Please Enter a Valid Email Address."
  validates_presence_of :password, :on => :create
  field :encrypted_password, type: String, default: ""
  field :salt, type: String, default: ""

  # Delegate
  delegate :url, :size, :path, to: :avatar
  # field :attached_item_id, type: Integer
  # field :attached_item_type, type: String 
  field :avatar, type: String#, null: false
  # field :original_filename, type: String
  # Virtual attributes
  # alias_attribute :filename, :original_filename
  validates_integrity_of  :avatar
  validates_processing_of :avatar

  field :first_name, type: String
  field :last_name, type: String
  field :user_name, type: String

  def build_user_hash
    user = {id: self.id.to_s,
     email: self.email,
     created_at: self.created_at
    }
    user[:first_name] = self.first_name if self.first_name
    user[:last_name] = self.last_name if self.last_name
    user[:user_name] = self.user_name if self.user_name
    user[:normal_avatar] = self.avatar.url if self.avatar
    user[:thumb_avatar] = self.avatar.thumb.url if self.avatar
    return user
  end

  def self.search(search)
    search = search.split(" ")
    if search.count == 1
      User.or(
        {"first_name": /.*#{search.first}.*/i}, 
        {"last_name": /.*#{search.first}.*/i}, 
        {"user_name": /.*#{search.first}.*/i}
        )
    else
      User.or(
        {"first_name": /.*#{search.first}.*/i}, 
        {"last_name": /.*#{search.first}.*/i}, 
        {"last_name": /.*#{search.last}.*/i}, 
        {"user_name": /.*#{search.last}.*/i}, 
        {"user_name": /.*#{search.first}.*/i}
        )
    end
  end

  def self.build_search_hash(user)
    user_hash = {id: user.id.to_s,
     first_name: user.first_name,
     last_name: user.last_name,
     email: user.email,
     avatar: user.avatar.url,
     user_name: user.user_name,
     created_at: user.created_at
    }
    # if !current_user.blank?
    #   user_hash[:friendship_status] = current_user.first.followed_users.include?(user.id.to_s) ? 
    #      "Is already a friend" : (user.pending_friends.include?(current_user.first.id.to_s) ? 
    #       "Request Sent" : "Send Request")
    # end
    # user_hash[:like_count] = user.likes.count if user.likes
    return user_hash
  end

  def authenticate(password)
    pass = BCrypt::Engine.hash_secret(password, self.salt)
    self.encrypted_password == pass
  end

  def create_session_record
    require 'json_web_token'
    sesh = Session.new
    sesh.user_id = self.id 
    sesh.jwt = JsonWebToken.encode({user_id: self.id.to_s})
    sesh.save
  end
  private

    def encrypt_password
      if password.present?
        self.salt = BCrypt::Engine.generate_salt
        self.encrypted_password = BCrypt::Engine.hash_secret(password, self.salt)
      end
    end

    def avatar_size_validation
      errors[:avatar] << "should be less than 500KB" if avatar.size > 100.5.megabytes
    end
end



